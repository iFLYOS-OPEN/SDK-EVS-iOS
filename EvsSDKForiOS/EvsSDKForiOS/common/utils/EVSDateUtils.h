//
//  EVSDateUtils.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/26.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSDateUtils : NSObject
//当前日期（YYYYMMdd）
+(NSString*)getCurrentTimes;
//当前时间戳（秒为单位）
+(NSString *)getNowTimeTimestamp;
/**
 *  日期转时间戳
 *  data: 日期时间
 */
+(NSString *) dateConversionTimestamp:(NSDate *) data;
@end

NS_ASSUME_NONNULL_END
