//
//  EVS+NSString.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVS+NSString.h"
#import "EVSHeader.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
@implementation NSString(EVS_NSString)
/**
 *  判断两个requestId，决定策略是执行还是不执行
 *  newRequestId : 最新的requestId
 */
-(request_execute_status) requestExecute:(NSString *) newRequestId{
    BOOL isActive = [newRequestId isActiveRequestIdType];//判断新的requestId是否主动请求
    
    if (isActive) {
        //主动请求
        if ([self isEqualToString:newRequestId]) {
            //相同则排队执行
            return QUEUE;
        }else{
            //不相同则判断先后顺序
        }
    }else{
        //被动请求（推送优先播放）
        //老requestId跟新ID做判断
        if ([self isEqualToString:newRequestId]) {
            //相同则排队执行
            return QUEUE;
        }
        //立刻执行（保证推送的肯定是最新的）
        return EXECUTE;
    }
    
    
    NSArray * array = [self componentsSeparatedByString:@"-"];
    if (array && array.count > 0) {
        NSString *oldTimestamp = array[1];
       
    }else{
        
    }
    return NOT;
}

/**
 *  判断是否主动请求ID类型
 */
-(BOOL) isAutoRequestIdType{
    if ([self containsString:@"auto"]) {
        return YES;
    }
    return NO;
}

/**
 *  判断是否主动请求ID类型
 */
-(BOOL) isActiveRequestIdType{
    if ([self containsString:@"manual"]) {
        return YES;
    }
    return NO;
}

//根据reqeuestId获取时间戳
-(NSString *) getRequestIdTimestamp{
    NSArray * array = [self componentsSeparatedByString:@"_"];
    NSString *oldTimestamp = nil;
    if (array && array.count > 1) {
        oldTimestamp = array[1];
    }
    return oldTimestamp;
}

/**
 *  获取被动请求 ID（主动：auto-xxxxxxxxxxx）
 */
+(NSString *) requestIdWithAuto{
    return [NSString requestId:@"auto"];
}

/**
 *  获取主动请求 ID（主动：manual-xxxxxxxxxxx）
 */
+(NSString *) requestIdWithActive{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    NSString *request_id = [NSString requestId:@"manual"];
    if (deviceId) {
        if (request_id) {
            [[EVSSqliteManager shareInstance] update:@{@"request_id":request_id} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
        }
    }
    return request_id;
}
//获取请求id
+(NSString *) requestId:(NSString *) prefix{
    NSString *str = prefix;
    str = [str stringByAppendingFormat:@"_%@",[[NSString randomString] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    return str;
}
-(NSDictionary *) JSONStringWithDictionary{
    //string转data
    NSData * jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [jsonData JSONDataWithDictionary];
    return dict;
}
-(NSArray *) JSONStringWithArray{
    //string转data
    NSData * jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *Array = [jsonData JSONDataWithArray];
    return Array;
}

- (NSString *)SHA256
{
    const char *s = [self cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
    NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

- (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    
    return HMAC;
}

/**
 *  根据原字符串替的目标字符串换成需要替换的字符串
 *  origStr : 原字符串
 *  targetStr : 目标字符串
 *  replaceStr : 需要替换的字符串
 *  return : 替换后的字符串
 */
+(NSString *) stringSubstitution:(NSString *) origStr targetStr:(NSString *)targetStr replaceStr:(NSString *) replaceStr{
    if (origStr == nil || replaceStr == nil || targetStr == nil) {
        return origStr;
    }
    
    if(![replaceStr isKindOfClass:[NSString class]]){
        replaceStr = [NSString stringWithFormat:@"%@",replaceStr];
    }
    
    if ( [origStr containsString:targetStr]) {
        //判断源字符串是否存在目标字符串
        return [origStr stringByReplacingOccurrencesOfString:targetStr withString:replaceStr];
    }
    return origStr;
}


+(NSString *) randomString{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

+ (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url
{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)", name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return @"";
}

//uuid转UUID格式
-(NSString *) getUUIDFormatter2{
    NSRange range1 = NSMakeRange(0, 8);
    NSRange range2 = NSMakeRange(8, 4);
    NSRange range3 = NSMakeRange(12, 4);
    NSRange range4 = NSMakeRange(16, 4);
    NSRange range5 = NSMakeRange(20, 12);
    
    NSMutableString *tmpStr = [[NSMutableString alloc] init];
    [tmpStr appendFormat:@"%@_",[self substringWithRange:range1]];
    [tmpStr appendFormat:@"%@_",[self substringWithRange:range2]];
    [tmpStr appendFormat:@"%@_",[self substringWithRange:range3]];
    [tmpStr appendFormat:@"%@_",[self substringWithRange:range4]];
    [tmpStr appendFormat:@"%@",[self substringWithRange:range5]];
    NSLog(@"uuid : %@",[tmpStr copy]);
    return [tmpStr copy];
}

//uuid转UUID格式
-(NSString *) getUUIDFormatter{
    NSRange range1 = NSMakeRange(0, 8);
    NSRange range2 = NSMakeRange(8, 4);
    NSRange range3 = NSMakeRange(12, 4);
    NSRange range4 = NSMakeRange(16, 4);
    NSRange range5 = NSMakeRange(20, 12);
    
    NSMutableString *tmpStr = [[NSMutableString alloc] init];
    [tmpStr appendFormat:@"%@-",[self substringWithRange:range1]];
    [tmpStr appendFormat:@"%@-",[self substringWithRange:range2]];
    [tmpStr appendFormat:@"%@-",[self substringWithRange:range3]];
    [tmpStr appendFormat:@"%@-",[self substringWithRange:range4]];
    [tmpStr appendFormat:@"%@",[self substringWithRange:range5]];
    NSLog(@"uuid : %@",[tmpStr copy]);
    return [tmpStr copy];
}

//解析BLE 蓝牙ad信息(厂商标识)
-(NSString *) getBLEAdvertFactoryFlag{
    NSString *pStr = [self stringByReplacingOccurrencesOfString:@" " withString:@""];  //去掉空格
    pStr = [pStr stringByReplacingOccurrencesOfString:@"<" withString:@""];  //去掉括号
    pStr = [pStr stringByReplacingOccurrencesOfString:@">" withString:@""];  //去掉括号
    
    NSRange range = NSMakeRange(0, 4);//NSMakeRange这个函数的作用是从第0位开始计算，长度为4
    NSString *flag = [pStr substringWithRange:range];
    NSLog(@"从第0个字符开始，长度为4的字符串是：%@",flag);
    
    return flag;
}
//解析BLE 蓝牙ad信息（clientId）
-(NSString *) getBLEAdvertClientId{
    NSString *pStr = [self stringByReplacingOccurrencesOfString:@" " withString:@""];  //去掉空格
    pStr = [pStr stringByReplacingOccurrencesOfString:@"<" withString:@""];  //去掉括号
    pStr = [pStr stringByReplacingOccurrencesOfString:@">" withString:@""];  //去掉括号
    
    
    NSString *clientId = [[pStr substringFromIndex:4] getUUIDFormatter];
    NSLog(@"client id：%@",clientId);
    
    return clientId;
}

/**
 *  创建个性json
 */
+(NSString *) createUserScript{
    //自适应
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width,user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    NSMutableString *javaScriptStar = [[NSMutableString alloc] initWithString:@"var iflytek = new Object();"] ;
    [javaScriptStar appendFormat:@"iflytek = 'mobile'; "];
    [javaScriptStar appendFormat:@"iflytek.osType = 'iOS'; "];
    
    NSString *customJs = javaScriptStar;
    NSString *allJs = [NSString stringWithFormat:@"%@%@",jScript,customJs];
    return allJs;
}
@end
