//
//  AudioSessionManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioSessionManager : NSObject
// 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时停止。
+(void) setOnlyPlayBack;

// 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时停止。
+(void) setOnlyRecord;
@end

NS_ASSUME_NONNULL_END
