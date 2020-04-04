//
//  EVSContactsManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2020/4/3.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import "EVSContactsManager.h"

@implementation EVSContactsManager
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSContactsManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        
    });
    return shareInstance;
}
@end
