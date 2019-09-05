//
//  EVSAuthModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSAuthModel : NSObject
@property(copy,nonatomic) NSString *authorization;
@property(copy,nonatomic) NSString *token_type;
@property(copy,nonatomic) NSString *access_token;
@property(copy,nonatomic) NSString *refresh_token;
@property(assign,nonatomic) long long expires_in;
@property(assign,nonatomic) long long created_at;
+(EVSAuthModel *) loadModel;
-(void) save;
@end

@interface EVSAuthUserCodeModel : NSObject
@property(copy,nonatomic) NSString *verification_uri;
@property(copy,nonatomic) NSString *user_code;
@property(copy,nonatomic) NSString *interval;
@property(copy,nonatomic) NSString *expires_in;
@property(copy,nonatomic) NSString *device_code;
@end
NS_ASSUME_NONNULL_END
