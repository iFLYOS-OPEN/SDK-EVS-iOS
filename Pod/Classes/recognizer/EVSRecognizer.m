//
//  EVSRecognizer.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/30.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSRecognizer.h"
#import "EVSHeader.h"
@implementation EVSRecognizerRequestHeader
-(NSString *) name{
    return @"recognizer.audio_in";
}

-(NSString *) request_id{
    return [NSString requestIdWithActive];
}
@end

@implementation EVSRecognizer
-(EVSRecognizerRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSRecognizerRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSRecognizerRequest
-(EVSRecognizerRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSRecognizerRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSRecognizerRequestHeader *) header{
    if (!_header) {
        _header = [[EVSRecognizerRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSRecognizerRequestPayload
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *systemDict = [[EVSSqliteManager shareInstance] asynQuerySystem:deviceId tableName:SYSTEM_TABLE_NAME];
        if (systemDict) {
            id enable_vad = systemDict[@"enable_vad"];
            if (enable_vad) {
                self.enable_vad = [enable_vad boolValue];
            }
            id profile = systemDict[@"profile"];
            if (profile) {
                self.profile = profile;
            }
            id format = systemDict[@"format"];
            if (format) {
                self.format = format;
            }
        }
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id reply_key = contextDict[@"reply_key"];
            if (reply_key && ![reply_key isEqualToString:@""]) {
                self.reply_key = reply_key;
            }
        }
    }
    return self;
}
@end

@implementation EVSRecognizerRequestPayloadWakeup


@end

//text in
@implementation EVSRecognizerTextIn
-(EVSRecognizerTextInRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSRecognizerTextInRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSRecognizerTextInRequestPayload

-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id reply_key = contextDict[@"reply_key"];
            if (reply_key && ![reply_key isEqualToString:@""]) {
                self.reply_key = reply_key;
            }
        }
    }
    return self;
}

@end

@implementation EVSRecognizerTextInRequestHeader
-(NSString *) name{
    return @"recognizer.text_in";
}

-(NSString *) request_id{
    return [NSString requestIdWithActive];
}
@end

@implementation EVSRecognizerTextInRequest
-(EVSRecognizerTextInRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSRecognizerTextInRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSRecognizerTextInRequestHeader *) header{
    if (!_header) {
        _header = [[EVSRecognizerTextInRequestHeader alloc] init];
    }
    return _header;
}
@end
