//
//  IFLYOSHTTPRequest.h
//  iflyosSDK
//
//  Created by admin on 2018/8/24.
//  Copyright © 2018年 iflyosSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFLYOSDataModel.h"

#define CONTENT_TYPE_MULITPART_BOUNDARY @"----WebKitFormBoundary7MA4YWxkTrZu0gW"
#define CONTENT_TYPE_MULTIPART_FORM_DATA @"multipart/form-data; " // 服务器接收类型data
#define CONTENT_TYPE_JSON_TEXT @"application/json; charset=utf-8" // 服务器接收类型json
#define AFNETWORK_ERROR_DATA @"com.alamofire.serialization.response.error.data"//获取错误的response信息
@interface IFLYOSHTTPRequest : NSObject
//请求数据
@property(nonatomic,strong) IFLYOSDataModel *dataModel;
//服务器接收类型（默认：json）
@property(nonatomic,copy) NSString *multipartType;

/**
 *  异步请求(扩展)
 */
-(void) request:(void (^)(IFLYOSDataModel *)) successDataModel progress:(void (^)(NSProgress *))downloadProgress error:(void (^)(IFLYOSDataModel *))failDataModel newServerAddress:(NSString *) newServerAddress;

/**
 *  异步请求
 */
-(void) request:(void (^)(IFLYOSDataModel *)) successDataModel progress:(void (^)(NSProgress *))downloadProgress error:(void (^)(IFLYOSDataModel *))failDataModel;

/**
 * 同步请求(扩展)
 */
-(IFLYOSDataModel *) synRequest:(NSString *) newServerAddress;

/**
 * 同步请求
 */
-(IFLYOSDataModel *) synRequest;
@end
