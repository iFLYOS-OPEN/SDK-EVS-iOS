//
//  EVS+NSData.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/24.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData(EVS_NSData)
-(NSDictionary *) JSONDataWithDictionary;
-(NSArray *) JSONDataWithArray;
-(NSString *) JSONDataWithString;
@end

NS_ASSUME_NONNULL_END
