//
//  EVSSystemStateSync.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/9.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EVSSystemStateSyncRequestHeader : NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSSystemStateSyncRequestPayload : NSObject
@end

@interface EVSSystemStateSyncRequest : NSObject
@property(strong,nonatomic) EVSSystemStateSyncRequestHeader *header;
@property(strong,nonatomic) EVSSystemStateSyncRequestPayload *payload;
@end

@interface EVSSystemStateSync : EVSBaseProtocolModel
@property(strong,nonatomic) EVSSystemStateSyncRequest *iflyos_request;//错误请求
@end

NS_ASSUME_NONNULL_END
