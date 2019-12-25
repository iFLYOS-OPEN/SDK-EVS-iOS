//
//  EVSAppActionCheckResult.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/11/19.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface EVSAppActionCheckResultRequestPayloadActions : NSObject
@property(assign,nonatomic) BOOL result;
@property(copy,nonatomic) NSString *action_id;
@end

@interface EVSAppActionCheckResultRequestPayload : NSObject
@property(copy,nonatomic) NSString *check_id;
@property(strong,nonatomic) NSArray *actions;
@end

@interface EVSAppActionCheckResultRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end


@interface EVSAppActionCheckResultRequest : NSObject
@property(strong,nonatomic) EVSAppActionCheckResultRequestHeader *header;
@property(strong,nonatomic) EVSAppActionCheckResultRequestPayload *payload;
@end

@interface EVSAppActionCheckResult : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAppActionCheckResultRequest *iflyos_request;
@end

@interface EVSAppActionExcuteSuccessRequestPayload : NSObject
@property(copy,nonatomic) NSString *action_id;
@property(copy,nonatomic) NSString *feedback_text;
@end

@interface EVSAppActionExcuteSuccessRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAppActionExcuteSuccessRequest : NSObject
@property(strong,nonatomic) EVSAppActionExcuteSuccessRequestHeader *header;
@property(strong,nonatomic) EVSAppActionExcuteSuccessRequestPayload *payload;
@end

@interface EVSAppActionExcuteSuccess : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAppActionExcuteSuccessRequest *iflyos_request;
@end

@interface EVSAppActionExcuteFailedRequestPayload : NSObject
@property(copy,nonatomic) NSString *action_id;
@property(copy,nonatomic) NSString *execution_id;
@property(copy,nonatomic) NSString *failure_code;
@property(copy,nonatomic) NSString *feedback_text;
@end

@interface EVSAppActionExcuteFailedRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAppActionExcuteFailedRequest : NSObject
@property(strong,nonatomic) EVSAppActionExcuteFailedRequestHeader *header;
@property(strong,nonatomic) EVSAppActionExcuteFailedRequestPayload *payload;
@end

@interface EVSAppActionExcuteFailed : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAppActionExcuteFailedRequest *iflyos_request;
@end
NS_ASSUME_NONNULL_END
