//
//  EvsSDKForiOS.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EVSRequestHeader.h"
#import "EvsSDKDelegate.h"
@interface EvsSDKForiOS : NSObject
@property(weak) id<EvsSDKDelegate> delegate;
/**
 *  单例
 */
+(instancetype) shareInstance;
/**
 * 创建EvsSDKForiOS实例
 */
+(EvsSDKForiOS *) create:(NSString *)clientId deviceId:(NSString *) deviceId wsURL:(NSString *) wsURL;

/**
 * 重新设置EVS(restore后调用)
 */
-(void) recreateEVS:(NSString *)clientId deviceId:(NSString *) deviceId wsURL:(NSString *) wsURL;
/**
 *  EVS连接状态
 */
-(EVSConnectState) state;

/**
 *  EVS是否已授权
 */
-(BOOL) isAuth;

/**
 * 停止查询授权状态
 */
-(void) stopCheckAuth;
/**
 *  获取deviceId
 */
-(NSString *) getDeviceId;

/**
 *  连接EVS服务
 */
-(void) connect;

/**
 *  授权EVS服务
 */
-(void) auth:(NSString *) deviceCode;

/**
 *  重新连接EVS
 */
-(void) reconnect;

/**
 *  断开EVS
 */
-(void) disconnect;

/**
 *  出厂化EVS（慎用，会清除设备所有的数据，需要调用recreateEVS重新创建实例或重新启动）
 */
-(void) restoreEVS;

/**
 *  开始录音
 */
-(void) tap;

/**
 *  结束录音(有回复)
 */
-(void) end;

/**
 *  取消录音(无回复)
 */
-(void) cancel;

/**
 *  暂停
 */
-(void) pause;

/**
 *  继续播放
 */
-(void) resume;

/**
 *  下一首
 */
-(void) next;

/**
 *  上一首
 */
-(void) previous;

/**
 *  文本合成
 *  message : 文本
 */
-(void) tts:(NSString *) message;

/**
 *  文本请求
 *  message : 文本
 */
-(void) text_in:(NSString *) message;

/**
 *  设置音量
 *  volume : 音量 0-100
 */
-(void) setVolume:(NSInteger)volume;

/**
 *  设置音乐播放器进度
 *  progress : 进度 [0~1]
 */
-(void) setMeidaProgress:(float)progress;

/**
 * 获取当前音量
 */
-(float) getVolume;

/**
 *  自定义指令（扩展）
 *  jsonStr : json字符串
 */
-(void) command:(NSString *) jsonStr;

/**
 *  自定义二进制数据（扩展）
 *  data : data数据
 */
-(void) sendData:(NSData *) data;

/**
 *  设置token（手工设置token后，需要重新连接EVS）
 */
-(void) setToken:(NSString *) token;

/**
 *  获取token
 */
-(NSString *) getToken;

/**
 *  获取authorization
 */
-(NSString *) getAuthorization;

/**
 *  后台播放
 */
-(void) playBackgroud;
@end
