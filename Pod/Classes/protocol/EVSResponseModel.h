//
//  EVSResponseModel.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface EVSResponseMetaModel : NSObject
@property(copy,nonatomic) NSString *trace_id; //响应提工单的ID
@property(copy,nonatomic) NSString *request_id; //当云端主动发送response时，该字段不会出现
@property(assign,nonatomic) BOOL is_last; //标记本次回复是不是这个请求的最后一组回复
@end

@interface EVSResponseHeaderModel : NSObject
@property(copy,nonatomic) NSString *command_id; //指令id
@property(copy,nonatomic) NSString *name; //指令name
@end

@interface EVSResponsePayloadMetadataModel : NSObject
@property(copy,nonatomic) NSString *text; //元数据文本
@property(copy,nonatomic) NSString *title; //元数据标题
@property(copy,nonatomic) NSString *album; //专辑
@property(assign,nonatomic) long duration; //时长
@end

@interface EVSResponsePayloadModel : NSObject
@property(copy,nonatomic) NSString *type; //响应类型（TTS，playback,template）
@property(copy,nonatomic) NSString *resource_id; //内容ID
@property(copy,nonatomic) NSString *url; //资源地址
@property(copy,nonatomic) NSString *control; //播放器控制，取值：- PLAY: 播放- PAUSE: 暂停- RESUME: 继续播放
@property(copy,nonatomic) NSString *behavior; //播放方式- IMMEDIATELY: 马上播放，- UPCOMING: 即将播放（播放队列播放完才播放）
@property(assign,nonatomic) long offset; //播放进度
@property(copy,nonatomic) NSString *lyric; //歌词信息
@property(strong,nonatomic) EVSResponsePayloadMetadataModel *metadata; //元数据

//识别返回文本
@property(copy,nonatomic) NSString *text; //识别的内容
@property(assign,nonatomic) BOOL is_last; //是否最后识别

//错误信息
@property(assign,nonatomic) NSInteger code;//错误码
@property(copy,nonatomic) NSString *message;//信息

//时间戳
@property(assign,nonatomic) long timestamp;//时间戳

//追问
@property(assign,nonatomic) NSInteger timeout;//超时
@property(assign,nonatomic) BOOL background_recognize;//是否背景录音，默认false
@property(copy,nonatomic) NSString *reply_key;//追问key

//音量
@property(assign,nonatomic) float volume;

//是否继续播放音频
@property(assign,nonatomic) BOOL isResumeContextChannel;
@end

@interface EVSResponseItemModel : NSObject
@property(strong,nonatomic) EVSResponseHeaderModel *header;
@property(strong,nonatomic) EVSResponsePayloadModel *payload;
@end

@interface EVSResponseModel : NSObject
@property(strong,nonatomic) EVSResponseMetaModel *iflyos_meta;
@property(strong,nonatomic) NSArray *iflyos_responses;//EVSResponseItemModel
@end

NS_ASSUME_NONNULL_END
