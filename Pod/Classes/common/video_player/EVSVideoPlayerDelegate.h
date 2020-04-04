//
//  EVSVideoPlayer.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/11/11.
//  Copyright © 2019 iflytek. All rights reserved.
//  播放器实现类
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, EVS_VIDEO_PLAYER_STATE) {
    VIDEO_STATE_INIT   = 0, //打开流中
    VIDEO_STATE_BUFFERING   = 1, //缓冲中
    VIDEO_STATE_PLAYING   = 2,//播放流中
    VIDEO_STATE_END     = 3, //结束
    VIDEO_STATE_PAUSE   = 4, //暂停
    VIDEO_STATE_STOP    = 5, //停止
    VIDEO_STATE_ERROR   = 6//错误
};

@protocol EVSVideoPlayerDelegate <NSObject>
@required
//打开viewController
-(void) open:(NSString *) url offset:(long) offset resource_id:(NSString *) resource_id;
//关闭viewController
-(void) close;
//播放
-(void) play;
//播放(某个时间点)
-(void) play:(NSTimeInterval) time;
//停止
-(void) stop;
//暂停
-(void) pause;

@optional

/**
 *  是否能播放
 *  canPlay : 是否能播放
 */
-(void) videoPlayer:(id) playerItem canPlay:(BOOL) canPlay;

/**
 *  播放进度
 *  totalTime ： 总时长
 *  currentTime :  当前时间
 */
-(void) videoPlayer:(id) playerItem totalTime:(float) totalTime currentTime:(float) currentTime;

/**
 *  是否能播放
 *  videoState : 状态
 */
-(void) videoPlayer:(id) playerItem videoState:(EVS_VIDEO_PLAYER_STATE) videoState;
@end
