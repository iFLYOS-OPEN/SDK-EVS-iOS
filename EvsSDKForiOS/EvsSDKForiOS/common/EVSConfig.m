//
//  EVSConfig.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSConfig.h"

@implementation EVSConfig
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSConfig *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


@end
