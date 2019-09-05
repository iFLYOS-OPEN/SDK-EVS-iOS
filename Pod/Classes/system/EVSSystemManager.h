//
//  EVSSystemManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//  系统管理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSSystemManager : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

/**
 *  同步状态
 */
+(void) stateSync;

/**
 *  同步错误信息
 */
+(void) exception:(NSString *) type code:(NSString *) code message:(NSString *) message;

/**
 *  定期检查
 */
-(void) periodicReview;

/**
 *  停止检查
 */
-(void) stopReview;
@end

NS_ASSUME_NONNULL_END
