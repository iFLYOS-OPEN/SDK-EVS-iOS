//
//  EVSVideoPlayerManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/11/11.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSVideoPlayerManager.h"
#import "EVSHeader.h"
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface EVSVideoPlayerManager()
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong)  id timeObser;
@property (nonatomic,strong) UIView *targetView;
@property (nonatomic,assign) CGRect frame;

@property (nonatomic,assign) long offset;
@property (nonatomic,copy) NSString *resource_id;

//是否重复提交NEARLY_FINISHED
@property (assign,atomic) BOOL nearlyFinishedSended;
#if isCustomPlayerModel
@property (nonatomic,strong) FFAVPlayerController *ffavPlayer;
#endif
@property (nonatomic,strong) UIView *drawView;
@end

@implementation EVSVideoPlayerManager
#if isCustomPlayerModel
-(FFAVPlayerController *) ffavPlayer{
    if (!_ffavPlayer) {
        _ffavPlayer = [[FFAVPlayerController alloc] init];
        _ffavPlayer.delegate = self;
        _ffavPlayer.shouldAutoPlay = YES;
    }
    return _ffavPlayer;
}
#endif
-(UIView *) drawView{
    if(!_drawView){
        _drawView = [[UIView alloc] init];
    }
    return _drawView;
}
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSVideoPlayerManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

-(id) init{
    if (self == [super init]) {
       
    }
    return self;
}
//注册视频组件
-(void) registVideoPlayerComponent:(AVPlayer *) player playerLayer:(AVPlayerLayer *) playerLayer playerItem:(AVPlayerItem *) playerItem{
    self.player = player;
    self.playerLayer = playerLayer;
    self.playerItem = playerItem;
}
//创建视频窗口
-(void) createVideoPlayer:(UIView *) view frame:(CGRect) frame url:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id{
    self.offset = offset;
    self.resource_id = resource_id;
    self.frame = frame;
    self.targetView = view;
    if (url) {
        #if isCustomPlayerModel
                  NSURL *urlObj = [NSURL URLWithString:url];
                  if (urlObj) {
                      [self.ffavPlayer openMedia:urlObj withOptions:nil];
                  }
        #else
            // 设置视频数据
            [self playWithViedeoUrl:url];
            // 初始化播放器图层对象
            [self initAVPlayerLayer:view frame:frame];
        [self play];
        #endif

    }
}

//播放
-(void) play:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id{
    self.offset = offset;
    self.resource_id = resource_id;
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        [newDict setObject:@(offset) forKey:@"offset"];
        if (resource_id) {
            [newDict setObject:resource_id forKey:@"resource_id"];
        }
        [[EVSSqliteManager shareInstance] update:newDict device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
        if (url) {
            self.nearlyFinishedSended = NO;
            #if isCustomPlayerModel
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *urlObj = [NSURL URLWithString:url];
                if (urlObj) {
                    [self.ffavPlayer stop];
                    self.ffavPlayer = nil;
                    [self.ffavPlayer openMedia:urlObj withOptions:nil];
                }
            });
            #else
            [self removeObserver];
            self.playerItem = [self getPlayItemWithUrl:url];
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
             // 添加播放进度监听
               [self addProgressObserver];
               // 添加播放内容KVO监听
               [self addPlayerItemObserver];
               // 添加通知中心监听播放完成
               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextPlayFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            
            if (offset == 0) {
                        [self.player play];
                    }else{
            //            int32_t timeScale = self.player.currentItem.asset.duration.timescale;
            //            float process = (float)(time/1000.0);
            //            CMTime time = CMTimeMakeWithSeconds(process, timeScale);
            //            [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                        NSTimeInterval time = (offset / 1000);
                        [self.player seekToTime:CMTimeMake(time, 1)];
                        [self.player play];
                    }
            #endif
           
        }
}
//同步进度
-(void) synProgress:(NSTimeInterval) time{
    
}
//是否全屏
- (void)setNewOrientation:(BOOL)fullscreen{
    if (fullscreen) {
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }else{
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}

//下一个
-(void) switchVideo{
    if (self.player) {
        [self.player pause];
        NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
        if (deviceId) {
            [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_paused} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
        }
    }
}
//暂停
-(void) pause{
    #if isCustomPlayerModel
              [self.ffavPlayer pause];
    #else
        if (self.player) {
            [self.player pause];
        }
    #endif
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_paused} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
    EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
    progressSync.iflyos_request.payload.type = @"PAUSED";
    NSDictionary *progressSyncDict = [progressSync getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
}

-(void) play:(NSTimeInterval) offset{
    #if isCustomPlayerModel
       NSTimeInterval time = (offset / TIME_ZOOM);
              [self.ffavPlayer play:time];
    #else
        if (self.player) {
                NSTimeInterval time = (offset / TIME_ZOOM);
                [self.player seekToTime:CMTimeMake(time, 1)];
                [self.player play];
        //        EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
        //        progressSync.iflyos_request.payload.type = @"PLAYING";
        //        NSDictionary *progressSyncDict = [progressSync getJSON];
        //        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
            }
    #endif
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_playing,@"offset":@(offset)} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
}

//恢复
-(void) resume{
    #if isCustomPlayerModel
        [self.ffavPlayer resume];
    #else
        if (self.player) {
            NSTimeInterval time = (self.offset / 1000);
            [self.player seekToTime:CMTimeMake(time, 1)];
            [self.player play];
        }
    #endif
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_playing} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
}

//播放
-(void) play{
    #if isCustomPlayerModel
        [self.ffavPlayer play:0];
    #else
        if (self.player) {
            [self.player play];
        }
    #endif
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_playing} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
    EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
    progressSync.iflyos_request.payload.type = @"PLAYING";
    NSDictionary *progressSyncDict = [progressSync getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
}

//清除
-(void) clean{
    #if isCustomPlayerModel
         [self.drawView removeFromSuperview];
               [self.ffavPlayer stop];
               self.ffavPlayer = nil;
               
               self.targetView = nil;
               self.delegate = nil;
    #else
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self removeObserver];
        [self.playerLayer removeFromSuperlayer];
        self.targetView = nil;
        self.player = nil;
        self.playerItem = nil;
        self.playerLayer = nil;
        self.delegate = nil;
    #endif
}

-(void) removeObserver{
    [self.player.currentItem.asset cancelLoading];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeTimeObserver:self.timeObser];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.playerItem = nil;
    self.timeObser = nil;
}

// 设置视频数据
- (void)playWithViedeoUrl:(NSString *)videoUrl {
    // 获取播放内容
    self.playerItem = [self getPlayItemWithUrl:videoUrl];
    // 创建视频播放器
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 添加播放进度监听
    [self addProgressObserver];
    // 添加播放内容KVO监听
    [self addPlayerItemObserver];
    // 添加通知中心监听播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextPlayFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

// 初始化AVPlayerItem视频内容对象
- (AVPlayerItem *)getPlayItemWithUrl:(NSString *)videoUrl {
    // 编码文件名，以防含有中文，导致存储失败
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *urlStr = [videoUrl stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建播放内容对象
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}
//创建画布
- (void)initAVPlayerLayer:(UIView *) view frame:(CGRect) frame {
    // 创建视频播放器图层对象
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // 尺寸大小
    layer.frame = frame;
    // 视频填充模式
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.backgroundColor = [UIColor blackColor].CGColor;
    layer.zPosition = 0;
    // 添加进控件图层
    [view.layer addSublayer:layer];
    self.playerLayer = layer;
    view.layer.masksToBounds = YES;
}
//同步播放器错误信息
-(void) syncAudioError:(NSString *) code{
    //同步服务器
    EVSAudioPlayerPlaybackProgressSync *progressSync = [[EVSAudioPlayerPlaybackProgressSync alloc] init];
    progressSync.iflyos_request.payload.type = @"FAILED";
    progressSync.iflyos_request.payload.resource_id = self.resource_id;
    progressSync.iflyos_request.payload.offset = self.offset;
    progressSync.iflyos_request.payload.failure_code = code;
    NSDictionary *progressSyncDict = [progressSync getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
}
/*********************监听*************************/
// 添加KVO，监听播放状态和缓冲加载状况
- (void)addPlayerItemObserver {
    // 监控状态属性
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    // 监控缓冲加载情况属性
    [self.playerItem addObserver:self
                      forKeyPath:@"loadedTimeRanges"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

// 属性发生变化，KVO响应函数
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    float time = 0;
    // 状态发生改变
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            time = CMTimeGetSeconds(playerItem.duration);
            NSLog(@"video - 总时间长：%.02f",time);
            [self.delegate videoPlayer:playerItem canPlay:YES];
            [[AudioOutput shareInstance] videoreadyToPlay];
        }else{
            [self.delegate videoPlayer:playerItem canPlay:NO];
            NSLog(@"video - 无法播放");
            EVSLog(@"[*] audio player error loading fail...");
            [EVSSystemManager exception:@"video_out" code:@"1001" message:[NSString stringWithFormat:@"video_out player %@ error loading fail"]];
            [self syncAudioError:@"1001"];
        }
    }
    // 缓冲区域变化
    else if ( [keyPath isEqualToString:@"loadedTimeRanges"] ) {
        NSArray *array = playerItem.loadedTimeRanges;
        // 已缓冲范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        NSTimeInterval totalDuration = CMTimeGetSeconds(playerItem.duration);
        float progress = totalBuffer / totalDuration;
        NSLog(@"video - 缓冲进度：%.02f",progress);
        if ([self.delegate respondsToSelector:@selector(videoPlayer:duration:buffer:)]) {
            [self.delegate videoPlayer:playerItem buffer:progress];
        }
    }
}



-(void) contextPlayFinished:(NSNotification *) notification{
    [[AudioOutput shareInstance] videoPlayEnd];
}

// 进度监听
- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    AVPlayerItem *item = self.player.currentItem;
    if (item) {
        self.timeObser = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                                 queue:dispatch_get_main_queue()
                                            usingBlock:^(CMTime time) {
            // CMTime是表示视频时间信息的结构体，包含视频时间点、每秒帧数等信息
            // 获取当前播放到的秒数
            float current = CMTimeGetSeconds(time)* TIME_ZOOM;
            // 获取视频总播放秒数
            float total = CMTimeGetSeconds(item.duration)* TIME_ZOOM;
           
           NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
           if (deviceId) {
               [[EVSSqliteManager shareInstance] update:@{@"offset":@(current)} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
           }
           //进度
           if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:totalTime:currentTime:)]) {
               if (isnan(total)){
                   total = 0.0f;
               }
               [weakSelf.delegate videoPlayer:item totalTime:total currentTime:current];
           }
           long lastTime = current / TIME_ZOOM;
           NSLog(@"video - 当前播放进度：%.02f / %.02f = %li",current,total,lastTime);
           if (lastTime >= 30 && !weakSelf.nearlyFinishedSended) {
               //同步服务器(NEARLY_FINISHED，即将播放完)
               EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
               progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
               NSDictionary *progressSyncDict = [progressSync getJSON];
               [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
               weakSelf.nearlyFinishedSended = YES;
           }
        }];
    }
}
#if isCustomPlayerModel
#pragma FFAVMediaPlayerDelegate
- (void)FFAVPlayerControllerWillLoad:(FFAVPlayerController *)controller{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(videoPlayer:canPlay:)]) {
            [self.delegate videoPlayer:controller canPlay:YES];
        }
        [self.drawView removeFromSuperview];
        self.drawView = nil;
    });
}

- (void)FFAVPlayerControllerDidLoad:(FFAVPlayerController *)controller error:(NSError *)error {
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.ffavPlayer hasVideo]) {
                self.drawView = [self.ffavPlayer drawableView];
                self.drawView.frame = self.frame;
                self.drawView.userInteractionEnabled = NO;
                [self.targetView insertSubview:self.drawView atIndex:0];
            }
        });
    }else{
        NSLog(@"错误：%@",error);
    }
}
//状态
// state was changed
- (void)FFAVPlayerControllerDidStateChange:(FFAVPlayerController *)controller{
    AVPlayerState state = [controller playerState];
    /**
            kAVPlayerStateInitialized=0,
            kAVPlayerStatePlaying,
            kAVPlayerStatePaused,
            kAVPlayerStateFinishedPlayback,
            kAVPlayerStateStoped,
            kAVPlayerStateUnknown=0xff
     */
    switch (state) {
        case kAVPlayerStateInitialized:
            NSLog(@"FFAVPlayer状态：初始化");
            {
                
            }
            break;
        case kAVPlayerStatePlaying:
            NSLog(@"FFAVPlayer状态：播放中");
            {
                if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                    [self.delegate videoPlayer:controller videoState:VIDEO_STATE_PLAYING];
                }
                [[AudioOutput shareInstance] videoreadyToPlay];
            }
            break;
        case kAVPlayerStatePaused:
            NSLog(@"FFAVPlayer状态：暂停");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:controller videoState:VIDEO_STATE_PAUSE];
            }
        }
            break;
        case kAVPlayerStateFinishedPlayback:
            NSLog(@"FFAVPlayer状态：结束");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:controller videoState:VIDEO_STATE_END];
            }
            [[AudioOutput shareInstance] videoPlayEnd];
        }
            break;
        case kAVPlayerStateStoped:
            NSLog(@"FFAVPlayer状态：停止");
            {
                if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                    [self.delegate videoPlayer:controller videoState:VIDEO_STATE_PAUSE];
                }
            }
            break;
        case kAVPlayerStateUnknown:
            
            break;
        default:
            break;
    }
}
//当前进度
// current play time was changed
- (void)FFAVPlayerControllerDidCurTimeChange:(FFAVPlayerController *)controller position:(NSTimeInterval)position{
    // 获取当前播放到的秒数
    float current = position* TIME_ZOOM;
    // 获取视频总播放秒数
    float total = controller.duration * TIME_ZOOM;
    
    NSLog(@"FFAVPlayer::position::%f / %f = %.02f",position,controller.duration,(current/total));
    if ([self.delegate respondsToSelector:@selector(videoPlayer:totalTime:currentTime:)]) {
        [self.delegate videoPlayer:controller totalTime:total currentTime:current];
    }
    if (position >= 30 && !self.nearlyFinishedSended) {
        //同步服务器(NEARLY_FINISHED，即将播放完)
        EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
        progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
        NSDictionary *progressSyncDict = [progressSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
        self.nearlyFinishedSended = YES;
    }
}
//当前缓冲
// current buffering progress was changed[0~1]
- (void)FFAVPlayerControllerDidBufferingProgressChange:(FFAVPlayerController *)controller progress:(double)progress{
//    NSLog(@"FFAVPlayer::buffering::%f",progress);

    if (progress <= 0) {
        if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
            [self.delegate videoPlayer:controller videoState:VIDEO_STATE_BUFFERING];
        }
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayer:duration:buffer:)]) {
        [self.delegate videoPlayer:controller buffer:progress];
    }

}

// real bitrate was changed
- (void)FFAVPlayerControllerDidBitrateChange:(FFAVPlayerController *)controller bitrate:(NSInteger)bitrate{
    
}

// real framerate was changed
- (void)FFAVPlayerControllerDidFramerateChange:(FFAVPlayerController *)controller framerate:(NSInteger)framerate{
    
}

// current subtitle was changed
- (void)FFAVPlayerControllerDidSubtitleChange:(FFAVPlayerController *)controller subtitleItem:(FFAVSubtitleItem *)subtitleItem{
    
}

// enter or exit full screen mode
//进入全屏
- (void)FFAVPlayerControllerDidEnterFullscreenMode:(FFAVPlayerController *)controller{
    
}
//退出全屏
- (void)FFAVPlayerControllerDidExitFullscreenMode:(FFAVPlayerController *)controller{
    
}
// 播放错误
// error handler
- (void)FFAVPlayerControllerDidOccurError:(FFAVPlayerController *)controller error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
        [self.delegate videoPlayer:controller videoState:VIDEO_STATE_ERROR];
    }
    NSLog(@"video - 无法播放");
    EVSLog(@"[*] audio player error loading fail...");
    [EVSSystemManager exception:@"video_out" code:@"1001" message:[NSString stringWithFormat:@"video_out player %@ error loading fail"]];
    [self syncAudioError:@"1001"];
}
#else
   
#endif
@end
