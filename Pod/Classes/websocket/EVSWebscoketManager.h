//
//  EVSWebscoketManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/23.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, EVSSRReadyState) {
    EVS_SR_CONNECTING   = 0,
    EVS_SR_OPEN         = 1,
    EVS_SR_CLOSING      = 2,
    EVS_SR_CLOSED       = 3,
};
@interface EVSWebscoketManager : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *access_token;
@property (nonatomic,copy) NSString *wsURL;

//连接状态
@property(readonly,nonatomic) EVSSRReadyState state;
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
