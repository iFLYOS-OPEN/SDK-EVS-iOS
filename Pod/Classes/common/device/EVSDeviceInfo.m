//
//  DeviceInfo.m
//  ivsSDKForIOSDemo
//
//  Created by admin on 2018/7/25.
//  Copyright © 2018年 ivsSDKForIOS. All rights reserved.
//

#import <Security/Security.h>
#import <KeychainItemWrapper_Copy/KeychainItemWrapper.h>
#import "EVSHeader.h"
#define FLAG @"com.iflyos.evs"

#define k_CLIENT_ID @"client_id"
#define k_DEVICE_ID @"device_id"

@interface EVSDeviceInfo()
@property(copy,nonatomic) NSString *mDeviceId;
@end

@implementation EVSDeviceInfo
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSDeviceInfo *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString*)uuid {
    CFUUIDRef uuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, uuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    CFRelease(uuid);
    CFRelease(uuidString);
    return result;
}

- (void)saveDeviceId:(NSString *) deviceId{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]
                                         initWithIdentifier:k_DEVICE_ID accessGroup:nil];
    NSString *strUUID = [keychainItem objectForKey:(id)kSecValueData];
    if (strUUID == nil || [strUUID isEqualToString:@""])
    {
        if (deviceId) {
            [keychainItem setObject:deviceId forKey:(id)kSecAttrService];
            [keychainItem setObject:deviceId forKey:(id)kSecValueData];
        }else{
            NSString *uuid = [self uuid];
            [keychainItem setObject:uuid forKey:(id)kSecAttrService];
            [keychainItem setObject:uuid forKey:(id)kSecValueData];
        }
    }
    
    
}
- (NSString *)getDeviceId {
    if (!self.mDeviceId) {
        KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]
                                             initWithIdentifier:k_DEVICE_ID accessGroup:nil];
        NSString *strUUID = [keychainItem objectForKey:(id)kSecValueData];
        self.mDeviceId = strUUID;
        return self.mDeviceId;
    }
   return self.mDeviceId;
}

- (void)saveClientId:(NSString *) clientId{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]
                                         initWithIdentifier:k_CLIENT_ID accessGroup:nil];
    NSString *strUUID = [keychainItem objectForKey:(id)kSecValueData];
    [keychainItem setObject:clientId forKey:(id)kSecAttrService];
    [keychainItem setObject:clientId forKey:(id)kSecValueData];
}
- (NSString *)getClientId{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]
                                         initWithIdentifier:k_CLIENT_ID accessGroup:nil];
    NSString *strUUID = [keychainItem objectForKey:(id)kSecValueData];
    return strUUID;
}

+ (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    //    NSLog(@"手机的IP是：%@", address);
    
    return address;
}
@end
