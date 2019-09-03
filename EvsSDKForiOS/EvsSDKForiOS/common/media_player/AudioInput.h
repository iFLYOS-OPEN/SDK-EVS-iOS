//
//  AudioInput.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/26.
//  Copyright © 2019 iflytek. All rights reserved.
//  音频输入

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioInput : NSObject
+ (AudioInput *)sharedAudioManager;
//写入文件
- (void)writeBytes:(Byte *)bytes len:(NSUInteger)len toPath:(NSString *)path;
-(NSString *) pcmPath;

//始终录音
-(void) run;

//停止录音
-(void) end;

//开启 Audio Unit
- (void)start;

//关闭 Audio Unit
- (void)stop;

//结束 Audio Unit
- (void)finished ;

//开启回声消除
-(void) openCAE;
@end

NS_ASSUME_NONNULL_END
