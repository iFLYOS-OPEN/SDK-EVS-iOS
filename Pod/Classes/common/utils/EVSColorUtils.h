//
//  EVSColorUtils.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVSColorUtils : NSObject
/**
 * 根据#FFFFFF获取颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

/**
 * 根据#FFFFFF获取颜色
 * alpha 通道
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat) alpha;

/**
 *  随机颜色
 */
+ (UIColor *)randomColor ;

/**
 * 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 * 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color CGRect:(CGRect) rect;

//设置状态栏颜色
+ (void)setStatusBarBackgroundColor:(UIColor *)color ;
@end

NS_ASSUME_NONNULL_END
