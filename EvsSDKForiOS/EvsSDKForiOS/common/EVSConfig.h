//
//  EVSConfig.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSConfig : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;
//服务器地址
@property(copy,nonatomic) NSString *serverAddress;
//请求超时
@property(assign,nonatomic) NSInteger requestTimeout;
@end

NS_ASSUME_NONNULL_END
