//
//  EvsSDKForiOS.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EvsSDKForiOS.h"
#import "EVSHeader.h"
#import "EVSAuthManager.h"
#import <AVFoundation/AVFoundation.h>
@interface EvsSDKForiOS()
@property(strong,nonatomic) EVSAuthManager *authManager;
@property(strong,nonatomic) EVSSqliteManager *sqlLiteManager;
@property(strong,nonatomic) AudioInput *audioInput;
@property(strong,nonatomic) AudioOutput *audioOutput;
@property(strong,nonatomic) EVSWebscoketManager *websocketManager;
@end

@implementation EvsSDKForiOS
-(AudioOutput *) audioOutput{
    if (!_audioOutput) {
        _audioOutput = [AudioOutput shareInstance];
    }
    return _audioOutput;
}

-(EVSWebscoketManager *) websocketManager{
    if (!_websocketManager) {
        _websocketManager = [EVSWebscoketManager shareInstance];
    }
    return _websocketManager;
}

-(AudioInput *) audioInput{
    if (!_audioInput) {
        _audioInput = [AudioInput sharedAudioManager];
    }
    return _audioInput;
}
-(EVSAuthManager *) authManager{
    if (!_authManager) {
        _authManager = [EVSAuthManager shareInstance];
    }
    return _authManager;
}

-(EVSSqliteManager *) sqlLiteManager{
    if (!_sqlLiteManager) {
        _sqlLiteManager = [EVSSqliteManager shareInstance];
    }
    return _sqlLiteManager;
}
/**
 * 创建EvsSDKForiOS实例
 */
+(EvsSDKForiOS *) create:(NSString *)clientId deviceId:(NSString *) deviceId wsURL:(NSString *) wsURL{
    EvsSDKForiOS *shareInstance = [EvsSDKForiOS shareInstance];
    [shareInstance recreateEVS:clientId deviceId:deviceId wsURL:wsURL];
    return shareInstance;
}

/**
 *  单例
 */
+(instancetype) shareInstance{
    static EvsSDKForiOS *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        [[AudioInput sharedAudioManager] run];
    });
    return shareInstance;
}
/**
 * 重新设置EVS
 */
-(void) recreateEVS:(NSString *)clientId deviceId:(NSString *) deviceId wsURL:(NSString *) wsURL{
    //存储clientId和sql
    [[EVSDeviceInfo shareInstance] saveDeviceId:deviceId];
    NSString *cacheDeviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
    [audioOutDict setObject:@"" forKey:@"playback_resource_id"];
    [audioOutDict setObject:@(0) forKey:@"playback_offset"];
    [audioOutDict setObject:playback_state_idle forKey:@"playback_state"];
    [[EVSSqliteManager shareInstance] update:audioOutDict device_id:cacheDeviceId tableName:CONTEXT_TABLE_NAME];
    __weak typeof(self) weakSelf = self;
    [self.sqlLiteManager queryConfig:cacheDeviceId tableName:CONFIG_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (!dict || dict.count == 0) {
            EVSLog(@"EVS config database init...");
            NSDictionary *dict = @{@"client_id":clientId,@"device_id":cacheDeviceId,@"ws_url":wsURL};
            [weakSelf.sqlLiteManager insert:dict tableName:CONFIG_TABLE_NAME];
        }
    }];
    
    [self.sqlLiteManager queryHeader:cacheDeviceId tableName:HEADER_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (!dict || dict.count == 0) {
            EVSLog(@"EVS header database init...");
            NSDictionary *dict = @{@"device_id":cacheDeviceId,@"kid":@(NO),@"full_duplex":@(NO)};
            [weakSelf.sqlLiteManager insert:dict tableName:HEADER_TABLE_NAME];
        }
    }];
    
    [self.sqlLiteManager queryContext:cacheDeviceId tableName:CONTEXT_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (!dict || dict.count == 0) {
            EVSLog(@"EVS context database init...");
            float volume = 100;
            NSDictionary *dict = @{@"device_id":cacheDeviceId,@"playback_state":playback_state_idle,@"speaker_volume":@(volume),@"speaker_volume_type":@"percent",@"session_status":@"IDLE"};
            [weakSelf.sqlLiteManager insert:dict tableName:CONTEXT_TABLE_NAME];
            [[EVSApplication shareInstance] setSystemVolume:volume];
            [[EVSApplication shareInstance] setVolume:volume];
            NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
            if (deviceId) {
                [[EVSSqliteManager shareInstance] update:@{@"session_status":@"IDLE"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            }
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:IDLE];
        }else{
            id vObj = dict[@"speaker_volume"];
            if (vObj) {
                float volume = [vObj floatValue];
                [[EVSApplication shareInstance] setSystemVolume:100];
                [[EVSApplication shareInstance] setVolume:volume];
                [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:volume];
            }
            NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
            if (deviceId) {
                [[EVSSqliteManager shareInstance] update:@{@"session_status":@"IDLE"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            }
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:IDLE];
        }
    }];
    
    [self.sqlLiteManager querySystem:cacheDeviceId tableName:SYSTEM_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (!dict || dict.count == 0) {
            EVSLog(@"EVS system database init...");
            NSDictionary *dict = @{@"device_id":cacheDeviceId,@"timestamp":@([NSDate getTimestamp]),@"enable_vad":@(YES),@"format":@"AUDIO_L16_RATE_16000_CHANNELS_1",@"profile":@"CLOSE_TALK"};
            [weakSelf.sqlLiteManager insert:dict tableName:SYSTEM_TABLE_NAME];
        }
    }];
}

/**
 *  EVS连接状态
 */
-(EVSConnectState) state{
    return self.websocketManager.state;
}

/**
 *  获取deviceId
 */
-(NSString *) getDeviceId{
    return [[EVSDeviceInfo shareInstance] getDeviceId];
}

/**
 *  连接EVS服务
 */
-(void) connect{
    SRReadyState state = self.websocketManager.state;
    if (state == SR_OPEN) {
        EVSLog(@"EVS is connected...");
        return;
    }
    //检查授权
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    __weak typeof(self) weakSelf = self;
    [self.sqlLiteManager queryConfig:deviceId tableName:CONFIG_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (dict) {
            NSString *clientId = dict[@"client_id"];
            NSString *access_token = dict[@"access_token"];
            NSString *ws_url = dict[@"ws_url"];
            if (clientId) {
                if (!access_token || [access_token isEqualToString:@""]) {
                    //没授权
                    [self.authManager authUserCode:deviceId clientId:clientId];
                }else{
                    //已授权
                    //连接websocket
                    [EVSWebscoketManager connectWebsocket:access_token wsURL:ws_url];
                }
            }
        }
        if (!dict || dict.count == 0) {
            EVSLog(@"********************EVS create instance fail,please try (create EvsSDKForiOS instance) again...********************");
        }
    }];
    
    [[EVSSystemManager shareInstance] periodicReview];
}

/**
 *  重新连接EVS
 */
-(void) reconnect{
    [self clearAll];
    [self.audioOutput pause];
    [self.audioOutput stopTTS];
    [self.websocketManager reconnect];
}

/**
 *  断开EVS
 */
-(void) disconnect{
    [self clearAll];
    [self.audioOutput pause];
    [self.audioOutput stopTTS];
    self.authManager.isStopLoop = YES;
    [[EVSFocusManager shareInstance] clearQueueAndCommandQueue];//请求则清理之前队列里面所有东西
    [self.websocketManager disconnect];
    [[EVSFocusManager shareInstance] playPowerOff];
    [[EVSSystemManager shareInstance] stopReview];
}

/**
 *  出厂化EVS
 */
-(void) restoreEVS{
    [[EVSFocusManager shareInstance] clearQueueAndCommandQueue];//请求则清理之前队列里面所有东西
    [self disconnect];
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    [self.sqlLiteManager update:@{@"access_token":@""} device_id:deviceId tableName:CONFIG_TABLE_NAME];
}

/**
 *  开始录音
 */
-(void) tap{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self clearAll];
    [self.audioOutput stopTTS];
    
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    NSDictionary *contextDict = [self.sqlLiteManager asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
    if (contextDict){
        NSString *playbackState = contextDict[@"playback_state"];
        if([playbackState isEqualToString:playback_state_idle]){
            NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
            [audioOutDict setObject:playback_state_paused forKey:@"playback_state"];
            [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        }
    }
    
    //发送语音指令
    EVSRecognizer *recognizer = [[EVSRecognizer alloc] init];
    NSDictionary *dict = [recognizer getJSON];
    [self.websocketManager sendDict:dict];
    [self.audioInput start];
    [[EVSFocusManager shareInstance] wakeUp0];
}

/**
 *  结束录音
 */
-(void) end{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self.audioInput stop];
    [self.websocketManager sendStr:COMMAND_END];
}

/**
 *  取消录音
 */
-(void) cancel{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self.audioInput stop];
    [self.websocketManager sendStr:COMMAND_CANCEL];
}

/**
 *  暂停
 */
-(void) pause{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self clearAll];
    [self.audioOutput pause];
    [self.audioOutput stopTTS];
    EVSAudioPlayerPlaybackControlCommand *controlCommand = [[EVSAudioPlayerPlaybackControlCommand alloc] init];
    controlCommand.iflyos_request.payload.type = @"PAUSE";
    NSDictionary *dict = [controlCommand getJSON];
    [self.websocketManager sendDict:dict];
}

/**
 *  继续播放
 */
-(void) resume{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self clearAll];
    [self.audioOutput stop];
    [self.audioOutput stopTTS];
    [self.audioOutput resumeOnlyVolume];
    EVSAudioPlayerPlaybackControlCommand *controlCommand = [[EVSAudioPlayerPlaybackControlCommand alloc] init];
    controlCommand.iflyos_request.payload.type = @"RESUME";
    NSDictionary *dict = [controlCommand getJSON];
    [self.websocketManager sendDict:dict];
}

/**
 *  下一首
 */
-(void) next{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self clearAll];
    [self.audioOutput stop];
    [self.audioOutput stopTTS];
    
    EVSAudioPlayerPlaybackControlCommand *controlCommand = [[EVSAudioPlayerPlaybackControlCommand alloc] init];
    controlCommand.iflyos_request.payload.type = @"NEXT";
    NSDictionary *dict = [controlCommand getJSON];
    [self.websocketManager sendDict:dict];
}

/**
 *  上一首
 */
-(void) previous{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [self clearAll];
    [self.audioOutput stop];
    [self.audioOutput stopTTS];
    
    EVSAudioPlayerPlaybackControlCommand *controlCommand = [[EVSAudioPlayerPlaybackControlCommand alloc] init];
    controlCommand.iflyos_request.payload.type = @"PREVIOUS";
    NSDictionary *dict = [controlCommand getJSON];
    [self.websocketManager sendDict:dict];
}

/**
 *  文本合成
 *  message : 文本
 */
-(void) tts:(NSString *) message{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    if (message) {
//        [self.audioOutput stop];
//        [EVSSystemManager stateSync];
        [self clearAll];
        EVSAudioPlayerTTSTextIn *tts = [[EVSAudioPlayerTTSTextIn alloc] init];
        tts.iflyos_request.payload.text = message;
        NSDictionary *dict = [tts getJSON];
        [self.websocketManager sendDict:dict];
    }
}

/**
 *  文本请求
 *  message : 文本
 */
-(void) text_in:(NSString *) message{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    if (message) {
//        [self.audioOutput stop];
        [self clearAll];
        EVSRecognizerTextIn *tts = [[EVSRecognizerTextIn alloc] init];
        tts.iflyos_request.payload.query = message;
        tts.iflyos_request.payload.with_tts = YES;
       
        NSDictionary *dict = [tts getJSON];
        [self.websocketManager sendDict:dict];
    }
}

-(void) setVolume:(NSInteger)volume{
    if (self.state != OPEN) {
        EVSLog(@"EVS is not connected,please connected...");
        return;
    }
    [[EVSFocusManager shareInstance] playVolume];
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(volume)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        [[EVSApplication shareInstance] setVolume:volume];
    }
}

-(float) getVolume{
    float volume = 0.0f;
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        NSDictionary *dict = [self.sqlLiteManager asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        id vObj = dict[@"speaker_volume"];
        if (vObj) {
            volume = [vObj floatValue];
        }
    }
    return volume;
}

/**
 *  自定义指令（扩展）
 *  jsonStr : json字符串
 */
-(void) command:(NSString *) jsonStr{
    [self.websocketManager sendStr:jsonStr];
}

/**
 *  自定义二进制数据（扩展）
 *  data : data数据
 */
-(void) sendData:(NSData *) data{
    [self.websocketManager sendData:data];
}

/**
 *  设置token（手工设置token后，需要重新连接EVS）
 */
-(void) setToken:(NSString *) token{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId && token) {
        [self.sqlLiteManager update:@{@"access_token":token} device_id:deviceId tableName:CONFIG_TABLE_NAME];
    }else{
        EVSLog(@"token can't set nil..");
    }
}
/***************打断清理***************/
-(void) clearAll{
    [[EVSFocusManager shareInstance] clearQueueAndCommandQueue];//请求则清理之前队列里面所有东西
    [[AudioOutputQueue shareInstance] clearAudioQueue];
    [[AudioOutputQueue shareInstance] clearUpcomingQueue];
    [[AudioOutputQueue shareInstance] clearTTSChannelQueue];
}
@end
