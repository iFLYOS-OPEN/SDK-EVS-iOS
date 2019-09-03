//
//  DeviceInfo.h
//  ivsSDKForIOSDemo
//
//  Created by admin on 2018/7/25.
//  Copyright © 2018年 ivsSDKForIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
@interface EVSDeviceInfo : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;
- (NSString*)uuid;
- (void)saveDeviceId:(NSString *) deviceId;
- (NSString *)getDeviceId;

- (void)saveClientId:(NSString *) clientId;
- (NSString *)getClientId;

//ip地址
+ (NSString *)deviceIPAdress;
@end
