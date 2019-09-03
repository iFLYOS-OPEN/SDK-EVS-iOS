//
//  EVS+NSDictionary.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary(EVS_NSDictionary)
// 字典转json字符串方法
-(NSString *)convertToJsonData;
@end

NS_ASSUME_NONNULL_END
