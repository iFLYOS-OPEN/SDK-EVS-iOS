//
//  IFLYOSDataModel.m
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import "IFLYOSDataModel.h"
#import "EVSHeader.h"
#import "EVSConfig.h"
@implementation IFLYOSDataModel
-(id) init{
    if (self == [super init ]){
        return self;
    }
    return nil;
}
-(void) load{
    self.serverAddress = [EVSConfig shareInstance].serverAddress;
    self.requestTimeout = [EVSConfig shareInstance].requestTimeout;
}


-(NSString *) authorization{
    NSString *az = [[NSUserDefaults standardUserDefaults] objectForKey:k_AUTHORIZATION];
    if (az) {
        NSString *strUpper = [az substringToIndex:1];
        NSString *strOrig = [az substringFromIndex:1];
        az = [[strUpper uppercaseString] stringByAppendingString:strOrig];;
    }
    return az;
}

-(NSString *) accessToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:k_ACCESS_TOKEN];
}

-(NSString *) tokenType{
    return [[NSUserDefaults standardUserDefaults] objectForKey:k_TOKEN_TYPE];
}

-(NSString *) refreshTken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:k_REFRESH_TOKEN];
}

-(long long) expiresIn{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:k_EXPIRES_IN] longLongValue];
}

-(long long) createdAt{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:k_CREATED_AT] longLongValue];
}
@end
