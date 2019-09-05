//
//  EVS+NSDate.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate(EVS_NSDate)
//获取当前时间戳  （以毫秒为单位）

+(NSString *)getNowTimeTimestamp3;
//获取当前时间戳
+(long)getTimestamp;
//判断两个时间戳相差多少秒
+(long)getSeconds:(long)takeCarTime systemTime:(long)systemTime;
@end

NS_ASSUME_NONNULL_END
