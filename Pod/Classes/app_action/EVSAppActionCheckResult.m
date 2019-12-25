//
//  EVSAppActionCheckResult.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/11/19.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAppActionCheckResult.h"
#import "EVSHeader.h"
@implementation EVSAppActionCheckResultRequestPayloadActions

@end
@implementation EVSAppActionCheckResultRequestPayload

@end
@implementation EVSAppActionCheckResultRequestHeader
-(NSString *) name{
    return @"app_action.check_result";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end
@implementation EVSAppActionCheckResultRequest
-(EVSAppActionCheckResultRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAppActionCheckResultRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAppActionCheckResultRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAppActionCheckResultRequestHeader alloc] init];
    }
    return _header;
}
@end
@implementation EVSAppActionCheckResult
-(EVSAppActionCheckResultRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAppActionCheckResultRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSAppActionExcuteSuccessRequestPayload

@end

@implementation EVSAppActionExcuteSuccessRequestHeader
-(NSString *) name{
    return @"app_action.execute_succeed";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end
@implementation EVSAppActionExcuteSuccessRequest
-(EVSAppActionExcuteSuccessRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAppActionExcuteSuccessRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAppActionExcuteSuccessRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAppActionExcuteSuccessRequestHeader alloc] init];
    }
    return _header;
}
@end
@implementation EVSAppActionExcuteSuccess
-(EVSAppActionExcuteSuccessRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAppActionExcuteSuccessRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSAppActionExcuteFailedRequestPayload

@end

@implementation EVSAppActionExcuteFailedRequestHeader
-(NSString *) name{
    return @"app_action.execute_failed";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end
@implementation EVSAppActionExcuteFailedRequest
-(EVSAppActionExcuteFailedRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAppActionExcuteFailedRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAppActionExcuteFailedRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAppActionExcuteFailedRequestHeader alloc] init];
    }
    return _header;
}
@end
@implementation EVSAppActionExcuteFailed
-(EVSAppActionExcuteFailedRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAppActionExcuteFailedRequest alloc] init];
    }
    return _iflyos_request;
}
@end
