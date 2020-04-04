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
#import "EVSVideoPlayerManager.h"
#define dispatch_key "audioOutput_dispatch"
@interface AudioOutput()<AVAudioPlayerDelegate,STKAudioPlayerDelegate>
@property (nonatomic ,strong)  id timeObser;

//监听进度
@property (nonatomic,strong) NSTimer *timer;

//是否重复提交NEARLY_FINISHED
@property (assign,atomic) BOOL nearlyFinishedSended;

//重试次数
@property (assign,nonatomic) NSInteger retryCount;
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
        [AudioSessionManager setPlayBackAndRecord];
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        //应用开启远程控制后,才会自动切歌,既可以实现后台运行 & 支持线控
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        //注册打断通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptHandleAction:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

-(STKAudioPlayer *) ttsPlayer{
    STKAudioPlayerOptions options = {.enableVolumeMixer = YES};
    if (!_ttsPlayer) {
        _ttsPlayer = [[STKAudioPlayer alloc] initWithOptions:options];
        _ttsPlayer.delegate = self;
    }
    return _ttsPlayer;
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
}
/**
 *  播放网络资源（在内容通道播放）
 */
-(void) openURLWithContextChannel:(AudioOutputModel *) model{
        if([model.type isEqualToString:@"video"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clearContextChannel];
                self.nearlyFinishedSended = NO;
                 self.contextModel = model;
                //视频
                if ([[EVSVideoPlayerManager shareInstance].delegate respondsToSelector:@selector(open:offset:resource_id:)]) {
                    [[EVSVideoPlayerManager shareInstance].delegate open:model.url offset:model.offset resource_id:model.resource_id];
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clearContextChannel];
                self.nearlyFinishedSended = NO;
                if (model) {
                    self.contextModel = model;
                    [self.delegate audioOutputContextChannelStart:self model:self.contextModel];
                    if (model.url) {
                            NSURL *urlObj = [NSURL URLWithString:model.url];
                            if (urlObj){
                                NSTimeInterval offset = (self.contextModel.offset / TIME_ZOOM);
                                //开始播放
                                if([[model.url pathExtension] isEqualToString:@"wav"]){
                                    //wav格式转MP3
                                    EVSLog(@"play SoundEffects Channel >>> %@.%@",model.localFileName,model.localFileType);
                                    //开始播放
                                    
                                    NSURL *reqUrlObj = [NSURL URLWithString:model.url];
                                    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:reqUrlObj];
                                    NSData *reqData = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
                                    NSString *fileName = [model.url lastPathComponent];
                                    
                                    BOOL isSave = [reqData saveAudioFile:fileName];
                                    if (isSave) {
                                        NSString *audioPath = [NSString getDocumentAudioPath];
                                        NSString *filePath = [NSString stringWithFormat:@"%@/%@.mp3", audioPath,[fileName stringByDeletingPathExtension]];
                                        
                                        NSURL *fileUrlObj = [NSURL fileURLWithPath:filePath];
                                        if (fileUrlObj){
                                            //开始播放
                                            [self createContextPlayer:fileUrlObj offset:offset];
                                        }else{
                                            //没找到音频文件
                                            [self syncAudioError:@"1003"];
                                            [EVSSystemManager exception:@"audio_output" code:@"1003" message:[NSString stringWithFormat:@"audio_output player url:%@ undefine",model.url]];
                                        }
                                    }else{
                                        [self syncAudioError:@"1003"];
                                        [EVSSystemManager exception:@"audio_output" code:@"1003" message:[NSString stringWithFormat:@"audio_output player url:%@ undefine",model.url]];
                                    }
                                }else{
                                    [self createContextPlayer:urlObj offset:offset];
                                }
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
}

-(void) createContextPlayer:(NSURL *)urlObj offset:(NSTimeInterval) offset{
//    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:urlObj];
        self.contextPlayer = [AVPlayer playerWithPlayerItem:item];
        self.contextPlayer.volume = self.currentVolume;
        [self.contextPlayer play];
        if (self.contextPlayer.currentItem) {
            [self.contextPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:@"context.player"];
            [self.contextPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:@"context.player"];
            if (offset > 0 ) {
                [self.contextPlayer.currentItem seekToTime:CMTimeMake(offset, 1) completionHandler:^(BOOL finished) {}];
            }
            [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.contextPlayer.currentItem queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
                [weakSelf contextPlayFinished:note];
            }];
        }

        [self startTimer];
//    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {

    NSString *playerName = (__bridge NSString *)(context);
    NSTimeInterval duration = 0 ;
    if ([keyPath isEqualToString:@"loadedTimeRanges"] && [playerName isEqualToString:@"context.player"]) {
        
        NSArray * timeRanges = self.contextPlayer.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        duration = CMTimeGetSeconds(self.contextPlayer.currentItem.duration);
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
        
        //回调进度
        NSLog(@"context.player::loadedTimeRanges:: buff size :%f",scale);
    }

    /*****************************华丽的分割线*************************************/
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.contextPlayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
            {
                if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:buffingFinish:)]) {
                    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] buffingFinish:NO];
                }
                NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
                 if (deviceId) {
                     [[EVSSqliteManager shareInstance] update:@{@"session_status":@"SPEAKING"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
                 }
                [[EVSApplication shareInstance] setEVSSessionState:SPEAKING];
                if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:sessionStatus:)]){
                    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:[EVSApplication shareInstance].sessionState];
                }
                
                if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:current:total:)] && !isnan(duration)) {
                    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] current:0 total:duration*TIME_ZOOM];
                }
                if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:progress:)]) {
                    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] progress:0];
                }
                       
                [self startTimer];
            }
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
}

/**
 *  播放网络资源（在TTS通道播放，分阻塞和非阻塞）
 */
-(void) openURLWithTTSChannel:(AudioOutputModel *) model{
    if (model) {
            [self clearTTSChannel];
            self.ttsModel = model;
            NSURL *urlObj = [NSURL URLWithString:model.url];
            if (urlObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ttsPlayer.volume = self.currentTTSVolume;
                    [self.ttsPlayer playURL:urlObj];
                });
            }
    }
}

-(void) contextPlayFinished:(NSNotification *) notification{
    EVSLog(@"context channel audio player [%@] finish...",self.contextModel.url);
    [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
}
//清除播放器通道
-(void) clearContextChannel{
    if(self.contextPlayer.currentItem){
        [self.contextPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [self.contextPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.contextPlayer.currentItem];
    }
    
    //    [self.player removeTimeObserver:self.timeObser];
        [self stopTimer];
    //    self.contextPlayer.delegate = n;
    //    self.contextPlayer = nil;
        self.contextModel = nil;
}

-(void) ttsPlayFinished:(NSNotification *) notification{
    EVSLog(@"TTS channel audio player [%@] finish...",self.contextModel.url);
    [self.delegate audioOutputTTSChannelFinish:self model:self.ttsModel];
}

-(void) clearTTSChannel{
    self.ttsPlayer.delegate = nil;
    self.ttsPlayer = nil;
    self.ttsModel = nil;
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
            if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:volume:)]){
                [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:volume];
            }
        }else{
            [[AudioOutput shareInstance] setTTSVolume:20/100.0];
            if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:volume:)]){
                [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] volume:20];
            }
        }
    }
}
//停止
-(void) stop{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.contextPlayer) {
            [self stopTimer];
            [self.contextPlayer pause];
            self.contextModel = nil;
        }
    });
    
}

//停止（TTS播放器）
-(void) stopTTS{
    if (self.ttsPlayer) {
        [self.ttsPlayer pause];
        self.ttsPlayer = nil;
    }
}

//暂停
-(void)pause {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        [self.contextPlayer pause];
    });
}

//本地回复
-(void) resume{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.contextPlayer && self.contextModel) {
            self.contextPlayer.volume = self.currentVolume;
            [self.contextPlayer play];
            [self startTimer];
        }
    });
}

//只是播放
-(void) onlyPlay{
//    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.contextPlayer && self.contextModel) {
            self.contextPlayer.volume = self.currentVolume;
            [self.contextPlayer pause];
            [NSThread sleepForTimeInterval:0.1];
            [self.contextPlayer play];
        }
//    });
}

//恢复(本地播放器恢复)
-(void) resumeLocalPlay{
     dispatch_async(dispatch_get_main_queue(), ^{
         if (self.contextPlayer) {
            self.contextPlayer.volume = self.currentVolume;
        }
     });
}

//恢复（只恢复声音）
-(void) resumeOnlyVolume{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.contextPlayer) {
            self.contextPlayer.volume = self.currentVolume;
        }
    });
}
//设置音量(0~1)
-(void) setVolume:(float) volume{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.contextPlayer){
            self.contextPlayer.volume = volume;
        }
        self.currentVolume = volume;
    });
}

//设置音量(0~1)
-(void) setTTSVolume:(float) volume{
        if (self.ttsPlayer) {
            self.ttsPlayer.volume = volume;
        }
        self.currentTTSVolume = volume;
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
-(void) updateProgress:(float)currentProgress{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentProgress = currentProgress;
        NSTimeInterval offset = CMTimeGetSeconds(self.contextPlayer.currentItem.duration) * currentProgress ;
        EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
        progressSync.iflyos_request.payload.type = playback_state_paused;
        progressSync.iflyos_request.payload.resource_id = self.contextModel.resource_id;
        progressSync.iflyos_request.payload.offset = offset * TIME_ZOOM;
        NSDictionary *progressSyncDict = [progressSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
        if (self.contextPlayer) {
                     [self.contextPlayer.currentItem seekToTime:CMTimeMake(offset, 1) completionHandler:^(BOOL finished) {}];
        }
    });
}

#pragma 回调
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(flag){
//        if (player == self.player && self.contextModel){
//            [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
//            self.contextModel = nil;
//            self.player = nil;
//        }
//        if (player == self.ttsChannelPlayer && self.ttsModel) {
//            [self.delegate audioOutputTTSChannelFinish:self model:self.ttsModel];
//            self.ttsModel = nil;
//            self.ttsChannelPlayer = nil;
//        }
        if (player == self.soundEffectsPlayer && self.soundModel) {
            [self.delegate audioOutputSoundEffectChannelFinish:self model:self.soundModel];
            self.soundModel = nil;
            self.soundEffectsPlayer = nil;
        }
    }
}

//视频回调
-(void) videoreadyToPlay{
    EVSLog(@"context channel video player [%@] playing...",self.contextModel.url);
    [self.delegate audioOutputContextChannelStart:self model:self.contextModel];
}
-(void) videoPlayEnd{
    EVSLog(@"context channel video player [%@] finish...",self.contextModel.url);
    [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
}

-(void) startTimer{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopTimer];
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf tick];
        }];
    });
}

-(void) stopTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


-(void) tick{
    if (!self.contextPlayer) {
        return;
    }
    
    //当前播放的时间
    float current = CMTimeGetSeconds(self.contextPlayer.currentItem.currentTime) * TIME_ZOOM;
    //总时间
    float total = CMTimeGetSeconds(self.contextPlayer.currentItem.duration) * TIME_ZOOM;
    //进度
    float progress = current / total ;
    
    //同步播放状态
    NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
    NSMutableDictionary *audioOutDict = [[NSMutableDictionary alloc] init];
    [audioOutDict setObject:@(current) forKey:@"playback_offset"];
    [[EVSSqliteManager shareInstance] update:audioOutDict device_id:deviceId tableName:CONTEXT_TABLE_NAME];
    
    if (isnan(total)) {
        long startTime = current / TIME_ZOOM;
        NSLog(@"开始：%li",startTime);
        if (startTime >= 10) {
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
    }else{
        long lastTime = (total - current) / TIME_ZOOM;
        NSLog(@"剩余：%li",lastTime);
        if (lastTime <= 10) {
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
    }
    
    //回调进度
    if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:current:total:)]) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] current:current total:total];
    }
    if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:progress:)]) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] progress:progress * 100];
    }
}

/*****************回调**************************/
/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{
    NSString *playerName;
    if (audioPlayer == self.ttsPlayer) {
        playerName = @"ttsPlayer";
    }
    if(audioPlayer == self.contextPlayer){
        playerName = @"contextPlayer";
    }
    NSLog(@"STKAudioPlayer::didStartPlayingQueueItemId::%@开始",playerName);
    
    if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:buffingFinish:)]) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] buffingFinish:NO];
    }
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
     if (deviceId) {
         [[EVSSqliteManager shareInstance] update:@{@"session_status":@"SPEAKING"} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
     }
    [[EVSApplication shareInstance] setEVSSessionState:SPEAKING];
    if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:sessionStatus:)]){
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] sessionStatus:[EVSApplication shareInstance].sessionState];
    }
    if (audioPlayer == self.ttsPlayer) {
        [self.delegate audioOutputTTSChannelStart:self model:self.ttsModel];
    }
    if(audioPlayer == self.contextPlayer){
        [self.delegate audioOutputContextChannelStart:self model:self.contextModel];
        
        if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:current:total:)] && !isnan(audioPlayer.duration)) {
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] current:0 total:audioPlayer.duration*TIME_ZOOM];
        }
        if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:progress:)]) {
            [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] progress:0];
        }
        [self startTimer];
    }
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{
    NSLog(@"STKAudioPlayer::didFinishBufferingSourceWithQueueItemId::缓冲结束");
    if ([[EvsSDKForiOS shareInstance].delegate respondsToSelector:@selector(evs:buffingFinish:)]) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] buffingFinish:YES];
    }
}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{
    NSString *playerName;
    if (audioPlayer == self.ttsPlayer) {
        playerName = @"ttsPlayer";
        if (state == STKAudioPlayerStatePlaying) {
            NSLog(@"STKAudioPlayer::stateChanged::STKAudioPlayerStatePlaying::%@",playerName);
            [self setBackgroundVolume2Percent];
        }
    }
    if(audioPlayer == self.contextPlayer){
        playerName = @"contextPlayer";
        if (state == STKAudioPlayerStatePlaying){
           NSLog(@"STKAudioPlayer::stateChanged::STKAudioPlayerStatePlaying::%@",playerName);
        }
    }
    NSLog(@"STKAudioPlayer::stateChanged::%@",playerName);
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{
    NSString *playerName;
    if (audioPlayer == self.ttsPlayer) {
        playerName = @"ttsPlayer";
    }
    if(audioPlayer == self.contextPlayer){
        playerName = @"contextPlayer";
    }
    NSLog(@"STKAudioPlayer::didFinishPlayingQueueItemId::%@结束",playerName);
    if (audioPlayer == self.ttsPlayer && self.ttsModel) {
        [self.delegate audioOutputTTSChannelFinish:self model:self.ttsModel];
        self.ttsModel = nil;
        self.ttsPlayer = nil;
    }
//    if (audioPlayer == self.contextPlayer && self.contextModel){
//        [self.delegate audioOutputContextChannelFinish:self model:self.contextModel];
//        self.contextModel = nil;
////        self.contextPlayer = nil;
//    }
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{
    NSLog(@"STKAudioPlayer::unexpectedError::%ld",(long)errorCode);
    NSString *playerName;
    if (audioPlayer == self.ttsPlayer) {
        playerName = @"ttsPlayer";
    }
    if(audioPlayer == self.contextPlayer){
        playerName = @"contextPlayer";
    }
    EVSLog(@"[*] audio player %@ error loading fail...",playerName);
    if (self.retryCount < 1 && self.contextModel) {
//        [self.contextPlayer play:self.contextModel.url];
    }
    self.retryCount ++;
//    [self stopTimer];
//    [EVSSystemManager exception:@"audio_output" code:@"1001" message:[NSString stringWithFormat:@"audio_output player %@ error loading fail",playerName]];
//    [self syncAudioError:@"1001"];
}
#pragma option
/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line{
//    NSLog(@" STKAudioPlayer::logInfo::%@",line);
}
/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didCancelQueuedItems:(NSArray*)queuedItems{
    
}

/// Raised when datasource read stream metadata. Called from the non-main thread.
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didReadStreamMetadata:(NSDictionary*)dictionary{
    NSLog(@"STKAudioPlayer::didReadStreamMetadata::%@",dictionary);
}
@end
