//
//  AudioOutput.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/26.
//  Copyright © 2019 iflytek. All rights reserved.
//  音频输出

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioOutputModel.h"
NS_ASSUME_NONNULL_BEGIN
/**************************************************前景音频播放器*******************************************************/
@class AudioOutput;
@protocol AudioOutputDelegate

//开始播放(内容通道)
-(void) audioOutputContextChannelStart:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;
//播放完毕(内容通道)
-(void) audioOutputContextChannelFinish:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;

//开始播放（TTS通道）
-(void) audioOutputTTSChannelStart:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;
//播放完毕（TTS通道）
-(void) audioOutputTTSChannelFinish:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;

//开始播放（音效通道）
-(void) audioOutputSoundEffectChannelStart:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;
//播放完毕（音效通道）
-(void) audioOutputSoundEffectChannelFinish:(AudioOutput *) audioOutput model:(AudioOutputModel *) model;
@end

@interface AudioOutput : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

@property id<AudioOutputDelegate> delegate;

//播放器
@property (nonatomic,strong) AVPlayer *player;//内容PLAYBACK
@property (nonatomic,strong) AVPlayer *ttsChannelPlayer;//TTS
@property (nonatomic,strong) AVAudioPlayer *soundEffectsPlayer;//音效

@property (nonatomic,strong) AudioOutputModel *contextModel;//内容通道当前Model
@property (nonatomic,strong) AudioOutputModel *ttsModel;//内容通道当前Model
@property (nonatomic,strong) AudioOutputModel *soundModel;//音效通道当前Model
//当前音量
@property(nonatomic,assign) float currentVolume;
@property(nonatomic,assign) float currentTTSVolume;
//当前进度
@property(nonatomic,assign) float currentProgress;
/**
 *  播放本地资源（在音效通道播放）
 */
-(void) openURLWithSoundEffectsChannel:(AudioOutputModel *) model;
/**
 *  播放网络资源（在内容通道播放）
 */
-(void) openURLWithContextChannel:(AudioOutputModel *) model;
/**
 *  播放网络资源（在TTS通道播放，分阻塞和非阻塞）
 */
-(void) openURLWithTTSChannel:(AudioOutputModel *) model;
//背景声音设置2%
-(void) setBackgroundVolume2Percent;
//背景声音设置20%
-(void) setBackgroundVolume20Percent;
//背景音乐恢复
-(void) resumeBackgroundVolume;

//停止
-(void) stop;
//停止（TTS播放器）
-(void) stopTTS;
//播放,time:播放进度
-(void) play:(NSTimeInterval) time;
//暂停
-(void) pause;

//恢复(本地播放器恢复)
-(void) resumeLocalPlay;

//恢复（只恢复声音）
-(void) resumeOnlyVolume;

//设置音量(0~1)
-(void) setVolume:(float) volume;
//设置TTS音量(0~1)
-(void) setTTSVolume:(float) volume;
@end

NS_ASSUME_NONNULL_END
