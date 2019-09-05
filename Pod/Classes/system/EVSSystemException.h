//
//  EVSSystemException.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/9.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVSSystemExceptionRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSSystemExceptionRequestPayload : NSObject
@property(copy,nonatomic) NSString *type;//错误类型，crash发生的地方，比如audio_player, recognizer, internal等, 你可以自定义
/**
 *  错误代码,自定义
 */
@property(copy,nonatomic) NSString *code;
@property(copy,nonatomic) NSString *message;//错误内容
@end

@interface EVSSystemExceptionRequest : NSObject
@property(strong,nonatomic) EVSSystemExceptionRequestHeader *header;
@property(strong,nonatomic) EVSSystemExceptionRequestPayload *payload;
@end

@interface EVSSystemException : EVSBaseProtocolModel
@property(strong,nonatomic) EVSSystemExceptionRequest *iflyos_request;//错误请求
@end

NS_ASSUME_NONNULL_END
