//
//  IFLYOSDataModel.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSUInteger,HTTP_REQUEST_TYPE){
    GET = 0,//get
    POST = 1 << 0,//post
    PUT = 2 << 0,//put
    DELETE = 3 << 0//delete
};
@interface IFLYOSDataModel : NSObject
//请求地址
@property (nonatomic,copy) NSString *serverAddress;
//请求头
@property (nonatomic,copy) NSDictionary *headers;
//请求参数
@property (nonatomic) id params;
//网络超时
@property(nonatomic,assign) NSInteger requestTimeout;
//网络请求code
@property (nonatomic,assign) NSInteger statusCode;
//错误信息
@property (nonatomic,copy) NSString *errorStr;
//错误对象
@property (nonatomic,copy) NSError *error;
//服务器回调错误码
@property (nonatomic,assign) NSInteger code;
//模块名
@property (nonatomic,copy) NSString *modelName;
//模块url
@property (nonatomic,copy) NSString *modelUrl;
//完整请求url
@property (nonatomic,copy) NSString *fullUrl;
//url上下文 , /xx/xx
@property (nonatomic,copy) NSString *contextUrl;
//模块id
@property (nonatomic,copy) NSString *modelId;
//接口名
@property (nonatomic,copy) NSString *interfaceName;
//日志标记
@property (nonatomic,copy) NSString *logMark;
//version
@property (nonatomic,copy) NSString *version;

//请求类型（get,post）
@property(nonatomic) HTTP_REQUEST_TYPE requestType;
//回调结果(返回id类型)
@property(nonatomic) id resultData;
//回调结果(返回字典格式)
@property(nonatomic) NSDictionary* resultDataDictionary;
//回调结果(返回Array)
@property(nonatomic) NSArray* resultDataJSONArray;
//回调结果(返回json字符串)
@property(nonatomic) NSString* resultDataJSONStr;

//访问token
@property(nonatomic,copy) NSString *accessToken;
//Authorization 认证许可令牌（type+token）
@property(nonatomic,copy) NSString *authorization;
//token类型
@property(nonatomic,copy) NSString *tokenType;
//刷新token
@property(nonatomic,copy) NSString *refreshTken;
//令牌过期时间
@property(nonatomic) long long expiresIn;
//令牌创建时间
@property(nonatomic) long long createdAt;

-(void) load;
@end
