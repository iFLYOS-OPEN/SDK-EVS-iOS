//
//  EVSAudioPlayer.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSBaseProtocolModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface EVSAudioPlayerPlaybackProgressSyncRequestHeader:NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAudioPlayerPlaybackProgressSyncRequestPayload:NSObject
/**
 *  STARTED:播放开始播放的时候，发送此类型并告知 resource_id，手机端可获得播放内容信息
 *  FAILED:播放失败的时候，发送此类型并告知播放失败的 resource_id，云端会下发其他内容
 *  NEARLY_FINISHED:音频播放即将结束，一般取内容的1/3的时间长度 或 结束前10秒或播放后30秒（不是必传）
 *  FINISHED:播放结束时候发送此类型，发送此类型并告知 resource_id
 */
@property(copy,nonatomic) NSString *type;
@property(copy,nonatomic) NSString *resource_id;//资源ID
@property(assign,nonatomic) long offset;//进度（不是必传）
/**
 *  错误码（不是必传）
 *  1001:MEDIA_ERROR_UNKNOWN    发生了未知错误
 *  1002:MEDIA_ERROR_INVALID_REQUEST    请求无效。可能的情况有：bad request, unauthorized, forbidden, not found等。
 *  1003:MEDIA_ERROR_SERVICE_UNAVAILABLE    设备端无法获取音频文件
 *  1004:MEDIA_ERROR_INTERNAL_SERVER_ERROR    服务端接收了请求但未能正确处理
 *  1005:MEDIA_ERROR_INTERNAL_DEVICE_ERROR    设备端内部错误
 */
@property(copy,nonatomic) NSString *failure_code;
@end

@interface EVSAudioPlayerPlaybackProgressSyncRequest : NSObject
@property(strong,nonatomic) EVSAudioPlayerPlaybackProgressSyncRequestHeader *header;
@property(strong,nonatomic) EVSAudioPlayerPlaybackProgressSyncRequestPayload *payload;
@end

@interface EVSAudioPlayerPlaybackControlCommandRequestHeader:NSObject
@property(copy,nonatomic) NSString *name;
@property(copy,nonatomic) NSString *request_id;
@end

@interface EVSAudioPlayerPlaybackControlCommandRequestPayload:NSObject
/**
 *  PAUSE:执行了暂停动作之后，发送此类型并告知当前 resource_id    是，得到pause回复
 *  RESUME:执行了继续播放之后，发送此类型并告知当前 resource_id    是，会收到一个带offset的播放内容，应该优先用offset进行播放对应资源
 *  NEXT:按键下一首，发送此类型并告知当前 resource_id    是，得到下一首内容
 *  PREVIOUS:按键上一首，发送此类型并告知当前 resource_id    是，得到上一首内容
 */
@property(copy,nonatomic) NSString *type;
@property(copy,nonatomic) NSString *resource_id;//资源ID
@end

@interface EVSAudioPlayerPlaybackControlCommandRequest : NSObject
@property(strong,nonatomic) EVSAudioPlayerPlaybackControlCommandRequestHeader *header;
@property(strong,nonatomic) EVSAudioPlayerPlaybackControlCommandRequestPayload *payload;
@end

@interface EVSAudioPlayerPlaybackProgressSync : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAudioPlayerPlaybackProgressSyncRequest *iflyos_request;//播放器信息同步
@end

@interface EVSAudioPlayerPlaybackControlCommand : EVSBaseProtocolModel
@property(strong,nonatomic) EVSAudioPlayerPlaybackControlCommandRequest *iflyos_request;//播放器控制同步
@end
NS_ASSUME_NONNULL_END
