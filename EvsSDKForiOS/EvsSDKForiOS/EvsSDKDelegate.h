//
//  EvsSDKDelegate.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/31.
//  Copyright © 2019 iflytek. All rights reserved.
//  代理回调
#import <Foundation/Foundation.h>
@class EvsSDKForiOS;
typedef NS_ENUM(NSInteger, EVSConnectState) {
    CONNECTING   = 0,//可连接
    OPEN         = 1,//已连接
    CLOSING      = 2,//可关闭
    CLOSED       = 3,//已关闭
};

typedef NS_ENUM(NSInteger, EVSSessionState) {
    IDLE = 0, //空闲
    LISTENING = 1, //录音中
    THINKING = 2, //响应中
    SPEAKING = 3, //播放中
    FINISHED = 4 //播放完毕
};

@protocol EvsSDKDelegate <NSObject>
/**
 *  EVS授权状态回调
 *  isAuth:是否授权成功
 *  errorCode : 错误代码 （0:没错误）
 *  error : 错误原因
 */
-(void) evs:(EvsSDKForiOS *) evsSDK isAuth:(BOOL)isAuth errorCode:(NSInteger) errorCode error:(NSError *) error;

/**
 *  EVS连接状态回调
 *  connectState : 连接状态
 *  error : 错误原因
 */
-(void) evs:(EvsSDKForiOS *) evsSDK connectState:(EVSConnectState) connectState error:(NSError *) error;

/**
 *  EVS当前音量回调
 *  volume : 音量（1～100）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK volume:(NSInteger) volume;

/**
 *  EVS请求回调
 *  requestMsg : 指令（json）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK requestMsg:(NSString *)requestMsg;

/**
 *  EVS响应回调
 *  responseMsg : 指令（json）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK responseMsg:(NSString *)responseMsg;

/**
 *  EVS录音分贝回调
 *  Command : 指令（json）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK decibel:(float) decibel;

/**
 *  EVS当前播放器播放进度
 *  progress :  播放进度（百分比）
 */
-(void) evs:(EvsSDKForiOS *) evsSDK progress:(float) progress;

/**
 *  EVS 对话状态
 *  sessionStatus : 对话状态
 */
-(void) evs:(EvsSDKForiOS *) evsSDK sessionStatus:(EVSSessionState) sessionStatus;
@end
