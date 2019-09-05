//
//  EVSContextProtocolModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/29.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSContextVersionProtocolModel : NSObject
@property(copy,nonatomic) NSString *version; //版本号
@end

@interface EVSContextSystemProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSContextRecognizerProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSContextSpeakerProtocolModel : EVSContextVersionProtocolModel
@property(assign,nonatomic) NSInteger volume; //音量，静音为0
@property(copy,nonatomic) NSString *type;//扬声器音量类型，取值：percent(百分比)。
@end

@interface EVSContextAudioPlayerPlaybackProtocolModel:NSObject
@property(copy,nonatomic) NSString *state;//内容播放器的状态（PLAYING: 播放中，IDLE: 空闲中 ，PAUSED: 已暂停）
@property(copy,nonatomic) NSString *resource_id;//当前播放器中播放/可播放的音频的唯一标识
@property(assign,nonatomic) NSInteger offset;//当前播放器中的资源的播放进度，以毫秒为单位
@end

@interface EVSContextAudioPlayerPlaybackMetadataProtocolModel:NSObject
@property(copy,nonatomic) NSString *title;
@property(copy,nonatomic) NSString *artist;
@property(copy,nonatomic) NSString *album;
@property(assign,nonatomic) NSInteger duration;
@end

@interface EVSContextAudioPlayerProtocolModel : EVSContextVersionProtocolModel
@property(strong,nonatomic) EVSContextAudioPlayerPlaybackProtocolModel *playback;
@end

@interface EVSContextAlarmProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSContextScreenProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSContextInterceptorProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSPlaybackControllerProtocolModel : EVSContextVersionProtocolModel

@end

@interface EVSContextProtocolModel : NSObject
@property(strong,nonatomic) EVSContextSystemProtocolModel *system;
@property(strong,nonatomic) EVSContextRecognizerProtocolModel *recognizer;
@property(strong,nonatomic) EVSContextSpeakerProtocolModel *speaker;
@property(strong,nonatomic) EVSContextAudioPlayerProtocolModel *audio_player;
@property(strong,nonatomic) EVSContextAlarmProtocolModel *alarm;
@property(strong,nonatomic) EVSContextScreenProtocolModel *screen;
@property(strong,nonatomic) EVSContextInterceptorProtocolModel *interceptor;
@property(strong,nonatomic) EVSPlaybackControllerProtocolModel *playback_controller;
//获取header json字典
+(NSDictionary *) getJSON;
@end
NS_ASSUME_NONNULL_END
