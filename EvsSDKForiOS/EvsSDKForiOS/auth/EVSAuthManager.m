//
//  EVSAuthManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSAuthManager.h"
#import "EVSHeader.h"
#import "EVSAuthViewController.h"
#import "EVSRequestHeader.h"
@implementation EVSAuthManager
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSAuthManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}
/**
 *  1.设备申请授权
 */
-(void) authUserCode:(NSString *) deviceId
            clientId:(NSString *) clientId{
    EVSLog(@"auth evs...");
    NSString *authrization = [[NSUserDefaults standardUserDefaults] objectForKey:k_AUTHORIZATION];
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    
    NSString *urlContext = [NSString stringSubstitution:AUTH_USER_CODE targetStr:@"{http_schema}" replaceStr:HTTP_SCHEMA];
    urlContext = [NSString stringSubstitution:urlContext targetStr:@"{env}" replaceStr:ENV];
    if (clientId){
        urlContext = [NSString stringSubstitution:urlContext targetStr:@"{client_id}" replaceStr:clientId];
    }
    if (deviceId) {
        NSDictionary *scopeDataDict = @{@"user_ivs_all":@{@"device_id":deviceId}};
        NSString *scopeDataStr = [scopeDataDict convertToJsonData];
        urlContext = [NSString stringSubstitution:urlContext targetStr:@"{scope_data}" replaceStr:scopeDataStr];
    }
    NSString *encodedValue = [urlContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    EVSLog(@"auth url : %@",encodedValue);
    //加载列表逻辑
    IFLYOSHTTPRequest *request = [[IFLYOSHTTPRequest alloc] init];
    request.dataModel.contextUrl = encodedValue;
    request.dataModel.requestType = POST;
    request.dataModel.headers = header;
    [request request:^(IFLYOSDataModel * _Nonnull successDataModel) {
        EVSLog(@"auth request statusCode: %li",successDataModel.statusCode);
        NSDictionary *dict = successDataModel.resultDataDictionary;
        if (dict) {
            EVSAuthUserCodeModel *userCodeModel = [EVSAuthUserCodeModel mj_objectWithKeyValues:dict];
            [self authDevice:userCodeModel];
            [self authToken:clientId device_code:userCodeModel.device_code];
        }
    } progress:nil error:^(IFLYOSDataModel * _Nonnull failDataModel) {
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] isAuth:NO errorCode:failDataModel.statusCode error:failDataModel.error];
        EVSLog(@"auth request statusCode: %li",failDataModel.statusCode);
    } newServerAddress:@""];
}

/**
 *  2.用户授权（web页）
 */
-(void) authDevice:(EVSAuthUserCodeModel *) userCodeModel{
    NSString *verificationUri = userCodeModel.verification_uri;
    NSString *userCode = userCodeModel.user_code;
    
    NSString *authUrl = [NSString stringSubstitution:AUTH_DEVICE_CODE targetStr:@"{auth_url}" replaceStr:@"https://auth.iflyos.cn/oauth/device"];
    authUrl = [NSString stringSubstitution:authUrl targetStr:@"{user_code}" replaceStr:userCode];
    EVSLog(@"auth url : %@",authUrl);
    
    if (authUrl) {
        UIViewController *topController = [EVSApplication presentingVC];
        
        EVSAuthViewController *authVc = [[EVSAuthViewController alloc] init];
        authVc.authUrl = authUrl;
        
        UINavigationController *navigationVc = [[UINavigationController alloc] initWithRootViewController:authVc];
        [topController presentViewController:navigationVc animated:YES completion:^{
            
        }];
    }
}

/**
 *  3.用户授权（轮询）
 */
-(void) authToken:(NSString *)clientId device_code:(NSString *) device_code{
    EVSLog(@"auth access token ...");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.isStopLoop = NO;
        while (!self.isStopLoop) {
            NSString *urlContext = [NSString stringSubstitution:AUTH_ACCESS_TOKEN targetStr:@"{http_schema}" replaceStr:HTTP_SCHEMA];
            urlContext = [NSString stringSubstitution:urlContext targetStr:@"{env}" replaceStr:ENV];
            NSString *encodedValue = [urlContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:@"urn:ietf:params:oauth:grant-type:device_code" forKey:@"grant_type"];
            if (clientId) {
                [params setObject:clientId forKey:@"client_id"];
            }
            if (device_code) {
                [params setObject:device_code forKey:@"device_code"];
            }
            __weak typeof(self) weakSelf = self;
            //加载列表逻辑
            IFLYOSHTTPRequest *request = [[IFLYOSHTTPRequest alloc] init];
            request.dataModel.contextUrl = encodedValue;
            request.dataModel.requestType = POST;
            request.dataModel.params = params;
            [request request:^(IFLYOSDataModel * _Nonnull successDataModel) {
                EVSLog(@"auth success statusCode: %li",successDataModel.statusCode);
                NSDictionary *dict = successDataModel.resultDataDictionary;
                if (dict) {
                    EVSAuthModel *authModel = [EVSAuthModel mj_objectWithKeyValues:dict];
                    [authModel save];
                    [self connectEVS];
                    self.isStopLoop = YES;
                    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] isAuth:YES errorCode:0 error:nil];
                }
            } progress:nil error:^(IFLYOSDataModel * _Nonnull failDataModel) {
                NSDictionary *dict = failDataModel.resultDataDictionary;
                if(dict){
                    NSString *error = dict[@"error"];
                    if ([error isEqualToString:@"authorization_pending"]){
                        //用户未授权，等待下一次轮循请求
                        self.isStopLoop = NO;
                       
                    }else if ([error isEqualToString:@"expired_token"]){
                        //授权码过期，用户仍未授权
                        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] isAuth:NO errorCode:failDataModel.statusCode error:failDataModel.error];
                    }else if ([error isEqualToString:@"access_denied"]){
                        //用户拒绝授权
                        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] isAuth:NO errorCode:failDataModel.statusCode error:failDataModel.error];
                    }
                    EVSLog(@"auth waiting statusCode: %li code:%@",failDataModel.statusCode,error);
                }
                
            } newServerAddress:@""];
            
            [NSThread sleepForTimeInterval:3.0f];
            
        }
        
    });
}

/**
 *  连接EVS
 */
-(void) connectEVS{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    [[EVSSqliteManager shareInstance] queryConfig:deviceId tableName:CONFIG_TABLE_NAME callback:^(NSDictionary * _Nonnull dict) {
        if (dict) {
            NSString *access_token = dict[@"access_token"];
            NSString *ws_url = dict[@"ws_url"];
            [EVSWebscoketManager connectWebsocket:access_token wsURL:ws_url];
        }
    }];
}

/**
 *  检查token时效，时效性重新申请，并刷新数据库token
 */
-(void) checkTokenVaild{
    //计算时效性
    EVSAuthModel *authModel = [EVSAuthModel loadModel];
    long long expiresCostTimeSp = (authModel.created_at + authModel.expires_in);
    long long nowTimeSp = [[EVSDateUtils dateConversionTimestamp:[NSDate date]] longLongValue];
    
    if(!authModel.refresh_token){
        return;
    }
    
    if (expiresCostTimeSp - nowTimeSp < 3600) {
        EVSLog(@"token refresh...");
        NSString *urlContext = [NSString stringSubstitution:AUTH_ACCESS_TOKEN targetStr:@"{http_schema}" replaceStr:HTTP_SCHEMA];
        urlContext = [NSString stringSubstitution:urlContext targetStr:@"{env}" replaceStr:ENV];
        NSString *encodedValue = [urlContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"refresh_token" forKey:@"grant_type"];
        if (authModel.refresh_token) {
            [params setObject:authModel.refresh_token forKey:@"refresh_token"];
        }
        
        //重新刷新token
        IFLYOSHTTPRequest *request = [[IFLYOSHTTPRequest alloc] init];
        request.dataModel.contextUrl = encodedValue;
        request.dataModel.requestType = POST;
        request.dataModel.params = params;
        IFLYOSDataModel *dataModel = [request synRequest];
        if (dataModel.statusCode == REQUEST_SUCCESS_CODE && dataModel.resultDataDictionary) {
            EVSLog(@"refresh token success ...");
            NSDictionary *dict = dataModel.resultDataDictionary;
            if (dict) {
                EVSAuthModel *authModel = [EVSAuthModel mj_objectWithKeyValues:dict];
                [authModel save];
            }
        }else{
            EVSLog(@"refresh token fail statusCode: %li",dataModel.statusCode);
        }
    }
}
@end
