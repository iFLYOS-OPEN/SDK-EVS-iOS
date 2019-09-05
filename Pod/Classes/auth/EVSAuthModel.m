//
//  EVSAuthModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAuthModel.h"
#import "EVSHeader.h"
@implementation EVSAuthModel

+(EVSAuthModel *) loadModel{
    EVSAuthModel *model = [[EVSAuthModel alloc] init];
    
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    EVSSqliteManager *sqliteManager = [EVSSqliteManager shareInstance];
    NSDictionary *dict = [sqliteManager asynQueryConfig:deviceId tableName:CONFIG_TABLE_NAME];
    if (dict) {
        NSString *access_token = dict[@"access_token"];
        NSString *token_type = dict[@"token_type"];
        NSString *refresh_token = dict[@"refresh_token"];
        NSInteger expires_in = [dict[@"expires_in"] integerValue];
        NSInteger created_at = [dict[@"created_at"] integerValue];
        NSString *az = [NSString stringWithFormat:@"%@ %@",token_type,access_token];
        if (az) {
            NSString *strUpper = [az substringToIndex:1];
            NSString *strOrig = [az substringFromIndex:1];
            az = [[strUpper uppercaseString] stringByAppendingString:strOrig];
        }
        model.access_token = access_token;
        model.token_type = token_type;
        model.refresh_token = refresh_token;
        model.expires_in = expires_in;
        model.created_at = created_at;
        model.authorization = az;
    }
    return model;
}

-(void) save{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    EVSSqliteManager *sqliteManager = [EVSSqliteManager shareInstance];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.access_token) {
        [dict setObject:self.access_token forKey:@"access_token"];
    }
    if (self.access_token) {
        [dict setObject:self.token_type forKey:@"token_type"];
    }
    if (self.access_token) {
        [dict setObject:self.refresh_token forKey:@"refresh_token"];
    }
    if (self.access_token) {
        [dict setObject:@(self.expires_in) forKey:@"expires_in"];
    }
    if (self.access_token) {
        [dict setObject:@(self.created_at) forKey:@"created_at"];
    }
    [sqliteManager update:dict device_id:deviceId tableName:CONFIG_TABLE_NAME];
}
@end

@implementation EVSAuthUserCodeModel

@end
