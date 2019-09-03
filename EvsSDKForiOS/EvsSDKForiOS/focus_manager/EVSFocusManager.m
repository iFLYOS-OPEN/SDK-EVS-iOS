//
//  EVSFocusManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/12.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSFocusManager.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"

#define dispatch_key "focus_mananger_dispatch"
@interface EVSFocusManager()<AudioOutputQueueDelegate>
@property(strong,nonatomic) AudioInput *input;//录音
@property(strong,nonatomic) AudioOutput *output;//播放器
@property(strong,nonatomic) NSMutableArray *queue;//响应回复队列
@property(strong,nonatomic) AudioOutputQueue *audioOutputQueue;//播放器队列
@end

@implementation EVSFocusManager

/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSFocusManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

-(id) init{
    if (self == [super init]) {
        self.audioOutputQueue.delegate = self;
    }
    return self;
}

-(AudioOutputQueue *) audioOutputQueue{
    if (!_audioOutputQueue) {
        _audioOutputQueue = [AudioOutputQueue shareInstance];
    }
    return _audioOutputQueue;
}

-(AudioOutput *) output{
    if (!_output) {
        _output = [AudioOutput shareInstance];
    }
    return _output;
}

-(NSMutableArray *) queue{
    if (!_queue) {
        _queue = [[NSMutableArray alloc] init];
    }
    return _queue;
}

/**********************************请求处理****************************************/
//添加请求到队列
-(void) addQueue:(EVSResponseModel *) newModel{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        @synchronized (self) {
            NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
            if (deviceId) {
                [[EVSSqliteManager shareInstance] update:@{@"reply_key":@""} device_id:deviceId tableName:CONTEXT_TABLE_NAME];//清理追问key
                if ([newModel.iflyos_meta.request_id isActiveRequestIdType]) {
                    //判断是否主动发起的request
                    NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
                    if (contextDict) {
                        NSString *currentRequestId = contextDict[@"request_id"];
                        //判断request_id是否当前请求,相同则执行
                        if (currentRequestId && [newModel.iflyos_meta.request_id isEqualToString:currentRequestId]) {
                            
                            for (EVSResponseItemModel *payloadItem in newModel.iflyos_responses) {
                                [self.queue addObject:payloadItem];
                            }
                            [self excute];//开始执行

                        }
                    }
                }else{
                    [self excuteNotMaunalResponse:newModel];
                }
            }
        }
    });
}

//处理非maunl的请求
-(void) excuteNotMaunalResponse:(EVSResponseModel *) newModel{
    //同步时间和音量
    NSMutableArray *excuteQueue = [[NSMutableArray alloc] init];
    for (EVSResponseItemModel *payloadItem in newModel.iflyos_responses) {
        //特殊处理,立即执行的指令
        if ([payloadItem.header.name isEqualToString:speaker_set_volume]) {
            EVSLog(@"****************** speaker.set_volume ******************");
            float volume = payloadItem.payload.volume;
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:volume];
            NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
            [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(volume)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            [[EVSApplication shareInstance] setVolume:volume];
        }else if ([payloadItem.header.name isEqualToString:system_ping]) {
            EVSLog(@"****************** system_ping ******************");
            long timestamp = payloadItem.payload.timestamp;
            NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
            [[EVSSqliteManager shareInstance] update:@{@"timestamp":@(timestamp)} device_id:deviceId tableName:SYSTEM_TABLE_NAME];
        }else if ([payloadItem.header.name isEqualToString:system_error]) {
            EVSLog(@"****************** system.error ******************");
            if (payloadItem.payload.code == 401) {
                //无效token
                [[EVSFocusManager shareInstance] authError];
                [[EvsSDKForiOS shareInstance] restoreEVS];
            }
            [[EVSWebscoketManager shareInstance] sendStr:COMMAND_END];
        }else if ([payloadItem.header.name isEqualToString:system_revoke_authorization]) {
            EVSLog(@"****************** system.revoke_authorization ******************");
            [[EVSWebscoketManager shareInstance] sendStr:COMMAND_END];
            [[EVSFocusManager shareInstance] authError];
            [[EvsSDKForiOS shareInstance] restoreEVS];
        }else{
            //非立即执行的指令判断播放方式
            //资源播放方式
            if ([payloadItem.payload.behavior isEqualToString:@"SERIAL"]) {
                //串行播放（阻塞指令,串行TTS 会阻塞其他指令，内容通道音量变为20%）
                [self.output stopTTS];
                [self.audioOutputQueue clearTTSChannelQueue];
                [excuteQueue addObject:payloadItem];
            }else if ([payloadItem.payload.behavior isEqualToString:@"PARALLEL"]) {
                //并行播放（非阻塞指令,并行TTS 不阻塞其他指令,直接执行）
                //执行音频指令
                AudioOutputModel *model = [[AudioOutputModel alloc] init];
                model.command_id = payloadItem.header.command_id;
                model.offset = payloadItem.payload.offset;
                model.resource_id = payloadItem.payload.resource_id;
                model.url = payloadItem.payload.url;
                model.type = payloadItem.payload.type;
                model.behavior = payloadItem.payload.behavior;
                model.isResumeContextChannel = payloadItem.payload.isResumeContextChannel;
                model.metadata.text = payloadItem.payload.metadata.text;
                model.metadata.title = payloadItem.payload.metadata.title;
                model.metadata.album = payloadItem.payload.metadata.album;
                model.metadata.duration = payloadItem.payload.metadata.duration;
                [self.audioOutputQueue addTTSChannelQueue:model];//直接执行，不进入指令队列，不会阻塞其他指令
            }else{
                //其他
                [excuteQueue addObject:payloadItem];
            }
            //判断是否特殊处理
            if (excuteQueue) {
                EVSResponseItemModel *currentPayloadItem = self.queue.firstObject ;
                //服务端推送过来的（没request_id或auto开头的）
                for (EVSResponseItemModel *payloadItem in excuteQueue) {
                    [self.queue addObject:payloadItem];
                }
                if (!currentPayloadItem || ![currentPayloadItem.payload.behavior isEqualToString:@"SERIAL"]) {
                    [self excute];//开始执行
                }
            }
        }
    }
}

//根据command_id移除请求队列
-(void) removeQueue:(EVSResponseItemModel *) responseModel{
    @synchronized (self) {
        
            [self.queue removeObject:responseModel];
        
    }
}

//根据id移除指令
-(void) removeQueueWithId:(NSString *) commandId{
    @synchronized (self) {
        NSMutableArray *tmpQueue = [self.queue mutableCopy];
        for (EVSResponseItemModel *item in self.queue) {
            if ([item.header.command_id isEqualToString:commandId]) {
                //
                [tmpQueue removeObject:item];
            }
        }
        self.queue = tmpQueue;
    }
}

//清理请求队列
-(void) clearQueueAndCommandQueue{
     @synchronized (self) {
         
             //    [self.output stop];
             //    [self.output stopTTS];
             [self.queue removeAllObjects];
             //    [self.audioOutputQueue clearAudioQueue];
             //    [self.audioOutputQueue clearUpcomingQueue];
             //    [self.audioOutputQueue clearTTSChannelQueue];
       
     }
}

/**********************************指令处理****************************************/
-(void) excute{
    EVSResponseItemModel *payloadItem = self.queue.firstObject;
    if (payloadItem) {
        //判断是否还有指令
        [self excuteCommand:payloadItem];
    }
}


//执行指令（需要判断是否阻塞）
-(void) excuteCommand:(EVSResponseItemModel *) payloadItem{
    @synchronized (self) {
        dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            if (payloadItem) {
                //判断是否音频资源指令audio_player.audio_out（PLAYBACK & TTS & RING）
                if([payloadItem.header.name containsString:@"audio_player"] &&
                   ([payloadItem.payload.type isEqualToString:@"PLAYBACK"] ||
                    [payloadItem.payload.type isEqualToString:@"TTS"] ||
                    [payloadItem.payload.type isEqualToString:@"RING"]) &&
                   payloadItem.payload.resource_id &&
                   payloadItem.payload.url){
                    
                    //执行音频指令
                    AudioOutputModel *model = [[AudioOutputModel alloc] init];
                    model.command_id = payloadItem.header.command_id;
                    model.offset = payloadItem.payload.offset;
                    model.resource_id = payloadItem.payload.resource_id;
                    model.url = payloadItem.payload.url;
                    model.type = payloadItem.payload.type;
                    model.behavior = payloadItem.payload.behavior;
                    model.isResumeContextChannel = payloadItem.payload.isResumeContextChannel;
                    model.metadata.text = payloadItem.payload.metadata.text;
                    model.metadata.title = payloadItem.payload.metadata.title;
                    model.metadata.album = payloadItem.payload.metadata.album;
                    model.metadata.duration = payloadItem.payload.metadata.duration;
                    
                    //播放通道
                    if ([payloadItem.payload.type isEqualToString:@"PLAYBACK"]) {
                        model.focusStatus = context_channel;
                        model.focusLevel = 50;
                    }else if ([payloadItem.payload.type isEqualToString:@"TTS"]) {
                        model.focusStatus = tts_channel;
                        model.focusLevel = 10;
                    }
                    
                    //资源播放方式
                    if ([payloadItem.payload.behavior isEqualToString:@"UPCOMING"]) {
                        //延后播放（UPCOMING,再次收到时就清理之前队列的内容）
                        [[AudioOutputQueue shareInstance] clearUpcomingQueue];
                        [[AudioOutputQueue shareInstance] addAudioUpcomingQueue:model];
                        //移除指令
                        [self removeQueue:payloadItem];
                        //执行完一条继续执行下一条
                        [self excute];
                    }else if ([payloadItem.payload.type isEqualToString:@"TTS"] && [payloadItem.payload.behavior isEqualToString:@"SERIAL"]) {
                        //串行播放（阻塞指令,串行TTS 会阻塞其他指令，内容通道音量变为20%）
                        [self.output stopTTS];
                        [[AudioOutputQueue shareInstance] clearTTSChannelQueue];
                        [[AudioOutputQueue shareInstance] addTTSChannelQueue:model];
                    }else if ([payloadItem.payload.type isEqualToString:@"TTS"] && [payloadItem.payload.behavior isEqualToString:@"PARALLEL"]) {
                        //并行播放（非阻塞指令,并行TTS 不阻塞其他指令）
                        //执行音频指令
                        AudioOutputModel *model = [[AudioOutputModel alloc] init];
                        model.command_id = payloadItem.header.command_id;
                        model.offset = payloadItem.payload.offset;
                        model.resource_id = payloadItem.payload.resource_id;
                        model.url = payloadItem.payload.url;
                        model.type = payloadItem.payload.type;
                        model.behavior = payloadItem.payload.behavior;
                        model.isResumeContextChannel = payloadItem.payload.isResumeContextChannel;
                        model.metadata.text = payloadItem.payload.metadata.text;
                        model.metadata.title = payloadItem.payload.metadata.title;
                        model.metadata.album = payloadItem.payload.metadata.album;
                        model.metadata.duration = payloadItem.payload.metadata.duration;
                        [self.audioOutputQueue addTTSChannelQueue:model];//直接执行，不进入指令队列，不会阻塞其他指令
                        //移除指令
                        [self removeQueue:payloadItem];
                        //执行完一条继续执行下一条
                        [self excute];
                    }else{
                        //立刻播放（IMMEDIATELY）
                        [self.output stop];
                        [[AudioOutputQueue shareInstance] clearAudioQueue];
                        [[AudioOutputQueue shareInstance] addAudioQueue:model];
                        //移除指令
                        [self removeQueue:payloadItem];
                        //执行完一条继续执行下一条
                        [self excute];
                    }
                }else{
                    //执行非音频指令
                    if ([payloadItem.header.name isEqualToString:recognizer_stop_capture]) {
                        //结束录音
                        EVSLog(@"****************** recognizer.stop_capture ******************");
                        [[EVSWebscoketManager shareInstance] sendStr:COMMAND_END];
                        //移除指令
                        [self removeQueue:payloadItem];
                        [[AudioInput sharedAudioManager] stop];
                    }else if ([payloadItem.header.name isEqualToString:audio_player_audio_out]) {
                        EVSLog(@"****************** audio_player.audio_out ******************");
                        if ([payloadItem.payload.type isEqualToString:@"PLAYBACK"]){
                            //操作
                            NSString *control = payloadItem.payload.control;//播放，暂停，继续播放
                            if (control){
                                NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
                                NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                                if ([control isEqualToString:@"PAUSE"]) {
                                    //暂停
                                    [self.output pause];
                                    [audioOutDict setObject:playback_state_paused forKey:@"playback_state"];
                                    [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                                    NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
                                    if (contextDict) {
                                        AudioOutputModel *model = [[AudioOutputModel alloc] init];
                                        model.type = @"PLAYBACK";
                                        model.resource_id = contextDict[@"playback_resource_id"];
                                        id offsetObj = contextDict[@"playback_offset"];
                                        model.offset = [offsetObj longValue];
                                        [[AudioOutputQueue shareInstance] playbackOrTTSSync:model type:@"PAUSED"];
                                    }
                                }else if ([control isEqualToString:@"RESUME"]) {
                                    //继续
                                    
                                }
                            }
                        }
                    }else if ([payloadItem.header.name isEqualToString:speaker_set_volume]) {
                        EVSLog(@"****************** speaker.set_volume ******************");
                        float volume = payloadItem.payload.volume;
                        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:volume];
                        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                        [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(volume)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                        [[EVSApplication shareInstance] setVolume:volume];
                    }else if ([payloadItem.header.name isEqualToString:system_ping]) {
                        EVSLog(@"****************** system_ping ******************");
                        long timestamp = payloadItem.payload.timestamp;
                        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
                        [[EVSSqliteManager shareInstance] update:@{@"timestamp":@(timestamp)} device_id:deviceId tableName:SYSTEM_TABLE_NAME];
                    }else if ([payloadItem.header.name isEqualToString:system_error]) {
                        EVSLog(@"****************** system.error ******************");
                        if (payloadItem.payload.code == 401) {
                            //无效token
                            [[EVSFocusManager shareInstance] authError];
                            [[EvsSDKForiOS shareInstance] restoreEVS];
                        }
                        [[EVSWebscoketManager shareInstance] sendStr:COMMAND_END];
                    }else if ([payloadItem.header.name isEqualToString:recognizer_intermediate_text]) {
                        EVSLog(@"****************** recognizer.intermediate_text ******************");
                        
                    }else if ([payloadItem.header.name isEqualToString:system_revoke_authorization]) {
                        EVSLog(@"****************** system.revoke_authorization ******************");
                        [[EVSWebscoketManager shareInstance] sendStr:COMMAND_END];
                        [[EVSFocusManager shareInstance] authError];
                        [[EvsSDKForiOS shareInstance] restoreEVS];
                    }else if ([payloadItem.header.name containsString:recognizer_expect_reply]) {
                        EVSLog(@"****************** recognizer.expect_reply ******************");
                        //追问指令，唤醒操作
                        NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
                        if (deviceId && payloadItem.payload.reply_key) {
                            [[EVSSqliteManager shareInstance] update:@{@"reply_key":payloadItem.payload.reply_key} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                            NSString *reply_key = payloadItem.payload.reply_key;
                            if (reply_key && ![reply_key isEqualToString:@""]) {
                                [[EvsSDKForiOS shareInstance] tap];
                            }
                        }
                    }
                    //移除指令
                    [self removeQueue:payloadItem];
                    //执行完一条继续执行下一条
                    [self excute];
                }
            }
        });
    }
}


//内容通道
//useModel : 正在处理的model
- (void)contextChannelFinish:(nonnull NSArray *)queue useModel:(nonnull AudioOutputModel *)model {
    EVSLog(@"context channel finish command id : %@",model.command_id);
    if (model.command_id) {
        //根据command_id移除指令
        [self removeQueueWithId:model.command_id];
        //执行完一条继续执行下一条
        EVSResponseItemModel *currentPayloadItem = self.queue.firstObject;
        if (currentPayloadItem && ![currentPayloadItem.payload.behavior isEqualToString:@"SERIAL"]) {
            //判断现在的指令是否阻塞
            [self excute];
        }
    }
    if (self.queue.count == 0) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:IDLE];
        NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
        if (deviceId) {
            [[EVSSqliteManager shareInstance] update:@{@"session_status":@"IDLE"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        }
    }
}

- (void)contextChannelStart:(nonnull NSArray *)queue useModel:(nonnull AudioOutputModel *)model {
    EVSLog(@"context channel start command id : %@",model.command_id);
}

//tts通道
//useModel : 正在处理的model
- (void)ttsChannelFinish:(nonnull NSArray *)queue useModel:(nonnull AudioOutputModel *)model {
    EVSLog(@"TTS channel finish command id : %@",model.command_id);
    if (model.command_id) {
        //根据command_id移除指令
        [self removeQueueWithId:model.command_id];
        //执行完一条继续执行下一条
        EVSResponseItemModel *currentPayloadItem = self.queue.firstObject;
        if (currentPayloadItem && ![currentPayloadItem.payload.behavior isEqualToString:@"SERIAL"]) {
            //判断现在的指令是否阻塞
            [self excute];
        }
    }
    if (self.queue.count == 0) {
        NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
        if (deviceId) {
            [[EVSSqliteManager shareInstance] update:@{@"session_status":@"IDLE"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        }
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:IDLE];
    }
}

- (void)ttsChannelStart:(nonnull NSArray *)queue useModel:(nonnull AudioOutputModel *)model {
    EVSLog(@"context channel start command id : %@",model.command_id);
}

@end
