//
//  EVSVideoPlayerManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/11/11.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVSVideoPlayerDelegate.h"
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, EVSVideoPlayerState) {
    VIDEO_CLOSED = 0, //已关闭
    VIDEO_OPENED = 1 //已打开
};

@interface EVSVideoPlayerManager : NSObject

//状态
@property (assign,nonatomic) EVSVideoPlayerState state;
//代理
@property(weak) id<EVSVideoPlayerDelegate> delegate;

/**
 *  单例
 */
+(instancetype) shareInstance;
//创建视频窗口
-(void) createVideoPlayer:(UIView *) view frame:(CGRect) frame url:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id;
//播放(新资源)
-(void) play:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id;
//切换
-(void) switchVideo;
//暂停
-(void) pause;
//恢复
-(void) resume;
//从offset播放
-(void) play:(NSTimeInterval) offset;
//播放
-(void) play;
//同步进度
-(void) synProgress:(NSTimeInterval) time;
//是否全屏
- (void)setNewOrientation:(BOOL)fullscreen;
//清除资源
-(void) clean;
@end

NS_ASSUME_NONNULL_END
