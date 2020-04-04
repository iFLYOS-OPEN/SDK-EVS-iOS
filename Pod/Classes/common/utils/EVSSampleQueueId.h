//
//  EVSSampleQueueId.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2020/3/5.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSSampleQueueId : NSObject
@property (readwrite) int count;
@property (readwrite) NSURL* url;

-(id) initWithUrl:(NSURL*)url andCount:(int)count;

@end

NS_ASSUME_NONNULL_END
