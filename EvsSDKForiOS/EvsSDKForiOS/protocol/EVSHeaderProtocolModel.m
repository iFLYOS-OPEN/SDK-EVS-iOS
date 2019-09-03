//
//  EVSHeaderProtocalModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSHeaderProtocolModel.h"
#import "EVSHeader.h"
@implementation EVSHeaderProtocolModel
-(NSString *) authorization{
    if (!_authorization) {
        EVSAuthModel *authModel = [EVSAuthModel loadModel];
        if (authModel) {
            _authorization = authModel.authorization;
        }
    }
    return _authorization;
}

-(EVSHeaderDeviceProtocalModel *) device{
    if (!_device) {
        _device = [[EVSHeaderDeviceProtocalModel alloc] init];
    }
    return _device;
}

+(NSDictionary *) getJSON{
    EVSHeaderProtocolModel *model = [[EVSHeaderProtocolModel alloc] init];
    NSDictionary *jsonDict = model.mj_keyValues;
    return jsonDict;
}
@end

@implementation EVSHeaderDeviceProtocalModel
-(NSString *) device_id{
    return [EVSDeviceInfo shareInstance].getDeviceId;
}

-(NSString *) ip{
    return [EVSDeviceInfo deviceIPAdress];
}

-(EVSHeaderDeviceLocationProtocalModel *) location{
    if (!_location) {
        _location = [[EVSHeaderDeviceLocationProtocalModel alloc] init];
    }
    return _location;
}

-(EVSHeaderDevicePlatformProtocalModel *) platform{
    if (!_platform) {
        _platform = [[EVSHeaderDevicePlatformProtocalModel alloc] init];
    }
    return _platform;
}

-(EVSHeaderDeviceFlagsProtocalModel *) flags{
    if (!_flags) {
        _flags = [[EVSHeaderDeviceFlagsProtocalModel alloc] init];
    }
    return _flags;
}
@end

@implementation EVSHeaderDeviceFlagsProtocalModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *headerDict = [[EVSSqliteManager shareInstance] asynQueryHeader:deviceId tableName:HEADER_TABLE_NAME];
        if (headerDict) {
            id kid = headerDict[@"kid"];
            if (kid) {
                self.kid = [kid boolValue];
            }
            id full_duplex = headerDict[@"full_duplex"];
            if (full_duplex) {
                self.full_duplex = [full_duplex boolValue];
            }
        }
    }
    return self;
}
@end

@implementation EVSHeaderDevicePlatformProtocalModel
-(NSString *) name{
    return @"iOS";
}

-(NSString *) version{
     NSString * version = [NSString stringWithFormat:@"%.02f",[[[UIDevice currentDevice] systemVersion] floatValue]];
    return version;
}
@end

@implementation EVSHeaderDeviceLocationProtocalModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *headerDict = [[EVSSqliteManager shareInstance] asynQueryHeader:deviceId tableName:HEADER_TABLE_NAME];
        if (headerDict) {
            id latitude = headerDict[@"latitude"];
            if (latitude) {
                self.latitude = [latitude floatValue];
            }
            id longitude = headerDict[@"longitude"];
            if (longitude) {
                self.longitude = [longitude floatValue];
            }
        }
    }
    return self;
}
@end
