//
//  AudioOutput.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/26.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "AudioOutput.h"

#import "EVSHeader.h"
#import "EVSRequestHeader.h"

#define dispatch_key "audioOutput_dispatch"
@interface AudioOutput()<AVAudioPlayerDelegate>
@property (nonatomic ,strong)  id timeObser;

//监听进度
@property (nonatomic,strong) NSTimer *timer;

//是否重复提交NEARLY_FINISHED
@property (assign,atomic) BOOL nearlyFinishedSended;
@end

@implementation AudioOutput
/**
 *  单例
 */
+(instancetype) shareInstance{
    static AudioOutput *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

-(id) init{
    if (self == [super init]) {
        //开启音频会话
        [AudioSessionManager setOnlyRecord];
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        //应用开启远程控制后,才会自动切歌,既可以实现后台运行 & 支持线控
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //注册打断通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptHandleAction:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

//播放打断事件处理
- (void)interruptHandleAction:(NSNotification *)noti {
    int type = [noti.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan:  //被打断
            [[EvsSDKForiOS shareInstance] pause];
            //取消选中状态
            EVSLog(@"前景被打断");
            break;
        case AVAudioSessionInterruptionTypeEnded: //结束打断
//            if (self.player) {
//                [self.player play];
//            }
            //设置为选中状态
            EVSLog(@"前景结束打断");
        default:
            break;
    }
}

/**
 *  播放本地资源（在音效通道播放）
 */
-(void) openURLWithSoundEffectsChannel:(AudioOutputModel *) model{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
   
     dispatch_async(queue, ^{
        if (model) {
            NSString *path = [[NSBundle mainBundle] pathForResource:model.localFileName ofType:model.localFileType];
            if (path) {
                NSURL *url = [NSURL fileURLWithPath:path];
                if (url) {
                    EVSLog(@"play SoundEffects Channel >>> %@.%@",model.localFileName,model.localFileType);
                    //开始播放
                    NSError *error;
                    self.soundEffectsPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
                    [self.soundEffectsPlayer prepareToPlay];
                    [self.soundEffectsPlayer play];
                    
                    if (error) {
                        EVSLog(@"[*] audio player error : %@",error);
                        [EVSSystemManager exception:@"audio_output" code:@"1001" message:[NSString stringWithFormat:@"audio_output player error:%@",error.localizedDescription]];
                        [self syncAudioError:@"1001"];
                    }else{
                        [self.delegate audioOutputSoundEffectChannelStart:self model:model];
                    }
                }
            }
        }
    });
}
/**
 *  播放网络资源（在内容通道播放）
 */
-(void) openURLWithContextChannel:(AudioOutputModel *) model{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self clearContextChannel];
        self.nearlyFinishedSended = NO;
        if (model) {
            self.contextModel = model;

            if (model.url) {
                NSURL *urlObj = [NSURL URLWithString:model.url];
                if (urlObj){
                    //开始播放
                    NSTimeInterval offset = (self.contextModel.offset / TIME_ZOOM);
                    [self openContextPlayer:urlObj];
                    self.player.volume = self.currentVolume;
                    [self.player seekToTime:CMTimeMake(offset, 1)];
                     [self.player play];
                }else{
                    //没找到音频文件
                    [self syncAudioError:@"1003"];
                    [EVSSystemManager exception:@"audio_output" code:@"1003" message:[NSString stringWithFormat:@"audio_output player url:%@ undefine",model.url]];
                }
            }else{
                //没找到音频文件
                [self syncAudioError:@"1003"];
                [EVSSystemManager exception:@"audio_output" code:@"1003" message:[NSString stringWithFormat:@"audio_output player url:%@ undefine",model.url]];
            }
        }
    });
}
/**
 *  播放网络资源（在TTS通道播放，分阻塞和非阻塞）
 */
-(void) openURLWithTTSChannel:(AudioOutputModel *) model{
    if (model) {
        dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(queue, ^{
            [self clearTTSChannel];
            self.ttsModel = model;
            NSURL *urlObj = [NSURL URLWithString:model.url];
            if (urlObj) {
                [self openTTSPlayer:urlObj];
                self.ttsChannelPlayer.volume = self.currentTTSVolume;
                [self.ttsChannelPlayer play];
            }
        });
    }
}

-(void) openTTSPlayer:(NSURL *) url{
    AVAsset*liveAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem*playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    self.ttsChannelPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    [self.ttsChannelPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:@"tts.player"];
    [self.ttsChannelPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:@"tts.player"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttsPlayFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.ttsChannelPlayer.currentItem];
}

-(void) openContextPlayer:(NSURL *) url{
    AVAsset*liveAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem*playerItem = [AVPlayerItem playerItemWithAsset:liveAsset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
//    if([[url.absoluteString pathExtension] isEqualToString:@"m3u8"] || [[url.absoluteString pathExtension] isEqualToString:@"M3U8"]){
//        self.player.automaticallyWaitsToMinimizeStalling = YES;
//    }else{
//        self.player.automaticallyWaitsToMinimizeStalling = NO;
//    }
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:@"context.player"];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:@"context.player"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextPlayFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    
    self.timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 10.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time) * TIME_ZOOM;
        //总时间
        float total = CMTimeGetSeconds(playerItem.duration) * TIME_ZOOM;
        
        //同步播放状态
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
        [audioOutDict setObject:@(current) forKey:@"playback_offset"];
        [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        
        if (current && !isnan(total)) {
            float progress = current / total;
            //更新播放进度条
            if (!isnan(progress)) {
//                EVSLog(@"--context player 1 >>> %.2f / %.2f = (%.2f)",(float)current,(float)total,progress * 100);
                long lastTime = (total - current) / TIME_ZOOM;
                if (lastTime == 10) {
                    if ([self.contextModel.type isEqualToString:@"PLAYBACK"] && !self.nearlyFinishedSended) {
                        //同步服务器(NEARLY_FINISHED，即将播放完)
                        EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
                        progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
                        progressSync.iflyos_request.payload.resource_id = self.contextModel.resource_id;
                        progressSync.iflyos_request.payload.offset = self.contextModel.offset;
                        NSDictionary *progressSyncDict = [progressSync getJSON];
                        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
                        self.nearlyFinishedSended = YES;
                    }
                }
                //最后播放的时间
                [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] progress:progress * 100];
            }
        }else{
            long lastTime = current / TIME_ZOOM;
            if (lastTime == 10) {
                if ([self.contextModel.type isEqualToString:@"PLAYBACK"] && !self.nearlyFinishedSended) {
                    //同步服务器(NEARLY_FINISHED，即将播放完)
                    EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
                    progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
                    progressSync.iflyos_request.payload.resource_id = self.contextModel.resource_id;
                    progressSync.iflyos_request.payload.offset = self.contextModel.offset;
                    NSDictionary *progressSyncDict = [progressSync getJSON];
                    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
                    self.nearlyFinishedSended = YES;
                }
            }
//            EVSLog(@"--context player current time >>> %.2f / %.2f",(float)current,(float)total);
        }
    }];
 
}

-(void) contextPlayFinished:(NSNotification *) notification{
    EVSLog(@"context channel audio player [%@] finish...",self.contextModel.url);
    [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
}
//清除播放器通道
-(void) clearContextChannel{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player removeTimeObserver:self.timeObser];
    self.player = nil;
    self.contextModel = nil;
}

-(void) ttsPlayFinished:(NSNotification *) notification{
    EVSLog(@"TTS channel audio player [%@] finish...",self.contextModel.url);
    [self.delegate audioOutputTTSChannelFinish:self model:self.ttsModel];
}

-(void) clearTTSChannel{
    [self.ttsChannelPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [self.ttsChannelPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.ttsChannelPlayer.currentItem];
    self.ttsChannelPlayer = nil;
    self.ttsModel = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSString *playerName = (__bridge NSString *)(context);
    if ([keyPath isEqualToString:@"loadedTimeRanges"] && [playerName isEqualToString:@"context.player"]) {
        
        NSArray * timeRanges = self.player.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.player.currentItem.duration);
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
       
    }
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusUnknown:
            {
                
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
                if (deviceId) {
                    [[EVSSqliteManager shareInstance] update:@{@"session_status":@"SPEAKING"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                }
               [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:SPEAKING];
                if ([playerName isEqualToString:@"context.player"]) {
                    [self.delegate audioOutputContextChannelStart:self model:self.contextModel];
                }else if([playerName isEqualToString:@"tts.player"]){
                    [self.delegate audioOutputTTSChannelStart:self model:self.ttsModel];
                }
            }
                break;
            case AVPlayerStatusFailed:
            {
                EVSLog(@"[*] audio player %@ error loading fail...",playerName);
                [EVSSystemManager exception:@"audio_output" code:@"1001" message:[NSString stringWithFormat:@"audio_output player %@ error loading fail",playerName]];
                [self syncAudioError:@"1001"];
            }
                break;
                
            default:
                break;
        }
        
    }
}


#pragma -----------------------------------------------操作
//背景声音设置20%
-(void) setBackgroundVolume20Percent{
    //前景声音 20%
    [self setVolume:0.2];
}

//背景声音设置2%
-(void) setBackgroundVolume2Percent{
    //前景声音 20%
    [self setVolume:0.02];
}
//背景音乐恢复
-(void) resumeBackgroundVolume{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    NSDictionary *dict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
    if (dict){
        id vObj = dict[@"speaker_volume"];
        if (vObj) {
            float volume = [vObj floatValue];
            [[EVSApplication shareInstance] setVolume:volume];
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:volume];
        }else{
            [[AudioOutput shareInstance] setTTSVolume:20/100.0];
            NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
            [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(20)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:20];
        }
    }
}
//停止
-(void) stop{
    [self.player pause];
    [self.player removeTimeObserver:self.timeObser];
    self.player = nil;
}

//停止（TTS播放器）
-(void) stopTTS{
    if (self.ttsChannelPlayer) {
        [self.ttsChannelPlayer pause];
        self.ttsChannelPlayer = nil;
    }
}

//暂停
-(void)pause {
    [self.timer invalidate];
    self.timer = nil;
    [self.player pause];
}

//恢复（根据时间播放）
-(void) play:(NSTimeInterval) time{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (self.player) {
            NSTimeInterval offset = (time / TIME_ZOOM);
            self.player.volume = self.currentVolume;
            [self.player seekToTime:CMTimeMake(offset, 1)];
            [self.player play];
            [self.delegate audioOutputContextChannelStart:self model:self.contextModel];
            
        }
    });
}

//恢复(本地播放器恢复)
-(void) resumeLocalPlay{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (self.player) {
            self.player.volume = self.currentVolume;
            [self.player play];
        }
    });
}

//恢复（只恢复声音）
-(void) resumeOnlyVolume{
    if (self.player) {
        self.player.volume = self.currentVolume;
    }
}
//设置音量(0~1)
-(void) setVolume:(float) volume{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (self.player) {
            self.player.volume = volume;
        }
        self.currentVolume = volume;
    });
}

//设置音量(0~1)
-(void) setTTSVolume:(float) volume{
    dispatch_queue_t queue =  dispatch_queue_create(dispatch_key, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (self.ttsChannelPlayer) {
            self.ttsChannelPlayer.volume = volume;
        }
        self.currentTTSVolume = volume;
    });
}

//同步播放器错误信息
-(void) syncAudioError:(NSString *) code{
    if ([self.contextModel.type isEqualToString:@"PLAYBACK"]) {
        //同步服务器
        EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
        progressSync.iflyos_request.payload.type = @"FAILED";
        progressSync.iflyos_request.payload.resource_id = self.contextModel.resource_id;
        progressSync.iflyos_request.payload.offset = self.contextModel.offset;
        progressSync.iflyos_request.payload.failure_code = code;
        NSDictionary *progressSyncDict = [progressSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
    }
}
////计算播放时间
//-(void) playerTimeAsyn{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            // 当前时间
//            long currentTime = self.player.currentTime * TIME_ZOOM;
//            // 总时间
//            long totalTime = self.player.duration * TIME_ZOOM;
//
//            //更新当前进度
//            self.currentProgress = currentTime;
//            self.contextModel.offset = currentTime;
////            [[AudioOutputQueue shareInstance] updateAudioQueue:self.contextModel];
//
//            //同步播放状态
//            NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
//            NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
//            [audioOutDict setObject:@(currentTime) forKey:@"playback_offset"];
//            [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
//
//            // 计算进度
//            float progress = (float)currentTime / (float)totalTime;
////            NSLog(@"%.2f / %.2f = (%.2f)",(float)currentTime,(float)totalTime,progress * 100);
//            //最后播放的时间
//            long lastTime = (totalTime - currentTime) / TIME_ZOOM;
//            if (lastTime == 10) {
//                if ([self.contextModel.type isEqualToString:@"PLAYBACK"] && !self.nearlyFinishedSended) {
//                    //同步服务器(NEARLY_FINISHED，即将播放完)
//                    EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
//                    progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
//                    progressSync.iflyos_request.payload.resource_id = self.contextModel.resource_id;
//                    progressSync.iflyos_request.payload.offset = self.contextModel.offset;
//                    NSDictionary *progressSyncDict = [progressSync getJSON];
//                    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
//                    self.nearlyFinishedSended = YES;
//                }
//            }
//        }];
//    });
//}

#pragma 回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(flag){
        if (player == self.player && self.contextModel){
            [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
            self.contextModel = nil;
            self.player = nil;
        }
        if (player == self.ttsChannelPlayer && self.ttsModel) {
            [self.delegate audioOutputTTSChannelFinish:self model:self.ttsModel];
            self.ttsModel = nil;
            self.ttsChannelPlayer = nil;
        }
        if (player == self.soundEffectsPlayer && self.soundModel) {
            [self.delegate audioOutputSoundEffectChannelFinish:self model:self.soundModel];
            self.soundModel = nil;
            self.soundEffectsPlayer = nil;
        }
    }
}
@end
