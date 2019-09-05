//
//  EVSAudioPlayerTTS.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAudioPlayerTTS.h"
#import "EVSHeader.h"

@implementation EVSAudioPlayerTTSTextInRequestPayload
-(id) init{
    if (self == [super init]) {
    }
    return self;
}
@end

@implementation EVSAudioPlayerTTSTextInRequestHeader
-(NSString *) name{
    return @"audio_player.tts.text_in";
}

-(NSString *) request_id{
    return [NSString requestIdWithActive];
}
@end

@implementation EVSAudioPlayerTTSTextInRequest
-(EVSAudioPlayerTTSTextInRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAudioPlayerTTSTextInRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAudioPlayerTTSTextInRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAudioPlayerTTSTextInRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSAudioPlayerTTSTextIn
-(EVSAudioPlayerTTSTextInRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAudioPlayerTTSTextInRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSAudioPlayerTTS

@end


//TTS同步

@implementation EVSAudioPlayerTTSProgressSyncRequestPayload

@end

@implementation EVSAudioPlayerTTSProgressSyncRequestHeader
-(NSString *) name{
    return @"audio_player.tts.progress_sync";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end

@implementation EVSAudioPlayerTTSProgressSyncRequest
-(EVSAudioPlayerTTSProgressSyncRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAudioPlayerTTSProgressSyncRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAudioPlayerTTSProgressSyncRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAudioPlayerTTSProgressSyncRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSAudioPlayerTTSProgressSync
-(EVSAudioPlayerTTSProgressSyncRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAudioPlayerTTSProgressSyncRequest alloc] init];
    }
    return _iflyos_request;
}
@end
