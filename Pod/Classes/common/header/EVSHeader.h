//
//  EVSHeader.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#ifndef EVSHeader_h
#define EVSHeader_h
/*****************************头文件********************************/
#import "EvsSDKForiOS.h"
#import "EVSColorUtils.h"
#import "EVSDateUtils.h"
#import "EVSAuthModel.h"
#import "EVS+NSData.h"
#import "EVS+NSDate.h"
#import "EVS+NSString.h"
#import "EVS+NSDictionary.h"
#import "EVS+EVSWebscoketManager.h"
#import "EVS+EVSFocusManager.h"
#import "EVSWebscoketManager.h"
#import "EVSLocationManager.h"
#import "IFLYOSHTTPRequest.h"
#import "EVSDeviceInfo.h"
#import "EVSApplication.h"
#import "EVSSqliteManager.h"
#import "EVSSystemManager.h"
#import "EVSAuthManager.h"
#import "AudioSessionManager.h"
#import "EVSFocusManager.h"
#import <MJExtension/MJExtension.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <SocketRocket/SocketRocket.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <fmdb/FMDB.h>

#import "EVSHeaderProtocolModel.h"
#import "EVSContextProtocolModel.h"
#import "EVSBaseProtocolModel.h"
#import "EVSResponseModel.h"

#import "AudioInput.h"
#import "AudioOutput.h"
#import "AudioOutputModel.h"
#import "AudioOutputQueue.h"

#define ENV @"staging-"
#define HTTP_SCHEMA @"https"
#define WEBSOCKET_SCHEMA @"WSS"

#define COMMAND_END @"__END__"
#define COMMAND_CANCEL @"__CANCEL__"

#define TIME_ZOOM 1000 //进度放大倍数（ms）
/*****************************异步串行********************************/
#define dispatch_command_queue_key "command_queue_dispatch" //移除添加队列

/*****************************播放状态********************************/
#define playback_state_idle @"IDLE"//空闲
#define playback_state_playing @"PLAYING"//播放中
#define playback_state_paused @"PAUSED"// 已暂停。设备有播放列表，但没有在播放时，上报这个状态
/*****************************地址配置start********************************/
//#define AUTH_USER_CODE @"{http_schema}://{env}auth.iflyos.cn/oauth/ivs/device_code?client_id={client_id}&scope=user_ivs_all&scope_data={scope_data}" //请求userCode
#define AUTH_USER_CODE @"{http_schema}://{env}auth.iflyos.cn/oauth/ivs/device_code?client_id={client_id}&scope_data={scope_data}" //请求userCode（测试）
#define AUTH_DEVICE_CODE @"{auth_url}?user_code={user_code}" //请求授权页面
#define AUTH_ACCESS_TOKEN @"{http_schema}://{env}auth.iflyos.cn/oauth/ivs/token" //轮训获取access_token

#define WSS_URL @"{ws_url}?token={access_token}&device_id={device_id}" //websocket连接

#define CONFIG_TABLE_NAME @"t_evs_config"
#define HEADER_TABLE_NAME @"t_evs_header"
#define CONTEXT_TABLE_NAME @"t_evs_context"
#define SYSTEM_TABLE_NAME @"t_evs_system"
/*****************************地址配置end********************************/
#define k_ACCESS_TOKEN @"access_token"
#define k_TOKEN_TYPE @"token_type"
#define k_REFRESH_TOKEN @"refresh_token"
#define k_EXPIRES_IN @"expires_in"
#define k_CREATED_AT @"created_at"
#define k_AUTHORIZATION @"authorization"

#define k_NOTIFICATION_WS_STATE @"notificationWsState"//全局通知
/***********************************回调*************************************/
#define REJECT_LOGIN @"rejectLogin"//拒绝
#define OPEN_NEW_BROWSER @"openBrowser"//打开浏览器
#define OPEN_NEW_PAGE @"openNewPage"
#define OPEN_LOGIN_PAGE @"openLoginPage"
#define CLOSE_PAGE @"closePage"
#define RELOAD_OLD_PAGE @"reloadOldPage"
#define LOGIN_FAILED @"loginFailed"
#define LOGOUT_PAGE @"logout"
#define AUTH_SUCCESS @"authSuccess"
#define AUTH_FAIL @"authFail"


#define WEBVIEW_APPEAR @"webview_appear"
#define WEBVIEW_DISAPPEAR @"webview_disappear"
#define WEBVIEW_APPEAR_OLD @"window.webview_bridge('webview_appear')"
#define WEBVIEW_DISAPPEAR_OLD @"window.webview_bridge('webview_disappear')"

/*****************************请求状态码********************************/
#define REQUEST_SUCCESS_CODE 200//请求成功
#define REQUEST_CLIENT_ERROR_CODE 400//客户端参数错误
#define REQUEST_NO_AUTHORIZATION_CODE 401//没有授权
#define REQUEST_AUTHORIZATION_LIMITS 403//权限限制
#define REQUEST_SERVER_NOT_RESPONSE 500//权限限制
#define REQUEST_TIMEOUT_CODE -1001//超时
#endif /* EVSHeader_h */

/*****************************指令********************************/
#define recognizer_intermediate_text @"recognizer.intermediate_text" //识别文字
#define recognizer_stop_capture @"recognizer.stop_capture" //结束录音
#define recognizer_expect_reply @"recognizer.expect_reply" //追问
#define audio_player_audio_out @"audio_player.audio_out" //音频播放
#define audio_player_audio_out_tts @"audio_player.audio_out.tts" //tts音频播放
#define speaker_set_volume @"speaker.set_volume" //设置音量
#define system_ping @"system.ping" //同步心跳包（同步时间）
#define system_error @"system.error" //错误提示
#define system_revoke_authorization @"system.revoke_authorization" //授权无效

#ifdef DEBUG
#define EVSLog(...) NSLog(@"EVS SDK ^_^: %@\n", [NSString stringWithFormat:__VA_ARGS__])
#else
#define EVSLog(...)
#endif
