//
//  EVSRecognizer.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/30.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSBaseProtocolModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSRecognizerRequestHeader:NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSRecognizerRequestPayloadWakeup:NSObject
@property(assign,nonatomic) NSInteger score;
@property(assign,nonatomic) NSInteger start_index_in_samples;
@property(assign,nonatomic) NSInteger end_index_in_samples;
@property(copy,nonatomic) NSString *word;
@property(copy,nonatomic) NSString *prompt;
@end

@interface EVSRecognizerRequestPayload:NSObject
//取值: FAR_FIELD: 远场识别 | CLOSE_TALK: 近场识别
@property(copy,nonatomic) NSString *profile;
//如果接收到 name 为 recognizer.expect_reply 的响应的话，重新打开麦克风识别的时候，需要填入响应中返回的 reply_key 中的取值
@property(copy,nonatomic) NSString *reply_key;
//AUDIO_L16_RATE_16000_CHANNELS_1: PCM 16bit 16K的录音 | AUDIO_OPUS_RATE_16000_CHANNELS_1: OPUS 格式
@property(copy,nonatomic) NSString *format;
//是否用云端VAD（语音边界检测）
@property(assign,nonatomic) BOOL enable_vad;
//唤醒（使用讯飞的麦克风阵列，必须填写，其他厂商提供的阵列可不填）
@property(strong,nonatomic) EVSRecognizerRequestPayloadWakeup *iflyos_wake_up;
@end

@interface EVSRecognizerRequest : NSObject
@property(strong,nonatomic) EVSRecognizerRequestHeader *header;
@property(strong,nonatomic) EVSRecognizerRequestPayload *payload;
@end

//语音请求
@interface EVSRecognizer : EVSBaseProtocolModel
@property(strong,nonatomic) EVSRecognizerRequest *iflyos_request;
@end


//文本请求
@interface EVSRecognizerTextInRequestHeader:NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSRecognizerTextInRequestPayload:NSObject
@property(copy,nonatomic) NSString *query;
@property(assign,nonatomic) BOOL with_tts;
@property(copy,nonatomic) NSString *reply_key;
@end

@interface EVSRecognizerTextInRequest : NSObject
@property(strong,nonatomic) EVSRecognizerTextInRequestHeader *header;
@property(strong,nonatomic) EVSRecognizerTextInRequestPayload *payload;
@end

@interface EVSRecognizerTextIn : EVSBaseProtocolModel
@property(strong,nonatomic) EVSRecognizerTextInRequest *iflyos_request;
@end
NS_ASSUME_NONNULL_END
