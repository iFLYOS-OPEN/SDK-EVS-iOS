//
//  EVSSystemManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/8/8.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSSystemManager.h"
#import "EVSHeader.h"
#import "EVSRequestHeader.h"
#define REVIEW_TIME 1
@interface EVSSystemManager()
//监听进度
@property (nonatomic,strong) NSTimer *timer;
//秒数
@property (nonatomic,assign) float second;
@end

@implementation EVSSystemManager
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSSystemManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

+(void) exception:(NSString *)type code:(NSString *)code message:(NSString *)message{
    EVSSystemException *exception = [[EVSSystemException alloc] init];
    exception.iflyos_request.payload.type = type;
    exception.iflyos_request.payload.code = code;
    exception.iflyos_request.payload.message = message;
    NSDictionary *dict = [exception getJSON];
    [[EVSWebscoketManager shareInstance] sendDict:dict];
}

/**
 *  同步状态
 */
+(void) stateSync{
    dispatch_queue_t queue =  dispatch_queue_create("system.state_sync", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        //同步状态
        EVSSystemStateSync *systemStateSync = [[EVSSystemStateSync alloc] init];
        NSDictionary *dict = [systemStateSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:dict];
    });
}

/**
 *  定期检查
 */
-(void) periodicReview{
    [self stopReview];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REVIEW_TIME repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //15分钟同步一次
        if (self.second == (60.0f * 15)) {
            [EVSSystemManager stateSync];
            self.second = 0.0f;
        }
//        EVSLog(@"-----------------EVS system review %f-------------------",self.second);
        self.second++;
       
        [self syncTimestamp];
        [self checkMute];
        [[EVSAuthManager shareInstance] checkTokenVaild];
    }];
}

-(void) stopReview{
    [self.timer invalidate];
    self.timer = nil;
}

//检查是否静音
-(void) checkMute{
    [[EVSApplication shareInstance] checkMuted];
}

//检查云端时间，若2分钟没收到指令，则重新连接websocket
-(void) syncTimestamp{
    NSString *deviceId = [[EVSDeviceInfo shareInstance] getDeviceId];
    NSDictionary *systemDict = [[EVSSqliteManager shareInstance] asynQuerySystem:deviceId tableName:SYSTEM_TABLE_NAME];
    id timestamp = systemDict[@"timestamp"];
    if (timestamp) {
        long serverTs = [timestamp longValue] ;//云端时间
        long currentTs = [NSDate getTimestamp] ;//当前时间
        
        long seconds = [NSDate getSeconds:serverTs systemTime:currentTs];
//        EVSLog(@"-----------------EVS system review %li-------------------",seconds);
        if (seconds <= -130) {
            [[EVSWebscoketManager shareInstance] reconnect];
        }
    }
}
@end
