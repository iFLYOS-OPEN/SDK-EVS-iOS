//
//  EVSSystemStateSync.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/9.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSSystemStateSync.h"
#import "EVSHeader.h"
@implementation EVSSystemStateSyncRequestHeader
-(NSString *) name{
    return @"system.state_sync";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end

@implementation EVSSystemStateSyncRequestPayload

@end

@implementation EVSSystemStateSyncRequest
-(EVSSystemStateSyncRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSSystemStateSyncRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSSystemStateSyncRequestHeader *) header{
    if (!_header) {
        _header = [[EVSSystemStateSyncRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSSystemStateSync
-(EVSSystemStateSyncRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSSystemStateSyncRequest alloc] init];
    }
    return _iflyos_request;
}
@end
