//
//  EVSAuthManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSAuthModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSAuthManager : NSObject
@property(assign) BOOL isStopLoop;
/**
 *  单例
 */
+(instancetype) shareInstance;
/**
 *  设备申请授权
 */
-(void) authUserCode:(NSString *) deviceId
            clientId:(NSString *)clientId;

/**
 *  用户授权（web页）
 */
-(void) authDevice:(EVSAuthUserCodeModel *) userCodeModel;

/**
 *  检查token时效，时效性重新申请，并刷新数据库token
 */
-(void) checkTokenVaild;
/**
 *  3.用户授权（轮询）
 */
-(void) authToken:(NSString *)clientId device_code:(NSString *) device_code;
@end

NS_ASSUME_NONNULL_END
