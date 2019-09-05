//
//  EVSHeaderProtocalModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EVSHeaderDeviceFlagsProtocalModel : NSObject
@property(assign,nonatomic) BOOL kid; //儿童模式（默认false）
@property(assign,nonatomic) BOOL full_duplex; //全双工（默认false）
@end

@interface EVSHeaderDevicePlatformProtocalModel : NSObject
@property(copy,nonatomic) NSString *name; //平台
@property(copy,nonatomic) NSString *version; //系统版本
@end

@interface EVSHeaderDeviceLocationProtocalModel : NSObject
@property(assign,nonatomic) float latitude; //经度
@property(assign,nonatomic) float longitude; //纬度
@end

@interface EVSHeaderDeviceProtocalModel : NSObject
@property(copy,nonatomic) NSString *device_id; //设备id
@property(copy,nonatomic) NSString *ip;//ip地址
@property(strong,nonatomic) EVSHeaderDeviceLocationProtocalModel *location;
@property(strong,nonatomic) EVSHeaderDevicePlatformProtocalModel *platform;
@property(strong,nonatomic) EVSHeaderDeviceFlagsProtocalModel *flags;
@end

@interface EVSHeaderProtocolModel : NSObject
@property(copy,nonatomic) NSString *authorization;
@property(strong,nonatomic) EVSHeaderDeviceProtocalModel *device;

//获取header json字典
+(NSDictionary *) getJSON;
@end

NS_ASSUME_NONNULL_END
