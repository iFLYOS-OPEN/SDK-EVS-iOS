//
//  EVS+NSDate.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVS+NSDate.h"

@implementation NSDate(EVS_NSDate)
//获取当前的时间
+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

///获取当前时间戳有两种方法(以秒为单位)

+(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}



+(NSString *)getNowTimeTimestamp2{
    
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    ;
    
    return timeString;
    
}

//获取当前时间戳  （以毫秒为单位）

+(NSString *)getNowTimeTimestamp3{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
    return timeSp;
    
}

//获取当前时间戳  （以毫秒为单位）

+(long)getTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    
    return (long)[datenow timeIntervalSince1970];
    
}

+(long)getSeconds:(long)takeCarTime systemTime:(long)systemTime
{
    
    //  时区相差8个小时 加上这个时区即是北京时间
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    NSInteger delta = [timeZone secondsFromGMT];
    
    // 两个时间戳转换日期类
    
    // [takeCarTime doubleValue]/1000 这里除以1000 我们后台传来的时间戳有问题
    
    NSDate  *DRstartDate = [[NSDate alloc] initWithTimeIntervalSince1970:takeCarTime + delta];
    
    NSDate *DRendDate = [[NSDate alloc] initWithTimeIntervalSince1970:systemTime + delta];
    
    // 日历对象 （方便比较两个日期之间的差距）
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // NSCalendarUnit 枚举代表想获得哪些差值 NSCalendarUnitYear 年 NSCalendarUnitWeekOfMonth 月
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *cmps = [calendar components:unit fromDate:DRendDate toDate:DRstartDate options:0];
    
    // 获得某个时间的年月日时分秒
    
    //        NSDateComponents *createDateCmps = [calendar components:unit fromDate:DRstartDate];
    
    //        NSDateComponents *nowCmps = [calendar components:unit fromDate:DRendDate];
    return cmps.second + cmps.minute * 60;
}
@end
