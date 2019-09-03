//
//  AudioSessionManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "AudioSessionManager.h"
#import <AVFoundation/AVFoundation.h>
/*
 1.AVAudioSessionCategoryAmbient
 当前App的播放声音可以和其他app播放的声音共存，当锁屏或按静音时停止。
 
 2.AVAudioSessionCategorySoloAmbient
 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时停止。
 
 3.AVAudioSessionCategoryPlayback
 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时不会停止。
 
 4.AVAudioSessionCategoryRecord
 只能用于录音，其他app的声音会停止，当锁屏或按静音时不会停止
 
 5.AVAudioSessionCategoryPlayAndRecord
 在录音的同时播放其他声音，当锁屏或按静音时不会停止
 可用于听筒播放，比如微信语音消息听筒播放
 
 6.AVAudioSessionCategoryAudioProcessing
 使用硬件解码器处理音频，该音频会话使用期间，不能播放或录音
 
 7.AVAudioSessionCategoryMultiRoute
 多种音频输入输出，例如可以耳机、USB设备同时播放等
 */

@implementation AudioSessionManager
// 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时停止。
+(void) setOnlyPlayBack{
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
    AudioSessionSetActive(YES);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];//设置为公放模式
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];//本App独占音频通道
}

// 只能播放当前App的声音，其他app的声音会停止，当锁屏或按静音时停止。
+(void) setOnlyRecord{
    AudioSessionSetActive(YES);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];//设置为公放模式
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//本App独占音频通道
}
@end
