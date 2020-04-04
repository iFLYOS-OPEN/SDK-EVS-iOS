//
//  IMAManager.h
//  IMAKit
//
//  Created by 周经伟 on 2019/11/6.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN
@class IMAManager;
@protocol IMAKitDelegate <NSObject>
/**
 * 蓝牙是否可用
 */
-(void) imaManager:(IMAManager *) imaManager isActive:(BOOL) isActive;
/**
 * 回调返回蓝牙对象
 */
-(void) imaManager:(IMAManager *) imaManager peripheral:(CBPeripheral *)peripheral clientId:(NSString *) clientId;

/**
 * 是否连接成功
 */
-(void) imaManager:(IMAManager *) imaManager peripheral:(CBPeripheral *)peripheral isConnect:(BOOL) isConnect error:(NSError *) error;

/**
 *  连接后返回设备信息
 */
-(void) onGetDeviceInfomation:(NSString *) deviceId clientId:(NSString *) clientId;
/**
 * 版本是否可用
 */
-(void) onVersionVerify:(BOOL) isVersionExchange;

/**
*  配对成功
*/
-(void) onPairSuccess;
/**
*  配对失败
*/
-(void) onPairFail:(int)statusCode msg:(NSString *)msg;

/**
 *  开始录音回调
 */
-(void) onStartSpeech;

/**
 *  结束录音回调
 */
-(void) onStopSpeech;

/**
* 音频数据处理
* @param data
* @param length
*/
-(void)onAudioData:(NSData *) data length:(int) length;
@end
@interface IMAManager : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;

@property(weak) id<IMAKitDelegate> delegate;
@property(nonatomic,assign,readonly) BOOL isActive;//蓝牙是否可用
@property(nonatomic,assign,readonly) BOOL isConnected;//蓝牙是否已连接
//搜索
-(void) startScan;
//停止
-(void) stopScan;
//根据名字搜索并连接设备
-(void) startScanWithName:(NSString *) name;
//连接蓝牙
-(void) connect:(CBPeripheral *) peripheral;
//断开蓝牙
-(void) disconnect;

//写数据
-(void) write:(NSData *) data;

/**
 * 开始录音
 */
-(void) startSpeech;

/**
 * 结束录音
 */
-(void) stopSpeech;
@end

NS_ASSUME_NONNULL_END

