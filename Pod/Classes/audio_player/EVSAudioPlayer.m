//
//  EVSAudioPlayer.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAudioPlayer.h"
#import "EVSHeader.h"
@implementation EVSAudioPlayerPlaybackProgressSyncRequestPayload

@end

@implementation EVSAudioPlayerPlaybackProgressSyncRequestHeader
-(NSString *) name{
    return @"audio_player.playback.progress_sync";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}
@end

@implementation EVSAudioPlayerPlaybackProgressSyncRequest
-(EVSAudioPlayerPlaybackProgressSyncRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAudioPlayerPlaybackProgressSyncRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAudioPlayerPlaybackProgressSyncRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAudioPlayerPlaybackProgressSyncRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSAudioPlayerPlaybackProgressSync
-(EVSAudioPlayerPlaybackProgressSyncRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAudioPlayerPlaybackProgressSyncRequest alloc] init];
    }
    return _iflyos_request;
}
@end



@implementation EVSAudioPlayerPlaybackControlCommandRequestPayload
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id playback_resource_id = contextDict[@"playback_resource_id"];
            if (playback_resource_id && ![playback_resource_id isEqualToString:@""]) {
                self.resource_id = playback_resource_id;
            }
        }
    }
    return self;
}
@end

@implementation EVSAudioPlayerPlaybackControlCommandRequestHeader
-(NSString *) name{
    return @"playback_controller.control_command";
}

-(NSString *) request_id{
    return [NSString requestIdWithActive];
}
@end

@implementation EVSAudioPlayerPlaybackControlCommandRequest
-(EVSAudioPlayerPlaybackControlCommandRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSAudioPlayerPlaybackControlCommandRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSAudioPlayerPlaybackControlCommandRequestHeader *) header{
    if (!_header) {
        _header = [[EVSAudioPlayerPlaybackControlCommandRequestHeader alloc] init];
    }
    return _header;
}
@end

@implementation EVSAudioPlayerPlaybackControlCommand

-(EVSAudioPlayerPlaybackControlCommandRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSAudioPlayerPlaybackControlCommandRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSVideoPlayerProgressSync
-(EVSVideoPlayerProgressSyncRequest *) iflyos_request{
    if (!_iflyos_request) {
        _iflyos_request = [[EVSVideoPlayerProgressSyncRequest alloc] init];
    }
    return _iflyos_request;
}
@end

@implementation EVSVideoPlayerProgressSyncRequest
-(EVSVideoPlayerProgressSyncRequestPayload *) payload{
    if (!_payload) {
        _payload = [[EVSVideoPlayerProgressSyncRequestPayload alloc] init];
    }
    return _payload;
}

-(EVSVideoPlayerProgressSyncRequestHeader *) header{
    if (!_header) {
        _header = [[EVSVideoPlayerProgressSyncRequestHeader alloc] init];
    }
    return _header;
}

@end

@implementation EVSVideoPlayerProgressSyncRequestPayload
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *videoPlayerDict = [[EVSSqliteManager shareInstance] asynQueryVideoPlayer:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
        if (videoPlayerDict) {
            id resource_id = videoPlayerDict[@"resource_id"];
            if (resource_id) {
                self.resource_id = resource_id;
            }
            id offset = videoPlayerDict[@"offset"];
            if (offset) {
                self.offset = [offset longValue];
            }
        }
    }
    return self;
}
@end

@implementation EVSVideoPlayerProgressSyncRequestHeader

-(NSString *) name{
    return @"video_player.progress_sync";
}

-(NSString *) request_id{
    return [NSString requestIdWithAuto];
}

@end
