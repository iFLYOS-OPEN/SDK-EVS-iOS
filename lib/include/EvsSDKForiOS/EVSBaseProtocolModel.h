//
//  EVSBaseProtocolModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EVSHeaderProtocolModel;
@class EVSContextProtocolModel;
NS_ASSUME_NONNULL_BEGIN

@interface EVSBaseProtocolModel : NSObject
@property(strong,nonatomic) EVSHeaderProtocolModel *iflyos_header;
@property(strong,nonatomic) EVSContextProtocolModel *iflyos_context;
-(NSDictionary *) getJSON;
@end

NS_ASSUME_NONNULL_END
