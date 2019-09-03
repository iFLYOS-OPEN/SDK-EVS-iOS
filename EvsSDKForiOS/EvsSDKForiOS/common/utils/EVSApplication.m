//
//  EVSApplication.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSApplication.h"
#import <AVFoundation/AVFoundation.h>
#import "EVSHeader.h"
#import "EVSRequestHeader.h"
static CFTimeInterval startPlayTime;
@interface EVSApplication()
{
    @private
    float soundDuration;
    NSTimer *playbackTimer;
    BOOL isMute;//是否静音
}
@end

static void PlaySoundCompletionBlock(SystemSoundID SSID, void *clientData) {
    AudioServicesRemoveSystemSoundCompletion(SSID);
    // 播放结束时，记录时间差，如果小于 0.1s，则认为是静音
    CFTimeInterval playDuring = CACurrentMediaTime() - startPlayTime;
    if (playDuring < 0.1) {
        NSLog(@"静音");
    } else {
        NSLog(@"非静音");
    }
}
@implementation EVSApplication

/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSApplication *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:shareInstance.volumeView];
    });
    return shareInstance;
}

//获取到当前所在的视图
+ (UIViewController *)presentingVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

/*
 * 设置音量
 */
- (void)setSystemVolume:(float)value {
    float volume = value/100.0f;
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = volume;
}

/*
 * 设置音量
 */
- (void)setVolume:(float)value {
    float volume = value/100.0f;
    [[AudioOutput shareInstance] setVolume:volume];
    [[AudioOutput shareInstance] setTTSVolume:volume];
    [EVSSystemManager stateSync];
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.hidden = YES;
    }
    return _volumeView;
}
/*
 * 遍历控件，拿到UISlider
 */
- (UISlider *)volumeSlider {
    UISlider* volumeSlider = nil;
    for (UIView *view in [self.volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider *)view;
            break;
        }
    }
    return volumeSlider;
}

- (void)playbackComplete {
    //切换为听筒播放
    
    NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
    if (soundDuration < 0.010) {
        if (!isMute) {
            if (deviceId) {
//                [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(0)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            }
//            [[AudioOutput shareInstance] setVolume:0];
            isMute = YES;
            //同步状态
            EVSSystemStateSync *systemStateSync = [[EVSSystemStateSync alloc] init];
            systemStateSync.iflyos_context.speaker.volume = 0;
            NSDictionary *dict = [systemStateSync getJSON];
            [[EVSWebscoketManager shareInstance] sendDict:dict];
        }
    }
    else {
        if (isMute) {
            if (deviceId) {
                NSDictionary *dict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
                id vObj = dict[@"speaker_volume"];
                if (vObj) {
                    long volume = [vObj longValue];
//                    [[AudioOutput shareInstance] setVolume:volume/100.0f];
                }
            }
            isMute = NO;
//            [EVSSystemManager stateSync];
        }
    }
    
    [playbackTimer invalidate];
    playbackTimer = nil;
    
}

static void soundCompletionCallback (SystemSoundID mySSID, void* myself) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    [[EVSApplication shareInstance] playbackComplete];
}

- (void)incrementTimer {
    soundDuration = soundDuration + 0.001;
}

- (void)detectMuteSwitch {
    soundDuration = 0.0;
    CFURLRef        soundFileURLRef;
    SystemSoundID    soundFileObject;
    
    // Get the main bundle for the app
    CFBundleRef mainBundle;
    mainBundle = CFBundleGetMainBundle();
    
    // Get the URL to the sound file to play
    soundFileURLRef  =    CFBundleCopyResourceURL(
                                                  mainBundle,
                                                  CFSTR ("detection"),
                                                  CFSTR ("aiff"),
                                                  NULL
                                                  );
    
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    
    AudioServicesAddSystemSoundCompletion (soundFileObject,NULL,NULL,
                                           soundCompletionCallback,
                                           (__bridge void*) self);
    
    // Start the playback timer
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(incrementTimer) userInfo:nil repeats:YES];
    // Play the sound
    AudioServicesPlaySystemSound(soundFileObject);
}

-(void) checkMuted{
    [self detectMuteSwitch];
}

@end
