//
//  AudioOutputQueue.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "AudioOutputQueue.h"
#import "AudioOutput.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"

#define dispatch_key "audiooutput_queue_dispatch"
@interface AudioOutputQueue()<AudioOutputDelegate>
@property(nonatomic,strong) NSMutableArray *ttsQueue;//TTS播放队列（串行/并行）

@property(nonatomic,strong) NSMutableArray *queue;//立刻播放的队列
@property(nonatomic,strong) NSMutableArray *upComingQueue;//即将播放的队列
@property(nonatomic,strong) AudioOutput *audioOutput;
@end

@implementation AudioOutputQueue

-(id) init{
    if (self == [super init]) {
        self.audioOutput.delegate = self;
    }
    return self;
}

-(AudioOutput *) audioOutput{
    if (!_audioOutput) {
        _audioOutput = [AudioOutput shareInstance];
    }
    return _audioOutput;
}

-(NSMutableArray *) queue{
    if (!_queue) {
        _queue = [[NSMutableArray alloc] init];
    }
    return _queue;
}

-(NSMutableArray *) ttsQueue{
    if (!_ttsQueue) {
        _ttsQueue = [[NSMutableArray alloc] init];
    }
    return _ttsQueue;
}

-(NSMutableArray *) upComingQueue{
    if (!_upComingQueue) {
        _upComingQueue = [[NSMutableArray alloc] init];
    }
    return _upComingQueue;
}

/**
 *  单例
 */
+(instancetype) shareInstance{
    static AudioOutputQueue *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

/**
 *  播放当前队列
 */
-(void) playQueue{
    @synchronized (self) {
        AudioOutputModel *model = self.queue.firstObject;
        if (model){
            [self playNext:model];
        }
    }
//    [self playFirst];
}

/**
 *  播放TTS队列
 */
-(void) playTTSQueue{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        AudioOutputModel *model = self.ttsQueue.firstObject;
        if (model){
            [self playNext:model];
        }
    });
}

/**
 *  加入TTS播放队列
 */
-(void) addTTSChannelQueue:(AudioOutputModel *) model{
    @synchronized (self) {
            if (model) {
                AudioOutputModel *oldModel = self.ttsQueue.firstObject;
                if (oldModel) {
                    [self.ttsQueue addObject:model];
                }else{
                    [self.ttsQueue addObject:model];
                    [self playTTSQueue];
                }
            }
    }
}

/**
 *  移除TTS队列
 */
-(void) removeTTSChannelQueue:(AudioOutputModel *) model{
    @synchronized (self) {
        
            [self.ttsQueue removeObject:model];
        
    }
}

/**
 *  清除TTS队列
 */
-(void) clearTTSChannelQueue{
    @synchronized (self) {
        
            [self.ttsQueue removeAllObjects];
        
    }
}

/**
 *  更新立刻播放队列
 */
-(void) updateAudioQueue:(AudioOutputModel *)newModel{
    @synchronized (self) {
        dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            if (self.queue) {
                NSMutableArray *tmpQueue = [[NSMutableArray alloc] init];
                for (AudioOutputModel *oldModel in self.queue) {
                    if ([oldModel.resource_id isEqualToString:newModel.resource_id]) {
                        oldModel.offset = newModel.offset;
                    }
                    [tmpQueue addObject:oldModel];
                }
                self.queue = tmpQueue;
            }
        });
    }
}

/**
 *  加入立刻播放队列
 */
-(void) addAudioQueue:(AudioOutputModel *) model{
    @synchronized (self) {
        //处理相关的响应
            [self process:model];
    }
}

/**
 *  加入即将播放队列
 */
-(void) addAudioUpcomingQueue:(AudioOutputModel *) model{
        @synchronized (self) {
            [self.upComingQueue addObject:model];
        }
}

/**
 *  移除即将播放队列
 */
-(void) clearUpcomingQueue{
    @synchronized (self) {
        [self.upComingQueue removeAllObjects];
    }
}

/**
 *  移出播放队列
 */
-(void) removeAudioQueue:(AudioOutputModel *)model{
    @synchronized (self) {
        NSMutableArray *tmpQueue = [self.queue mutableCopy];
        [tmpQueue removeObject:model];
        self.queue = tmpQueue;
    }
}

/**
 *  移出即将播放队列
 */
-(void) removeUpcomingQueue:(AudioOutputModel *)model{
    @synchronized (self) {
        NSMutableArray *tmpQueue = [self.upComingQueue mutableCopy];
        [tmpQueue removeObject:model];
        self.upComingQueue = tmpQueue;
    }
}

/**
 *  清除播放队列
 */
-(void) clearAudioQueue{
    @synchronized (self) {
        [self.queue removeAllObjects];
    }
}

/**
 *  按顺序播放
 */
-(void) playFirst{

        @synchronized (self) {
            AudioOutputModel *model = self.queue.firstObject;
            if (model){
                [self playNext:model];
            }
        }

}

/**
 *  处理音频播放顺序
 *  newModel : 新的响应资源
 */
-(void) process:(AudioOutputModel *) newModel{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        @synchronized (self) {
            AudioOutputModel *oldModel = self.queue.firstObject;
            if(oldModel){
                //如果有音频队列，则添加
                [self.queue addObject:newModel];
            }else{
                //空的插入，立即执行
                [self.queue addObject:newModel];
                [self playFirst];
            }
        }
    });
}

/**
 *  播放下一个
 */
-(void) playNext:(AudioOutputModel *)model{
        //判断播放的通道类型
    @synchronized (self) {
        if (model.focusStatus == context_channel){
            [self.audioOutput openURLWithContextChannel:model];
            if(model.offset > 0){
                [self.audioOutput play:model.offset];
            }
        }else if (model.focusStatus == tts_channel){
            [self.audioOutput openURLWithTTSChannel:model];
        }else{
            [self.audioOutput openURLWithSoundEffectsChannel:model];
        }
    }
}

#pragma ------------------------------------------------回调函数
/********************************************内容播放回调*************************************************/
-(void) audioOutputContextChannelStart:(AudioOutput *)audioOutput model:(AudioOutputModel *)model{
    EVSLog(@"audio output contextChannel start >>> %@ (%@<%@>)",model.resource_id,model.metadata.text,model.metadata.title);
    [self.delegate contextChannelStart:self.queue useModel:model];
    NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
    NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
    if (model.type) {
        [audioOutDict setObject:model.type forKey:@"playback_type"];
    }
    [audioOutDict setObject:playback_state_playing forKey:@"playback_state"];
    //存储数据库，然后同步到服务器
    if (model.resource_id) {
        [audioOutDict setObject:model.resource_id forKey:@"playback_resource_id"];
    }
    [audioOutDict setObject:@(model.offset) forKey:@"playback_offset"];
    [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
    //同步
    [self playbackOrTTSSync:model type:@"STARTED"];
    [self.delegate contextChannelStart:self.queue useModel:model];
}
-(void) audioOutputContextChannelFinish:(AudioOutput *)audioOutput model:(AudioOutputModel *)model{
    EVSLog(@"audio output contextChannel finish >>> %@ (%@<%@>)",model.resource_id,model.metadata.text,model.metadata.title);
    
    [self removeAudioQueue:model];//播放完毕就移除
    [self removeUpcomingQueue:model];//移除即将播放列表
    
    //存储数据库，然后同步到服务器
    NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
    NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
    [audioOutDict setObject:playback_state_paused forKey:@"playback_state"];
    [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
    
    AudioOutputModel *nextModel = self.queue.firstObject;
    if (nextModel) {
        //如果有下一个，则开始播放
        [self playNext:nextModel];
    }else{
        //如果没有下一个，检查即将播放队列是否有播放
        AudioOutputModel *upComingModel = self.upComingQueue.firstObject;
        if (upComingModel) {
            self.queue = [self.upComingQueue mutableCopy];
            [self clearUpcomingQueue];
            [self playQueue];
        }
    }
    if (self.queue.count == 0) {
        [self.audioOutput stop];
        [audioOutDict setObject:playback_state_idle forKey:@"playback_state"];
        [audioOutDict setObject:@"" forKey:@"playback_resource_id"];
        [audioOutDict setObject:@(0) forKey:@"playback_offset"];
        [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
        if (deviceId) {
            [[EVSSqliteManager shareInstance] update:@{@"session_status":@"FINISHED"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        }
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:FINISHED];
    }
    
    //播放下一个
    [self playbackOrTTSSync:model type:@"FINISHED"];
    [self.delegate contextChannelFinish:self.queue useModel:model];
}

/********************************************TTS播放回调*************************************************/
-(void) audioOutputTTSChannelStart:(AudioOutput *)audioOutput model:(AudioOutputModel *)model{
    EVSLog(@"audio output TTSChannel start >>> %@ (%@<%@>)",model.resource_id,model.metadata.text,model.metadata.title);
    if(model.focusLevel >= 100){
        //太大就不管（不抢焦点）
        return;
    }
    if (model.focusStatus == tts_channel) {
        if (model &&
            [model.type isEqualToString:@"TTS"] &&
            [model.behavior isEqualToString:@"SERIAL"]) {
            //串行

        }else if (model &&
                  [model.type isEqualToString:@"TTS"] &&
                  [model.behavior isEqualToString:@"PARALLEL"]){
            
        }
    }
    //前景声音 20%
    [self.audioOutput setBackgroundVolume20Percent];
    
    //同步
    [self playbackOrTTSSync:model type:@"STARTED"];
    [self.delegate ttsChannelStart:self.ttsQueue useModel:model];
}

-(void) audioOutputTTSChannelFinish:(AudioOutput *)audioOutput model:(AudioOutputModel *)model{
    EVSLog(@"audio output TTSChannel finish >>> %@ (%@<%@>)",model.resource_id,model.metadata.text,model.metadata.title);
    if(model.focusLevel >= 100){
        //太大就不管（不抢焦点）
        return;
    }
    if (model.focusStatus == tts_channel) {
        if (model &&
            [model.type isEqualToString:@"TTS"] &&
            [model.behavior isEqualToString:@"SERIAL"]) {
            //串行
        }else if (model &&
                  [model.type isEqualToString:@"TTS"] &&
                  [model.behavior isEqualToString:@"PARALLEL"]){
            
        }
        //声音 恢复
        [self.audioOutput resumeBackgroundVolume];
    }
    //播放下一个
    //同步
    [self removeTTSChannelQueue:model];
    [self playbackOrTTSSync:model type:@"FINISHED"];
    [self.delegate ttsChannelFinish:self.ttsQueue useModel:model];
}

/********************************************音效播放回调*************************************************/
- (void)audioOutputSoundEffectChannelFinish:(nonnull AudioOutput *)audioOutput model:(nonnull AudioOutputModel *)model {
    
}


- (void)audioOutputSoundEffectChannelStart:(nonnull AudioOutput *)audioOutput model:(nonnull AudioOutputModel *)model {
    
}

/**
 *  播放器同步
 *  STARTED:播放开始播放的时候，发送此类型并告知 resource_id，手机端可获得播放内容信息
 *  FAILED:播放失败的时候，发送此类型并告知播放失败的 resource_id，云端会下发其他内容
 *  NEARLY_FINISHED:音频播放即将结束，一般取内容的1/3的时间长度 或 结束前10秒或播放后30秒（不是必传）
 *  FINISHED:播放结束时候发送此类型，发送此类型并告知 resource_id
 *  PAUSED:正在播放的内容被暂停时（被用户按键暂停，或收到了云端下发的PAUSE类型的audio_player.audio.out的response），发送此类型并告知resource_id
 */
-(void) playbackOrTTSSync:(AudioOutputModel *)model type:(NSString *)type{
    dispatch_queue_t queue =  dispatch_queue_create("audio_player.playback.progress_sync", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if ([model.type isEqualToString:@"PLAYBACK"]) {
            //同步服务器
            EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
            progressSync.iflyos_request.payload.type = type;
            progressSync.iflyos_request.payload.resource_id = model.resource_id;
            progressSync.iflyos_request.payload.offset = model.offset;
            NSDictionary *progressSyncDict = [progressSync getJSON];
            [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
        }else if([model.type isEqualToString:@"TTS"]){
            EVSAudioPlayerTTSProgressSync *ttsProgressSync = [[EVSAudioPlayerTTSProgressSync alloc] init];
            ttsProgressSync.iflyos_request.payload.type = type;
            ttsProgressSync.iflyos_request.payload.resource_id = model.resource_id;
            NSDictionary *ttsProgressSyncDict = [ttsProgressSync getJSON];
            [[EVSWebscoketManager shareInstance] sendDict:ttsProgressSyncDict];
        }
    });
}

@end
