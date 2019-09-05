//
//  EVSResponseModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSResponseModel.h"
#import "EVSHeader.h"
@implementation EVSResponseHeaderModel
-(id) init{
    if (self == [super init]) {
        if (!_command_id){
            _command_id = [NSString randomString];
        }
    }
    return self;
}
@end

@implementation EVSResponsePayloadMetadataModel

@end

@implementation EVSResponsePayloadModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *systemDict = [[EVSSqliteManager shareInstance] asynQuerySystem:deviceId tableName:SYSTEM_TABLE_NAME];
        if (systemDict) {
            id timestamp = systemDict[@"timestamp"];
            if (timestamp) {
                self.timestamp = [timestamp longValue];
            }
        }
    }
    return self;
}
@end

@implementation EVSResponseItemModel

@end

@implementation EVSResponseMetaModel

@end

@implementation EVSResponseModel
//-(EVSResponseMetaModel *) iflyos_meta{
//    if (!_iflyos_meta) {
//        _iflyos_meta = [[EVSResponseMetaModel alloc] init];
//    }
//    return _iflyos_meta;
//}
-(void) setIflyos_responses:(NSArray *)iflyos_responses {
    _iflyos_responses = [EVSResponseItemModel mj_objectArrayWithKeyValuesArray:iflyos_responses];
}
@end
