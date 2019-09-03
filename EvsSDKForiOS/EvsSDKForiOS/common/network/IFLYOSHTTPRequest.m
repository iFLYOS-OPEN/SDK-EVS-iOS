//
//  IFLYOSHTTPRequest.m
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import "IFLYOSHTTPRequest.h"
#import "EVSHeader.h"

@interface IFLYOSHTTPRequest()
//网络请求实体类
@property(nonatomic,strong) AFHTTPSessionManager *manager;
@property(nonatomic,strong) AFURLSessionManager *urlManager;

@end

@implementation IFLYOSHTTPRequest
-(id) init{
    if(self == [super init]){
        [self cleanDataModel];
        self.manager = [[AFHTTPSessionManager alloc]init];
        [self initSessionManager];
        return self;
    }
    return nil;
}

-(void) cleanDataModel{
    if (self.dataModel != nil) {
        self.dataModel = nil;
    }
    self.dataModel = [[IFLYOSDataModel alloc] init];
    [self.dataModel load];
}
-(void) initSessionManager{
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = self.dataModel.requestTimeout;
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [self.manager.requestSerializer setValue:CONTENT_TYPE_JSON_TEXT forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer setValue:CONTENT_TYPE_JSON_TEXT forHTTPHeaderField:@"Content-Type"];
    // 请求参数类型
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"multipart/form-data", nil];
}

//自定义http协议管理器
-(void) initUrlManager{
    self.urlManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self.urlManager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"multipart/form-data", nil];
    self.urlManager.responseSerializer = responseSerializer;
}

-(void) setMultipartType:(NSString *)multipartType{
    _multipartType = multipartType;
    [self initUrlManager];
}

//自定义http协议头和body
-(NSData *) multipartImageBody:(NSData *) imageData imageName:(NSString *)imageName{
    NSMutableData *body = [[NSMutableData alloc]init];//请求体数据
    //上传格式开始头
    NSData *bundaryHeader = [[NSString stringWithFormat:@"--%@\r\n",CONTENT_TYPE_MULITPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding];
    [body appendData:bundaryHeader];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"avatar\"; filename=\"%@\"\r\n",imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];//图像
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",CONTENT_TYPE_MULITPART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    //结束
    return [body copy];
}

//同步请求
-(IFLYOSDataModel *) synRequest{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",self.dataModel.serverAddress?self.dataModel.serverAddress:@"",self.dataModel.contextUrl];
    self.manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    if(self.dataModel.requestType == GET){
        [self.manager GET:requestUrl parameters:self.dataModel.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            dispatch_semaphore_signal(semaphore);
        }];
    }else if(self.dataModel.requestType == POST){
        [self.manager POST:requestUrl parameters:self.dataModel.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            dispatch_semaphore_signal(semaphore);
        }];
    }
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return self.dataModel;
}

//同步请求(扩展)
-(IFLYOSDataModel *) synRequest:(NSString *) newServerAddress{
    if (newServerAddress) {
        self.dataModel.serverAddress = newServerAddress;
    }
    return [self synRequest];
}

/**
 *  异步请求(扩展)
 */
-(void) request:(void (^)(IFLYOSDataModel * _Nonnull)) successDataModel progress:(void (^)(NSProgress * _Nonnull))downloadProgress error:(void (^)(IFLYOSDataModel * _Nonnull))failDataModel newServerAddress:(NSString *) newServerAddress{
    if (newServerAddress) {
        self.dataModel.serverAddress = newServerAddress;
    }
    [self request:successDataModel progress:downloadProgress error:failDataModel];
}

//异步请求
-(void) request:(void (^)(IFLYOSDataModel * _Nonnull)) successDataModel progress:(void (^)(NSProgress * _Nonnull))downloadProgress error:(void (^)(IFLYOSDataModel * _Nonnull))failDataModel{
    
    if (!self.dataModel.serverAddress && !self.dataModel.contextUrl ){
        return ;
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",self.dataModel.serverAddress,self.dataModel.contextUrl];
    
    NSDictionary *headers = [self.dataModel headers];
    NSDictionary *params = [self.dataModel params];
    
    EVSLog(@"http request [url:%@] [%@:%@] [%@:%@]",requestUrl,@"header",headers,@"param",params);
    
    //设置请求头
    for (NSString *key in self.dataModel.headers){
        [self.manager.requestSerializer setValue:self.dataModel.headers[key] forHTTPHeaderField:key];
    }
    
    if(self.dataModel.requestType == GET){
        [self.manager GET:requestUrl parameters:self.dataModel.params progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            successDataModel(self.dataModel);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            failDataModel(self.dataModel);
        }];
    }else if(self.dataModel.requestType == POST){
        [self.manager POST:requestUrl parameters:self.dataModel.params progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            successDataModel(self.dataModel);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            failDataModel(self.dataModel);
        }];
    }else if(self.dataModel.requestType == DELETE){
        [self.manager DELETE:requestUrl parameters:self.dataModel.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            successDataModel(self.dataModel);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            [self showFailTips:self.dataModel];
            failDataModel(self.dataModel);
        }];
    }else if(self.dataModel.requestType == PUT){
        [self.manager PUT:requestUrl parameters:self.dataModel.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //成功回调
            [self successDataHandler:responseObject task:task];
            successDataModel(self.dataModel);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //失败回调
            [self failDataHandler:task error:error];
            failDataModel(self.dataModel);
        }];
    }
}



//成功回调处理
-(void) successDataHandler:(id) responseObject task:(NSURLSessionDataTask *) task{
    //成功回调
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
    self.dataModel.statusCode = httpResponse.statusCode;
    self.dataModel.resultData = responseObject;
    self.dataModel.resultDataDictionary = [self dataWithObject:responseObject classType:[NSDictionary class]];
    self.dataModel.resultDataJSONArray = [self dataWithObject:responseObject classType:[NSArray class]];
    self.dataModel.resultDataJSONStr = [self dataWithObject:responseObject classType:[NSString class]];
}

//失败回调处理
-(void) failDataHandler:(NSURLSessionDataTask *) task error:(NSError *) error{
    NSData *data = error.userInfo[AFNETWORK_ERROR_DATA];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
    self.dataModel.resultData = data;
    self.dataModel.resultDataDictionary = [data JSONDataWithDictionary];
    self.dataModel.resultDataJSONArray = [data JSONDataWithArray];
    self.dataModel.resultDataJSONStr = [data JSONDataWithString];
    self.dataModel.statusCode = httpResponse.statusCode;
    self.dataModel.error = error;
    self.dataModel.errorStr = error.localizedDescription;
    [self showFailTips:self.dataModel];
}

/**
 * 根据classType转数据格式
 *  data : 传入的数据
 *  cls  : 要转换的数据类型
 */
-(id) dataWithObject:(id) data classType:(Class) cls{
    
    if ([data isKindOfClass:cls]){
        return data;
    }
    
    if([data isKindOfClass:[NSData class]]){
        NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        EVSLog(@"result : %@",receiveStr);
        if( cls == [NSDictionary class]){
            //NSData转NSDictionary
            return [data JSONDataWithDictionary];
        }
        if( cls == [NSArray class]){
            //NSData转NSArray
            return [data JSONDataWithDictionary];
        }
        if( cls == [NSString class]){
            //NSData转NSString
            return [data JSONDataWithDictionary];
        }
    }
    return nil;
}

//错误信息集中处理
-(void) showFailTips:(IFLYOSDataModel *) dataModel{
    if (self.dataModel.statusCode >= REQUEST_SERVER_NOT_RESPONSE) {
       
    }else if(self.dataModel.resultDataJSONStr!=nil){
        NSDictionary *dict = self.dataModel.resultDataDictionary;
        if(dict){
            if ([dict[@"message"] isKindOfClass:[NSNull class]]) {
                return ;
            }
           
        }else{
            
        }
    }else if (self.dataModel.errorStr) {
       
    }
    else if (self.dataModel.statusCode == REQUEST_CLIENT_ERROR_CODE) {
       
    }else if (self.dataModel.statusCode == REQUEST_NO_AUTHORIZATION_CODE) {
      
    }else if (self.dataModel.statusCode == REQUEST_AUTHORIZATION_LIMITS) {
        
    }
}

@end
