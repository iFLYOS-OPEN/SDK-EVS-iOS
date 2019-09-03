//
//  EVSAudioPlayerTTS.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface EVSAudioPlayerTTSTextInRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAudioPlayerTTSTextInRequestPayload : NSObject
@property(copy,nonatomic) NSString *text;
@end

@interface EVSAudioPlayerTTSTextInRequest : NSObject
@property(strong,nonatomic) EVSAudioPlayerTTSTextInRequestHeader *header;
@property(strong,nonatomic) EVSAudioPlayerTTSTextInRequestPayload *payload;
@end

@interface EVSAudioPlayerTTSTextIn : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAudioPlayerTTSTextInRequest *iflyos_request;//文本合成
@end

@interface EVSAudioPlayerTTS : EVSBaseProtocolModel

@end

//TTS同步
@interface EVSAudioPlayerTTSProgressSyncRequestHeader:NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAudioPlayerTTSProgressSyncRequestPayload:NSObject
@property(copy,nonatomic) NSString *type;
@property(copy,nonatomic) NSString *resource_id;
@end

@interface EVSAudioPlayerTTSProgressSyncRequest:NSObject
@property(strong,nonatomic) EVSAudioPlayerTTSProgressSyncRequestHeader *header;
@property(strong,nonatomic) EVSAudioPlayerTTSProgressSyncRequestPayload *payload;
@end

@interface EVSAudioPlayerTTSProgressSync : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAudioPlayerTTSProgressSyncRequest *iflyos_request;//文本合成
@end

NS_ASSUME_NONNULL_END
