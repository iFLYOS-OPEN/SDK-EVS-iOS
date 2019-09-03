//
//  EVSWebscoketManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
NS_ASSUME_NONNULL_BEGIN

@interface EVSWebscoketManager : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *access_token;
@property (nonatomic,copy) NSString *wsURL;

//连接状态
@property(readonly,nonatomic) SRReadyState state;
/**
 *  连接websocket
 */
+(void) connectWebsocket:(NSString *) access_token wsURL:(NSString *)wsURL;
/**
 *  设置wss
 */
-(void) setup:(NSString *) device_id access_token:(NSString *)access_token wsURL:(NSString *) wsURL;
/**
 *  wss连接
 */
-(void) connect;
/**
 *  wss重连接
 */
-(void) reconnect;
/**
 *  wss断开
 */
-(void) disconnect;

/**
 *  发送string
 */
-(void) sendStr:(NSString *) string;
/**
 *  发送字典
 */
- (void)sendDict:(NSDictionary *)param ;
/**
 *  发送Data
 */
-(void) sendData:(NSData *) data;
@end

NS_ASSUME_NONNULL_END
