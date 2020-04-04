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
//是否第一次打开
@property (nonatomic,assign) BOOL isFirstOpen;
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

-(id) init{
    if (self == [super init]) {
        self.isFirstOpen = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    }
    return self;
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
-(void) stateSync{
//    dispatch_queue_t queue =  dispatch_queue_create("system.state_sync", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue, ^{
        //同步状态
        EVSSystemStateSync *systemStateSync = [[EVSSystemStateSync alloc] init];
        NSDictionary *dict = [systemStateSync getJSON];
        [[EVSWebscoketManager shareInstance] sendDict:dict];
        self.second = 0.0f;
//    });
}

-(void)volumeChanged:(NSNotification *)notification{
//    dispatch_queue_t queue =  dispatch_queue_create("system.state_sync", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(queue, ^{
        float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        NSInteger systemVolume = volume * 100;
        if (systemVolume > 0 && !self.isFirstOpen){
            NSLog(@"EVS-系统音量:%f", systemVolume);
            NSString *deviceId = [EVSDeviceInfo shareInstance].getDeviceId;
            [[EVSSqliteManager shareInstance] update:@{@"speaker_volume":@(systemVolume)} device_id:deviceId tableName:CONTEXT_TABLE_NAME];
            [self stateSync];
        }
        self.isFirstOpen = NO;
//    });
}

/**
 *  定期检查
 */
-(void) periodicReview{
    [self stopReview];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REVIEW_TIME repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        //15分钟同步一次
        if (self.second == (60.0f * 15)) {
            [[EVSSystemManager shareInstance] stateSync];
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
//    [[EVSApplication shareInstance] checkMuted];
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
