//
//  EVSWebscoketManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSWebscoketManager.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"
#import "EvsSDKDelegate.h"

#define dispatch_key "websocket_dispatch"

@interface EVSWebscoketManager()<SRWebSocketDelegate>
@property (nonatomic,strong) SRWebSocket *socket;//socket
@property (nonatomic,strong) AudioOutputQueue *queue;//音频播放队列
@end

@implementation EVSWebscoketManager
-(AudioOutputQueue *) queue{
    if (!_queue) {
        _queue = [AudioOutputQueue shareInstance];
    }
    return _queue;
}

/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSWebscoketManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

/**
 *  连接websocket
 */
+(void) connectWebsocket:(NSString *) access_token wsURL:(NSString *)wsURL{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    EVSWebscoketManager *wsManager = [EVSWebscoketManager shareInstance];
    wsManager.deviceId = deviceId;
    wsManager.access_token = access_token;
    wsManager.wsURL = wsURL;
    [wsManager setup:deviceId access_token:access_token wsURL:wsURL];
    [wsManager connect];
}

-(EVSSRReadyState) state{
    return self.socket.readyState;
}
/**
 *  设置wss
 */
-(void) setup:(NSString *) device_id access_token:(NSString *)access_token wsURL:(NSString *) wsURL{
    NSString *origUrl = [NSString stringSubstitution:WSS_URL targetStr:@"{ws_url}" replaceStr:wsURL];;
    NSString *urlContext = [NSString stringSubstitution:origUrl targetStr:@"{access_token}" replaceStr:access_token];
    urlContext = [NSString stringSubstitution:urlContext targetStr:@"{device_id}" replaceStr:device_id];
    NSString *encodedValue = [urlContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    EVSLog(@"setup socket url :%@",urlContext);
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:encodedValue]]];
    self.socket.delegate = self;
}

/**
 *  wss连接
 */
-(void) connect{
    if (self.socket){
        EVSLog(@"socket connecting...");
        NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
        long timestamp = [NSDate getTimestamp] ;
        [[EVSSqliteManager shareInstance] update:@{@"timestamp":@(timestamp)} device_id:deviceId tableName:SYSTEM_TABLE_NAME];
        
        [[EVSLocationManager shareInstance] getLocation];
        [self.socket open];
    }
}

/**
 *  wss重连接
 */
-(void) reconnect{
    [self.socket close];
    self.socket = nil;
    if (self.deviceId && self.access_token && self.wsURL) {
        [self setup:self.deviceId access_token:self.access_token wsURL:self.wsURL];
    }
    [self connect];
}

/**
 *  wss断开
 */
-(void) disconnect{
    [self.socket close];
//    [[EVSFocusManager shareInstance] playPowerOff];
}

#pragma delegate
#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (webSocket == self.socket) {
        //接收到推送的新数据message,可以是json,可以是data等
        //信息统一处理渠道
        EVSResponseModel *responseModel = [EVSResponseModel mj_objectWithKeyValues:message];
        
        [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] responseMsg:message];
        if (responseModel.iflyos_responses.count > 0){
            EVSLog(@"[*] response <<< %@",message);
            [[EVSFocusManager shareInstance] addQueue:responseModel];
        }
    }
}
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    EVSLog(@"######################## EVS State #########################");
    EVSLog(@"#                 socket connect success...                #");
    EVSLog(@"############################################################");
    EVSConnectState state = self.socket.readyState;
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] connectState:state error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:k_NOTIFICATION_WS_STATE object:@(self.socket.readyState)];
    [[EVSFocusManager shareInstance] playPowerOn];
    [EVSSystemManager stateSync];
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    EVSLog(@"socket connect fail:%@",error);
    [[EVSFocusManager shareInstance] playNetworkErrorRetry];
    EVSConnectState state = self.socket.readyState;
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] connectState:state error:error];
    [EVSSystemManager exception:@"ws_connect_fail" code:[NSString stringWithFormat:@"%li",error.code] message:error.localizedDescription];
    [[NSNotificationCenter defaultCenter] postNotificationName:k_NOTIFICATION_WS_STATE object:@(self.socket.readyState)];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    EVSLog(@"socket connect close:%@",reason);
//    [[EVSFocusManager shareInstance] playNetworkErrorRetry];
    EVSConnectState state = self.socket.readyState;
    NSString *errorStr = @"";
    if (reason) {
        errorStr = reason;
    }
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:errorStr}];
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] connectState:state error:error];
    [EVSSystemManager exception:@"ws_connect_close" code:[NSString stringWithFormat:@"%li",code] message:reason];
    [[NSNotificationCenter defaultCenter] postNotificationName:k_NOTIFICATION_WS_STATE object:@(self.socket.readyState)];
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSData * jsonData = [[NSData alloc] init];
    id resObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    EVSLog(@"socket connect pong:%@",resObj);
}

#pragma 操作

/**
 *  发送command
 */
-(void) sendStr:(NSString *) dataStr{
    EVSLog(@"[*] Request >>> %@",dataStr);
    [[EvsSDKForiOS shareInstance].delegate evs:[EvsSDKForiOS shareInstance] requestMsg:dataStr];
        if (self.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (self.socket.readyState == SR_OPEN) {
                [self.socket send:dataStr];    // 发送数据
            }   else if (self.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                // [self reConnect];
            } else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED)   {
                // websocket 断开了，调用 reConnect 方法重连
                NSLog(@"重连");
//                [self reconnect];
            }
        } else {
//            [EVSSystemManager exception:@"ws_sendStr" code:@"0" message:[NSString stringWithFormat:@"数据包大小:%li",dataStr.length]];
//            [[EVSFocusManager shareInstance] playNetworkErrorWait];
//            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
//            NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
        }
}

- (void)sendDict:(NSDictionary *)param {
    NSString* dataStr = [param mj_JSONString];
    [self sendStr:dataStr];
}

-(void) sendData:(NSData *) data{
//    NSLog(@"[*] Request >>> data size %li",data.length);
        if (self.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (self.socket.readyState == SR_OPEN) {
                [self.socket send:data];    // 发送数据
            }   else if (self.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                // [self reConnect];
            } else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED)   {
                // websocket 断开了，调用 reConnect 方法重连
                NSLog(@"重连");
//                [self reconnect];
            }
        } else {
//            [EVSSystemManager exception:@"ws_sendData" code:@"0" message:[NSString stringWithFormat:@"数据包大小:%li",data.length]];
//            [[EVSFocusManager shareInstance] playNetworkErrorWait];
//            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
//            NSLog(@"其实最好是发送前判断一下网络状态比较好，我写的有点晦涩，socket==nil来表示断网");
        }
}
@end
