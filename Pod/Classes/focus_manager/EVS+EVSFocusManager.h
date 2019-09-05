//
//  EVS+EVSFocusManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/14.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSFocusManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSFocusManager(EVS_EVSFocusManager)
/*************************音效*****************************/
-(void) playPowerOn;//开机
-(void) playPowerOff;//关机
-(void) playNetworkErrorRetry;//重试
-(void) playNetworkErrorWait;//等待再试
-(void) playVolume;//音量提示音
-(void) wakeUp0;//唤醒提示音
-(void) authError;//授权问题
@end

NS_ASSUME_NONNULL_END
