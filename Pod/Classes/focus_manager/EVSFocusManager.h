//
//  EVSFocusManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/12.
//  Copyright © 2019 iflytek. All rights reserved.
//  焦点管理

#import <Foundation/Foundation.h>
#import "EVSResponseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSFocusManager : NSObject

/**
 *  单例
 */
+(instancetype) shareInstance;

//添加响应到队列
-(void) addQueue:(EVSResponseModel *) responseModel;
//移除指令队列
-(void) removeQueue:(EVSResponseItemModel *) responseModel;
//根据id移除指令
-(void) removeQueueWithId:(NSString *) commandId;
//清理指令队列
-(void) clearQueueAndCommandQueue;
@end

NS_ASSUME_NONNULL_END
