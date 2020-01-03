//
//  EVSApplication.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EvsSDKDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSApplication : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;
@property(nonatomic,strong) MPVolumeView *volumeView;
@property(nonatomic,assign,readonly) EVSSessionState sessionState;
//获取到当前所在的视图
+ (UIViewController *)presentingVC;
/*
 * 设置音量
 */
- (void)setVolume:(float)value;
/*
 * 设置音量
 */
- (void)setSystemVolume:(float)value;



/**
 * 判断是否静音
 */
-(void) addMuteListen;
- (void)checkMuted;
- (void)playbackComplete;
-(BOOL)silenced;

/**
 *  设置对话状态
 */
-(void) setEVSSessionState:(EVSSessionState) sessionState;
@end

NS_ASSUME_NONNULL_END
