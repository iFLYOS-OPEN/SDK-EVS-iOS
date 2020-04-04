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

@interface EVSVideoPlayerManager()<PLPlayerDelegate>
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
//@property (nonatomic,strong) FFAVPlayerController *ffavPlayer;
@property (nonatomic,strong) PLPlayer *plPlayer;
@property (nonatomic,strong) PLPlayerOption *option;
#endif
@property (nonatomic,strong) UIView *drawView;
@end

@implementation EVSVideoPlayerManager
#if isCustomPlayerModel
-(PLPlayerOption *) option{
    if (!_option) {
        _option = [PLPlayerOption defaultOption];
        // 更改需要修改的 option 属性键所对应的值
        [_option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
        [_option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
        [_option setOptionValue:@(NO) forKey:PLPlayerOptionKeyVideoToolbox];
        [_option setOptionValue:@(kPLLogInfo) forKey:PLPlayerOptionKeyLogLevel];
    }
    return _option;
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
//进入后台
-(void) enterBackground{
    if (self.plPlayer) {
        self.plPlayer.backgroundPlayEnable = NO;
    }
}
//进入前台
-(void) becomeActive{
    if (self.plPlayer) {
        self.plPlayer.backgroundPlayEnable = YES;
    }
}
//创建视频窗口
-(void) createVideoPlayer:(UIView *) view frame:(CGRect) frame url:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id{
    self.offset = offset;
    self.resource_id = resource_id;
    self.frame = frame;
    self.targetView = view;
    if (url) {
        #if isCustomPlayerModel
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *urlObj = [NSURL URLWithString:url];
            if (urlObj) {
                if (self.plPlayer) {
                    [self.plPlayer openPlayerWithURL:urlObj];
                }else{
                    self.plPlayer = [[PLPlayer alloc] initWithURL:urlObj option:self.option];
                    self.plPlayer.delegate = self;
                    [self.plPlayer play];
                }
                self.drawView = [self.plPlayer playerView];
                self.drawView.frame = self.frame;
                self.drawView.userInteractionEnabled = NO;
                [self.targetView insertSubview:self.drawView atIndex:0];
            }
        });
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
                    if (self.plPlayer) {
                        [self.plPlayer stop];
                        NSTimeInterval time = (offset / TIME_ZOOM);
                        if (time > 0) {
                            [self.plPlayer preStartPosTime:CMTimeMake(time, 1)];
                        }
                        
                        [self.plPlayer playWithURL:urlObj sameSource:NO];
                    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.plPlayer) {
            [self.plPlayer pause];
        }
    });
    #else
        if (self.player) {
            [self.player pause];
        }
    #endif
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_paused,@"offset":@(self.offset)} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
    EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
    progressSync.iflyos_request.payload.type = @"PAUSED";
    NSDictionary *progressSyncDict = [progressSync getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
}

-(void) play:(NSTimeInterval) offset{
    #if isCustomPlayerModel
       NSTimeInterval time = (offset / TIME_ZOOM);
       dispatch_async(dispatch_get_main_queue(), ^{
                  if (self.plPlayer) {
                      [self.plPlayer seekTo:CMTimeMake(time, 1)];
                  }
              });
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.plPlayer) {
                [self.plPlayer resume];
            }
        });
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.plPlayer) {
                [self.plPlayer play];
            }
        });
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
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    if (deviceId) {
        [[EVSSqliteManager shareInstance] update:@{@"state":playback_state_paused} device_id:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
    }
    //同步状态
    EVSVideoPlayerProgressSync *videoProgressSync = [[EVSVideoPlayerProgressSync alloc] init];
    videoProgressSync.iflyos_request.payload.type = @"FINISHED";
    videoProgressSync.iflyos_request.payload.resource_id = self.resource_id;
    videoProgressSync.iflyos_request.payload.offset = self.offset;
    NSDictionary *videoProgressSyncDict = [videoProgressSync getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:videoProgressSyncDict];
    #if isCustomPlayerModel
         [self.drawView removeFromSuperview];
               [self.plPlayer stop];
               self.plPlayer = nil;
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
//        if ([self.delegate respondsToSelector:@selector(videoPlayer:duration:buffer:)]) {
//            [self.delegate videoPlayer:playerItem buffer:progress];
//        }
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

// 实现 <PLPlayerDelegate> 来控制流状态的变更
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state {
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
  // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
  // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
  // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
  // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    switch (state) {
        case PLPlayerStatusReady:
            EVSLog(@"[*] audio player ready...");
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(videoPlayer:canPlay:)]) {
                    [self.delegate videoPlayer:player canPlay:YES];
                }
//                [self.drawView removeFromSuperview];
//                self.drawView = nil;
                [[AudioOutput shareInstance] videoreadyToPlay];
            });
        }
            break;
        case PLPlayerStatusPlaying:
            EVSLog(@"[*] audio player playing...");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:player videoState:VIDEO_STATE_PLAYING];
            }
        }
            break;
        case PLPlayerStatusPaused:
            EVSLog(@"[*] audio player paused...");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:player videoState:VIDEO_STATE_PAUSE];
            }
        }
            break;
        case PLPlayerStatusStopped:
            EVSLog(@"[*] audio player stopped...");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:player videoState:VIDEO_STATE_STOP];
            }
        }
            break;
        case PLPlayerStatusCompleted:
            EVSLog(@"[*] audio player completed...");
        {
            if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
                [self.delegate videoPlayer:player videoState:VIDEO_STATE_END];
            }
            [[AudioOutput shareInstance] videoPlayEnd];
        }
            break;
        default:
            break;
    }
}

- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error {
    // 当发生错误，停止播放时，会回调这个方法
    if ([self.delegate respondsToSelector:@selector(videoPlayer:videoState:)]) {
           [self.delegate videoPlayer:player videoState:VIDEO_STATE_ERROR];
       }
       EVSLog(@"[*] audio player error stoppedWithError:%@",error.localizedDescription);
       [EVSSystemManager exception:@"video_out" code:@"1001" message:[NSString stringWithFormat:@"video_out player stoppedWithError::%@",error.localizedDescription]];
       [self syncAudioError:@"1001"];
}

- (void)player:(nonnull PLPlayer *)player codecError:(nonnull NSError *)error {
  // 当解码器发生错误时，会回调这个方法
  // 当 videotoolbox 硬解初始化或解码出错时
  // error.code 值为 PLPlayerErrorHWCodecInitFailed/PLPlayerErrorHWDecodeFailed
  // 播发器也将自动切换成软解，继续播放
    EVSLog(@"[*] audio player error codecError:%@",error.localizedDescription);
}

/**
回调将要渲染的帧数据
该功能只支持直播

@param player 调用该方法的 PLPlayer 对象
@param frame 将要渲染帧 YUV 数据。
CVPixelBufferGetPixelFormatType 获取 YUV 的类型。
软解为 kCVPixelFormatType_420YpCbCr8Planar.
硬解为 kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange.
@param pts 显示时间戳 单位ms
@param sarNumerator
@param sarDenominator
其中sar 表示 storage aspect ratio
视频流的显示比例 sarNumerator sarDenominator
@discussion sarNumerator = 0 表示该参数无效

@since v2.4.3
*/
- (void)player:(nonnull PLPlayer *)player willRenderFrame:(nullable CVPixelBufferRef)frame pts:(int64_t)pts sarNumerator:(int)sarNumerator sarDenominator:(int)sarDenominator{
    
    // 获取当前播放到的秒数
    float current = pts;
    // 获取视频总播放秒数
    float total = CMTimeGetSeconds(player.totalDuration) * TIME_ZOOM;
    
    self.offset = current;

//    NSLog(@"[*] audio player PLPlayer::position::%f / %f = %.02f",current,total,(current/total));
    if ([self.delegate respondsToSelector:@selector(videoPlayer:totalTime:currentTime:)]) {
        [self.delegate videoPlayer:player totalTime:total currentTime:current];
    }
    if (current / TIME_ZOOM >= 30 && !self.nearlyFinishedSended) {
        //同步服务器(NEARLY_FINISHED，即将播放完)
        EVSVideoPlayerProgressSync *progressSync = [[EVSVideoPlayerProgressSync alloc] init];
        progressSync.iflyos_request.payload.type = @"NEARLY_FINISHED";
        NSDictionary *progressSyncDict = [progressSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:progressSyncDict];
        self.nearlyFinishedSended = YES;
    }
}

#else
   
#endif
@end
