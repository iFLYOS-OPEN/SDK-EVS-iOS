//
//  EVS+NSString.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSUInteger,request_execute_status){
    NOT = 0 ,//不执行
    QUEUE = 1 << 0 ,//排队执行
    EXECUTE = 2 << 0 //立刻执行
};
NS_ASSUME_NONNULL_BEGIN

@interface NSString(EVS_NSString)
/**
 *  判断两个requestId，决定策略是执行还是不执行
 *  newRequestId : 最新的requestId
 */
-(request_execute_status) requestExecute:(NSString *) newRequestId;
/**
 *  判断是否主动请求ID类型
 */
-(BOOL) isActiveRequestIdType;

/**
 *  判断是否主动请求ID类型
 */
-(BOOL) isAutoRequestIdType;
/**
 *  获取主动请求 ID（主动：manual-xxxxxxxxxxx）
 */
+(NSString *) requestIdWithActive;

/**
 *  获取被动请求 ID（主动：auto-xxxxxxxxxxx）
 */
+(NSString *) requestIdWithAuto;
/**
 *  获取请求id
 *  prefix : 前缀（主动：manual-xxxxxxxxxxx）
 */
+(NSString *) requestId:(NSString *) prefix;

//根据reqeuestId获取时间戳
-(NSString *) getRequestIdTimestamp;











//获取UUID随机字符串
+(NSString *) randomString;
/**
 *  根据原字符串替的目标字符串换成需要替换的字符串
 *  origStr : 原字符串
 *  targetStr : 目标字符串
 *  replaceStr : 需要替换的字符串
 *  return : 替换后的字符串
 */
+(NSString *) stringSubstitution:(NSString *) origStr targetStr:(NSString *)targetStr replaceStr:(NSString *) replaceStr;
/**
 *  根据名字从URL取value
 */
+ (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url;

- (NSString *)SHA256;

- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key;

-(NSDictionary *) JSONStringWithDictionary;
-(NSArray *) JSONStringWithArray;
-(NSString *) getUUIDFormatter2;
/**
 *  创建个性json
 */
+(NSString *) createUserScript;
//解析BLE 蓝牙ad信息(厂商标识)
-(NSString *) getBLEAdvertFactoryFlag;
//解析BLE 蓝牙ad信息（clientId）
-(NSString *) getBLEAdvertClientId;
@end

NS_ASSUME_NONNULL_END
