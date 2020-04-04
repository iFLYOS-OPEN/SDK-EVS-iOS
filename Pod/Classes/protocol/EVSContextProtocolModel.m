//
//  EVSContextProtocolModel.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSContextProtocolModel.h"
#import "EVSHeader.h"
@implementation EVSContextVersionProtocolModel
-(NSString *) version{
    if (_version){
        return _version;
    }
    return @"1.0";
}
@end
@implementation EVSContextAppActionModel
//-(NSString *) foreground_app{
//    return @"com.qiyi.video.speaker";
//}
//
//-(NSString *) activity{
//    return @"com.qiyi.video.speaker";
//}
@end

@implementation EVSContextVideoPlayerModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *videoPlayerDict = [[EVSSqliteManager shareInstance] asynQueryVideoPlayer:deviceId tableName:VIDEO_PLAYER_TABLE_NAME];
        if (videoPlayerDict) {
            id state = videoPlayerDict[@"state"];
            if (state) {
                self.state = state;
            }
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

@implementation EVSContextProtocolModel
-(EVSContextSystemProtocolModel *) system{
    if (!_system) {
        _system = [[EVSContextSystemProtocolModel alloc] init];
    }
    return _system;
}

-(EVSContextRecognizerProtocolModel *) recognizer{
    if (!_recognizer) {
        _recognizer = [[EVSContextRecognizerProtocolModel alloc] init];
    }
    return _recognizer;
}

-(EVSContextSpeakerProtocolModel *) speaker{
    if (!_speaker) {
        _speaker = [[EVSContextSpeakerProtocolModel alloc] init];
    }
    return _speaker;
}

-(EVSContextAudioPlayerProtocolModel *) audio_player{
    if (!_audio_player) {
        _audio_player = [[EVSContextAudioPlayerProtocolModel alloc] init];
    }
    return _audio_player;
}

-(EVSContextScreenProtocolModel *) screen{
    if (!_screen) {
        _screen = [[EVSContextScreenProtocolModel alloc] init];
    }
    return _screen;
}

-(EVSContextAlarmProtocolModel *) alarm{
    if (!_alarm) {
        _alarm = [[EVSContextAlarmProtocolModel alloc] init];
    }
    return _alarm;
}

-(EVSContextInterceptorProtocolModel *) interceptor{
    if (!_interceptor) {
        _interceptor = [[EVSContextInterceptorProtocolModel alloc] init];
    }
    return _interceptor;
}

-(EVSPlaybackControllerProtocolModel *) playback_controller{
    if (!_playback_controller) {
        _playback_controller = [[EVSPlaybackControllerProtocolModel alloc] init];
    }
    return _playback_controller;
}

-(EVSContextAppActionModel *) app_action{
    if (!_app_action) {
        _app_action = [[EVSContextAppActionModel alloc] init];
    }
    return _app_action;
}

-(EVSContextVideoPlayerModel *) video_player{
    if (!_video_player) {
        _video_player = [[EVSContextVideoPlayerModel alloc] init];
    }
    return _video_player;
}

-(EVSContextTemplateProtocolModel *) m_template{
    if (!_m_template) {
        _m_template = [[EVSContextTemplateProtocolModel alloc] init];
    }
    return _m_template;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"m_template":@"template"};
}

+(NSDictionary *) getJSON{
    EVSContextProtocolModel *model = [[EVSContextProtocolModel alloc] init];
    NSDictionary *jsonDict = model.mj_keyValues;
    return jsonDict;
}

@end

@implementation EVSContextSystemProtocolModel

@end

@implementation EVSContextRecognizerProtocolModel

@end

@implementation EVSContextSpeakerProtocolModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id volume = contextDict[@"speaker_volume"];
            if (volume) {
                self.volume = [volume integerValue];
            }
            id type = contextDict[@"speaker_volume_type"];
            if (type) {
                self.type = type;
            }
        }
    }
    return self;
}
@end

@implementation EVSContextAudioPlayerProtocolModel
-(EVSContextAudioPlayerPlaybackProtocolModel *) playback{
    if (!_playback) {
        _playback = [[EVSContextAudioPlayerPlaybackProtocolModel alloc] init];
    }
    return _playback;
}
@end

@implementation EVSContextAudioPlayerPlaybackProtocolModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id state = contextDict[@"playback_state"];
            if (state) {
                self.state = state;
            }
            id resource_id = contextDict[@"playback_resource_id"];
            if (resource_id && ![resource_id isEqualToString:@""]) {
                self.resource_id = resource_id;
            }
            id offset = contextDict[@"playback_offset"];
            if (offset) {
                self.offset = [offset integerValue];
            }
        }
    }
    return self;
}
@end

@implementation EVSContextAudioPlayerPlaybackMetadataProtocolModel
-(id) init{
    if (self == [super init]) {
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        NSDictionary *contextDict = [[EVSSqliteManager shareInstance] asynQueryContext:deviceId tableName:CONTEXT_TABLE_NAME];
        if (contextDict) {
            id title = contextDict[@"title"];
            if (title) {
                self.title = [title string];
            }
            id artist = contextDict[@"artist"];
            if (artist) {
                self.artist = [artist string];
            }
            id album = contextDict[@"album"];
            if (album) {
                self.album = [artist string];
            }
            id duration = contextDict[@"duration"];
            if (duration) {
                self.duration = [duration integerValue];
            }
        }
    }
    return self;
}
@end


@implementation EVSContextAlarmProtocolModel

@end

@implementation EVSContextScreenProtocolModel

@end

@implementation EVSContextInterceptorProtocolModel

@end

@implementation EVSPlaybackControllerProtocolModel

@end

@implementation EVSContextTemplateProtocolModel
-(NSString *) version{
    return @"1.2";
}
@end
