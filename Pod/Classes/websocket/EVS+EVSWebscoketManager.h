//
//  EVS+EVSWebscoketManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSWebscoketManager.h"
#import "EVSResponseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface EVSWebscoketManager(EVS_EVSWebscoketManagerCategory)
-(void) lastResponseProcessor:(EVSResponseModel *) responseModel;
@end

NS_ASSUME_NONNULL_END
