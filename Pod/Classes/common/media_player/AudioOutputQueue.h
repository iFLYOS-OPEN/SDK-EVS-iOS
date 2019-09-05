//
//  AudioOutputQueue.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//  播放器列队

#import <Foundation/Foundation.h>
#import "AudioOutputModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol AudioOutputQueueDelegate
/**
 *  内容播放队列(开始播放的队列)
 *  model : 正在播放的model
 */
-(void) contextChannelStart:(NSArray *) queue useModel:(AudioOutputModel *) model;

/**
 *  内容播放队列(结束播放的队列)
 *  model : 结束的model
 */
-(void) contextChannelFinish:(NSArray *) queue useModel:(AudioOutputModel *) model;

/**
 *  TTS播放队列
 *  model : 开始播放的model
 */
-(void) ttsChannelStart:(NSArray *) queue useModel:(AudioOutputModel *) model;

/**
 *  TTS播放队列
 *  model : 结束播放的model
 */
-(void) ttsChannelFinish:(NSArray *) queue useModel:(AudioOutputModel *) model;
@end

@interface AudioOutputQueue : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

@property(weak) id<AudioOutputQueueDelegate> delegate;
/**
 *  判断当前指令是否在阻塞
 */
-(BOOL) checkSerial;

/**
 *  播放TTS队列
 */
-(void) playTTSQueue;

/**
 *  加入TTS播放队列
 */
-(void) addTTSChannelQueue:(AudioOutputModel *) model;

/**
 *  移除TTS队列
 */
-(void) removeTTSChannelQueue:(AudioOutputModel *) model;

/**
 *  清除TTS队列
 */
-(void) clearTTSChannelQueue;

/**
 *  播放当前队列
 */
-(void) playQueue;
/**
 *  更新立刻播放队列
 */
-(void) updateAudioQueue:(AudioOutputModel *)newModel;
/**
 *  加入即将播放队列
 */
-(void) addAudioUpcomingQueue:(AudioOutputModel *) model;

/**
 *  加入立刻播放队列
 */
-(void) addAudioQueue:(AudioOutputModel *) model;

/**
 *  移出立刻播放队列
 */
-(void) removeAudioQueue:(AudioOutputModel *)model;

/**
 *  移出即将播放队列
 */
-(void) removeUpcomingQueue:(AudioOutputModel *)model;
/**
 *  清除即将播放队列(all)
 */
-(void) clearUpcomingQueue;
/**
 *  清除立刻播放队列(All)
 */
-(void) clearAudioQueue;

/**
 *  播放器同步
 *  STARTED:播放开始播放的时候，发送此类型并告知 resource_id，手机端可获得播放内容信息
 *  FAILED:播放失败的时候，发送此类型并告知播放失败的 resource_id，云端会下发其他内容
 *  NEARLY_FINISHED:音频播放即将结束，一般取内容的1/3的时间长度 或 结束前10秒或播放后30秒（不是必传）
 *  FINISHED:播放结束时候发送此类型，发送此类型并告知 resource_id
 *  PAUSED:正在播放的内容被暂停时（被用户按键暂停，或收到了云端下发的PAUSE类型的audio_player.audio.out的response），发送此类型并告知resource_id    
 */
-(void) playbackOrTTSSync:(AudioOutputModel *)model type:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
