//
//  AudioOutputModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/1.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSResponseModel.h"
typedef NS_ENUM(NSInteger, EVSFocusStatus) {
    sound_effect_channel   = 0,//音效通道
    context_channel   = 1,//内容通道
    tts_channel   = 2//TTS通道
};

NS_ASSUME_NONNULL_BEGIN

@interface AudioOutputModel : NSObject
@property(nonatomic,copy) NSString *type; //播放器类型，取值：- TTS: 语音回复- PLAYBACK: 音频播放器，常见于播放内容- RING: 铃声，常见于闹钟
//@property(nonatomic,copy) NSString *request_id; //请求ID
@property(nonatomic,copy) NSString *command_id; //指令id
@property(nonatomic,copy) NSString *resource_id; //资源ID
@property(nonatomic,assign) long offset; //播放进度
@property(nonatomic,copy) NSString *url; //播放url

@property(nonatomic,copy) NSString *behavior;//播放方式 ： SERIAL：串行TTS（阻塞） ， PARALLEL：并行（非阻塞）
@property(nonatomic,assign) EVSFocusStatus focusStatus; //焦点状态
@property(nonatomic,assign) NSInteger focusLevel; //焦点优先级

@property(nonatomic,copy) NSString *localFileName;//本地文件名
@property(nonatomic,copy) NSString *localFileType;//本地文件类型

@property(strong,nonatomic) EVSResponsePayloadMetadataModel *metadata; //元数据
@property(nonatomic,assign) BOOL isResumeContextChannel;//是否继续播放contextChannel
@end

NS_ASSUME_NONNULL_END
