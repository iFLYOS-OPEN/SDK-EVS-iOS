//
//  EVSSampleQueueId.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2020/3/5.
//  Copyright © 2020 iflytek. All rights reserved.
//

#import "EVSSampleQueueId.h"

@implementation EVSSampleQueueId
-(id) initWithUrl:(NSURL*)url andCount:(int)count
{
    if (self = [super init])
    {
        self.url = url;
        self.count = count;
    }
    
    return self;
}

-(BOOL) isEqual:(id)object
{
    if (object == nil)
    {
        return NO;
    }
    
    if ([object class] != [EVSSampleQueueId class])
    {
        return NO;
    }
    
    return [((EVSSampleQueueId*)object).url isEqual: self.url] && ((EVSSampleQueueId*)object).count == self.count;
}

-(NSString*) description
{
    return [self.url description];
}
@end
