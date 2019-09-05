//
//  EVSSqliteManager.h
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/25.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;
NS_ASSUME_NONNULL_BEGIN

@interface EVSSqliteManager : NSObject
/**
 *  单例
 */
+(instancetype) shareInstance;
@property(nonatomic,strong) FMDatabaseQueue *queue;//线程安全
/**
 *  创建数据库
 */
-(void) create;

/**
 *  打开数据库
 */
-(void) open;

/**
 *  关闭数据库
 */
-(void) close;

/**
 *  插入
 *  tableName : 表名
 */
-(void) insert:(NSDictionary *) dict tableName:(NSString *) tableName;

/**
 *  更新
 *  tableName : 表名
 */
-(void) update:(NSDictionary *) dict device_id:(NSString *)device_id tableName:(NSString *) tableName;
/**
 *  更新
 */
-(void) update:(NSDictionary *) dict client_id:(NSString *)client_id tableName:(NSString *) tableName;
/**
 *  删除
 *  tableName : 表名
 */
-(void) deleted:(NSString *)device_id tableName:(NSString *) tableName;

/**
 * 根据deviceId查询
 *  tableName : 表名
 */
-(void) queryConfig:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict;
/**
 * 同步根据deviceId查询
 */
-(NSDictionary *) asynQueryConfig:(NSString *)device_id tableName:(NSString *) tableName;

/**
 * 根据deviceId查询
 * tableName : 表名
 */
-(void) queryHeader:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict;
/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQueryHeader:(NSString *)device_id tableName:(NSString *) tableName;

/**
 * 根据deviceId查询
 */
-(void) queryContext:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict;
/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQueryContext:(NSString *)device_id tableName:(NSString *) tableName;
/**
 * 根据deviceId查询
 */
-(void) querySystem:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict;
/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQuerySystem:(NSString *)device_id tableName:(NSString *) tableName;
@end

NS_ASSUME_NONNULL_END
