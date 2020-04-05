//
//  IMAKit.h
//  IMAKit
//
//  Created by 周经伟 on 2019/11/6.
//  Copyright © 2019 iflytek. All rights reserved.
//  IFLYOS MobileAccessory(IMA) Kit

#import <Foundation/Foundation.h>

#import "IMAManager.h"

@interface IMAKit : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;
-(void) setToken:(NSString *) token;
-(NSString *) getToken;
-(NSString *) getAuthorization;

-(void) getClientInfo:(NSString *) clientId
           statusCode:(void (^)(NSInteger)) statusCode
       requestSuccess:(void (^)(id _Nonnull)) successData
          requestFail:(void (^)(id _Nonnull)) failData;
@end
