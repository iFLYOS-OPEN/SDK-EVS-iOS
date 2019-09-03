//
//  EVSSystemException.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/9.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSSystemException.h"
#import "EVSHeader.h"
@implementation EVSSystemExceptionRequestHeader
-(NSString *) name{
    return @"system.exception";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end

@implementation EVSSystemExceptionRequestPayload

@end

@implementation EVSSystemExceptionRequest
-(EVSSystemExceptionRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSSystemExceptionRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSSystemExceptionRequestHeader *) header{
    if (!_header) {
        _header = [[EVSSystemExceptionRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSSystemException
-(EVSSystemExceptionRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSSystemExceptionRequest alloc] init];
    }
    return _iflyos_request;
}
@end
