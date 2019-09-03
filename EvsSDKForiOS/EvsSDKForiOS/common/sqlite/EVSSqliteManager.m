//
//  EVSSqliteManager.m
//  EvsSDKForiOS
//
//  Created by 周经伟 on 2019/7/25.
//  Copyright © 2019 iflytek. All rights reserved.
//

#import "EVSSqliteManager.h"
#import "EVSHeader.h"
@interface EVSSqliteManager()
@property(nonatomic,strong) FMDatabase *db;
@property(nonatomic,copy) NSString *mPath;
@end

@implementation EVSSqliteManager
-(FMDatabase *) db{
    NSString *path = [self dataBasePath];
    if (!_db) {
        _db = [FMDatabase databaseWithPath:path];
    }
    return _db;
}

-(FMDatabaseQueue *) queue{
    NSString *path = [self dataBasePath];
    if (!_queue) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return _queue;
}
/**
 *  单例
 */
+(instancetype) shareInstance{
    static EVSSqliteManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
        [shareInstance create];
    });
    return shareInstance;
}

-(NSString *) dataBasePath{
    //1.创建database路径
    if (!self.mPath) {
        NSString *docuPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [docuPath stringByAppendingPathComponent:@"evs.db"];
        self.mPath = dbPath;
        return self.mPath;
    }
    return self.mPath;
}

/**
 *  创建数据库
 */
-(void) create{
    // 2.打开数据库
    [self.queue inDatabase:^(FMDatabase* fmdb) {
        NSString *createConfigSql = @"CREATE TABLE IF NOT EXISTS t_evs_config (client_id text NOT NULL, device_id text primary key, token_type text , access_token text , refresh_token text , expires_in integer , created_at integer ,ws_url text NOT NULL);";
        
        NSString *createHeaderSql = @"CREATE TABLE IF NOT EXISTS t_evs_header (device_id text primary key,latitude text,longitude text,kid boolean NOT NULL,full_duplex boolean NOT NULL);";
        
        NSString *createContextSql = @"CREATE TABLE IF NOT EXISTS t_evs_context (device_id text primary key,speaker_volume integer,speaker_volume_type text,playback_type text,playback_behavior text,playback_control text,playback_state text,playback_resource_id text,playback_offset integer,reply_key text,metadata_title text,metadata_artist text,metadata_album text,metadata_duration integer,request_id text,session_status text NOT NULL);";
        
        NSString *createSystemSql = @"CREATE TABLE IF NOT EXISTS t_evs_system (device_id text primary key,timestamp TIMESTAMP NOT NULL,enable_vad boolean,profile text,format text);";
        
        [fmdb executeUpdate:createConfigSql];
        [fmdb executeUpdate:createHeaderSql];
        [fmdb executeUpdate:createContextSql];
        [fmdb executeUpdate:createSystemSql];
    }];
    [self open];
}

/**
 *  打开数据库
 */
-(void) open{
    if ([self.db open]) {
        // do something
        EVSLog(@"success to open database...");
    }else {
        EVSLog(@"fail to open database...");
    }
}

/**
 *  关闭数据库
 */
-(void) close{
    BOOL isClose = [self.db close];
    if (isClose) {
        EVSLog(@"close database...");
    }
}

/**
 *  关闭线程队列
 */
-(void) closeQueue{
    [self.queue close];
}

/**
 *  插入
 */
-(void) insert:(NSDictionary *) dict tableName:(NSString *) tableName{
    [self.queue inDatabase:^(FMDatabase* fmdb) {
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (",tableName];
        int i = 0;
        for (NSString *key in dict) {
            if (i<dict.count-1) {
                sql = [sql stringByAppendingFormat:@"%@,",key];
            }else{
                sql = [sql stringByAppendingFormat:@"%@",key];
            }
            i++;
        }
        sql = [sql stringByAppendingFormat:@")"];
        sql = [sql stringByAppendingString:@" values ("];
        int j = 0;
        for (NSString *key in dict) {
            id value = dict[key];
            if (j<dict.count-1) {
                sql = [sql stringByAppendingFormat:@"'%@',",value];
            }else{
                sql = [sql stringByAppendingFormat:@"'%@'",value];
            }
            j++;
        }
        sql = [sql stringByAppendingFormat:@");"];
       
        [fmdb executeUpdate:sql];
    }];
}

/**
 *  更新
 */
-(void) update:(NSDictionary *) dict client_id:(NSString *)client_id tableName:(NSString *) tableName{
    [self.queue inDatabase:^(FMDatabase* fmdb) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set ",tableName];
        int i = 0;
        for (NSString *key in dict) {
            id value = dict[key];
            if (i<dict.count-1) {
                sql = [sql stringByAppendingFormat:@"%@='%@',",key,value];
            }else{
                sql = [sql stringByAppendingFormat:@"%@='%@'",key,value];
            }
            i++;
        }
        sql = [sql stringByAppendingFormat:@" where client_id='%@'",client_id];
        
        [fmdb executeUpdate:sql];
    }];
}

/**
 *  更新
 */
-(void) update:(NSDictionary *) dict device_id:(NSString *)device_id tableName:(NSString *) tableName{
    [self.queue inDatabase:^(FMDatabase* fmdb) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set ",tableName];
        int i = 0;
        for (NSString *key in dict) {
            id value = dict[key];
            if (i<dict.count-1) {
                sql = [sql stringByAppendingFormat:@"%@='%@',",key,value];
            }else{
                sql = [sql stringByAppendingFormat:@"%@='%@'",key,value];
            }
            i++;
        }
        sql = [sql stringByAppendingFormat:@" where device_id='%@'",device_id];
        
        [fmdb executeUpdate:sql];
    }];
}

/**
 *  删除
 */
-(void) deleted:(NSString *)device_id tableName:(NSString *) tableName{
    [self.queue inDatabase:^(FMDatabase* fmdb) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where device_id = '%@'",tableName,device_id];
        
        [fmdb executeUpdate:sql];
    }];
}

/**
 * 根据deviceId查询
 */
-(void) queryConfig:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    while ([rs next]) {
        NSString *client_id = [rs stringForColumnIndex:0];
        NSString *device_id = [rs stringForColumnIndex:1];
        NSString *token_type = [rs stringForColumnIndex:2];
        NSString *access_token = [rs stringForColumnIndex:3];
        NSString *refresh_token = [rs stringForColumnIndex:4];
        int expires_in = [rs intForColumnIndex:5];
        int created_at = [rs intForColumnIndex:6];
        NSString *ws_url = [rs stringForColumnIndex:7];
        
        if (client_id) {
            [dict setObject:client_id forKey:@"client_id"];
        }
        if (device_id) {
            [dict setObject:device_id forKey:@"device_id"];
        }
        if (token_type) {
            [dict setObject:token_type forKey:@"token_type"];
        }
        if (access_token) {
            [dict setObject:access_token forKey:@"access_token"];
        }
        if (refresh_token) {
            [dict setObject:refresh_token forKey:@"refresh_token"];
        }
        if (expires_in) {
            [dict setObject:@(expires_in) forKey:@"expires_in"];
        }
        if (created_at) {
            [dict setObject:@(created_at) forKey:@"created_at"];
        }
        if (ws_url) {
            [dict setObject:ws_url forKey:@"ws_url"];
        }
    }
    [rs close];
    resultDict(dict);
}

/**
 * 同步根据deviceId查询
 */
-(NSDictionary *) asynQueryConfig:(NSString *)device_id tableName:(NSString *) tableName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *client_id = [rs stringForColumnIndex:0];
            NSString *device_id = [rs stringForColumnIndex:1];
            NSString *token_type = [rs stringForColumnIndex:2];
            NSString *access_token = [rs stringForColumnIndex:3];
            NSString *refresh_token = [rs stringForColumnIndex:4];
            NSInteger expires_in = [rs intForColumnIndex:5];
            NSInteger created_at = [rs intForColumnIndex:6];
            NSString *ws_url = [rs stringForColumnIndex:7];
            
            if (client_id) {
                [dict setObject:client_id forKey:@"client_id"];
            }
            if (device_id) {
                [dict setObject:device_id forKey:@"device_id"];
            }
            if (token_type) {
                [dict setObject:token_type forKey:@"token_type"];
            }
            if (access_token) {
                [dict setObject:access_token forKey:@"access_token"];
            }
            if (refresh_token) {
                [dict setObject:refresh_token forKey:@"refresh_token"];
            }
            if (expires_in) {
                [dict setObject:@(expires_in) forKey:@"expires_in"];
            }
            if (created_at) {
                [dict setObject:@(created_at) forKey:@"created_at"];
            }
            if (ws_url) {
                [dict setObject:ws_url forKey:@"ws_url"];
            }
        }
        [rs close];
        dispatch_semaphore_signal(sem); //信号量+1
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
    return dict;
}

/**
 * 根据deviceId查询
 */
-(void) queryHeader:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    while ([rs next]) {
        NSString *device_id = [rs stringForColumnIndex:0];
        NSString *latitude = [rs stringForColumnIndex:1];
        NSString *longitude = [rs stringForColumnIndex:2];
        BOOL kid = [rs boolForColumnIndex:3];
        BOOL full_duplex = [rs boolForColumnIndex:4];
        
        if (device_id) {
            [dict setObject:device_id forKey:@"device_id"];
        }
        if (latitude) {
            [dict setObject:latitude forKey:@"latitude"];
        }
        if (longitude) {
            [dict setObject:longitude forKey:@"longitude"];
        }
        [dict setObject:@(kid) forKey:@"kid"];
        [dict setObject:@(full_duplex) forKey:@"full_duplex"];
    }
    [rs close];
    resultDict(dict);
}

/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQueryHeader:(NSString *)device_id tableName:(NSString *) tableName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *device_id = [rs stringForColumnIndex:0];
            NSString *latitude = [rs stringForColumnIndex:1];
            NSString *longitude = [rs stringForColumnIndex:2];
            BOOL kid = [rs boolForColumnIndex:3];
            BOOL full_duplex = [rs boolForColumnIndex:4];
            
            if (device_id) {
                [dict setObject:device_id forKey:@"device_id"];
            }
            if (latitude) {
                [dict setObject:latitude forKey:@"latitude"];
            }
            if (longitude) {
                [dict setObject:longitude forKey:@"longitude"];
            }
            [dict setObject:@(kid) forKey:@"kid"];
            [dict setObject:@(full_duplex) forKey:@"full_duplex"];
        }
        [rs close];
        dispatch_semaphore_signal(sem); //信号量+1
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
    
    return dict;
}

/**
 * 根据deviceId查询
 */
-(void) queryContext:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    while ([rs next]) {
        NSString *device_id = [rs stringForColumnIndex:0];
        NSInteger speaker_volume = [rs intForColumnIndex:1];
        NSString *speaker_volume_type = [rs stringForColumnIndex:2];
        NSString *playback_type = [rs stringForColumnIndex:3];
        NSString *playback_behavior = [rs stringForColumnIndex:4];
        NSString *playback_control = [rs stringForColumnIndex:5];
        NSString *playback_state = [rs stringForColumnIndex:6];
        NSString *playback_resource_id = [rs stringForColumnIndex:7];
        NSInteger playback_offset = [rs intForColumnIndex:8];
        
        NSString *reply_key = [rs stringForColumnIndex:9];
        NSString *metadata_title = [rs stringForColumnIndex:10];
        NSString *metadata_artist = [rs stringForColumnIndex:11];
        NSString *metadata_album = [rs stringForColumnIndex:12];
        NSInteger metadata_duration = [rs intForColumnIndex:13];
        NSString *request_id = [rs stringForColumnIndex:14];
        NSString *session_status = [rs stringForColumnIndex:15];
        if (device_id) {
            [dict setObject:device_id forKey:@"device_id"];
        }
        
        if (speaker_volume) {
            [dict setObject:@(speaker_volume) forKey:@"speaker_volume"];
        }
        if (speaker_volume_type) {
            [dict setObject:speaker_volume_type forKey:@"speaker_volume_type"];
        }
        if (playback_type) {
            [dict setObject:playback_type forKey:@"playback_type"];
        }
        if (playback_state) {
            [dict setObject:playback_state forKey:@"playback_state"];
        }
        if (playback_resource_id) {
            [dict setObject:playback_resource_id forKey:@"playback_resource_id"];
        }
        if (playback_offset) {
            [dict setObject:@(playback_offset) forKey:@"playback_offset"];
        }
        if (playback_behavior) {
            [dict setObject:playback_behavior forKey:@"playback_behavior"];
        }
        if (playback_control) {
            [dict setObject:playback_control forKey:@"playback_control"];
        }
        if (reply_key) {
            [dict setObject:reply_key forKey:@"reply_key"];
        }
        if (metadata_title) {
            [dict setObject:metadata_title forKey:@"metadata_title"];
        }
        if (metadata_artist) {
            [dict setObject:metadata_artist forKey:@"metadata_artist"];
        }
        if (metadata_album) {
            [dict setObject:metadata_album forKey:@"metadata_album"];
        }
        if (metadata_duration) {
            [dict setObject:@(metadata_duration) forKey:@"metadata_duration"];
        }
        if (request_id) {
            [dict setObject:request_id forKey:@"request_id"];
        }
        if (session_status) {
            [dict setObject:session_status forKey:@"session_status"];
        }
    }
    [rs close];
    resultDict(dict);
}

/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQueryContext:(NSString *)device_id tableName:(NSString *) tableName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *device_id = [rs stringForColumnIndex:0];
            NSInteger speaker_volume = [rs intForColumnIndex:1];
            NSString *speaker_volume_type = [rs stringForColumnIndex:2];
            NSString *playback_type = [rs stringForColumnIndex:3];
            NSString *playback_behavior = [rs stringForColumnIndex:4];
            NSString *playback_control = [rs stringForColumnIndex:5];
            NSString *playback_state = [rs stringForColumnIndex:6];
            NSString *playback_resource_id = [rs stringForColumnIndex:7];
            NSInteger playback_offset = [rs intForColumnIndex:8];
            
            NSString *reply_key = [rs stringForColumnIndex:9];
            NSString *metadata_title = [rs stringForColumnIndex:10];
            NSString *metadata_artist = [rs stringForColumnIndex:11];
            NSString *metadata_album = [rs stringForColumnIndex:12];
            NSInteger metadata_duration = [rs intForColumnIndex:13];
            NSString *request_id = [rs stringForColumnIndex:14];
            NSString *session_status = [rs stringForColumnIndex:15];
            if (device_id) {
                [dict setObject:device_id forKey:@"device_id"];
            }
            
            if (speaker_volume) {
                [dict setObject:@(speaker_volume) forKey:@"speaker_volume"];
            }
            if (speaker_volume_type) {
                [dict setObject:speaker_volume_type forKey:@"speaker_volume_type"];
            }
            if (playback_type) {
                [dict setObject:playback_type forKey:@"playback_type"];
            }
            if (playback_state) {
                [dict setObject:playback_state forKey:@"playback_state"];
            }
            if (playback_resource_id) {
                [dict setObject:playback_resource_id forKey:@"playback_resource_id"];
            }
            if (playback_offset) {
                [dict setObject:@(playback_offset) forKey:@"playback_offset"];
            }
            if (playback_behavior) {
                [dict setObject:playback_behavior forKey:@"playback_behavior"];
            }
            if (playback_control) {
                [dict setObject:playback_control forKey:@"playback_control"];
            }
            if (reply_key) {
                [dict setObject:reply_key forKey:@"reply_key"];
            }
            if (metadata_title) {
                [dict setObject:metadata_title forKey:@"metadata_title"];
            }
            if (metadata_artist) {
                [dict setObject:metadata_artist forKey:@"metadata_artist"];
            }
            if (metadata_album) {
                [dict setObject:metadata_album forKey:@"metadata_album"];
            }
            if (metadata_duration) {
                [dict setObject:@(metadata_duration) forKey:@"metadata_duration"];
            }
            if (request_id) {
                [dict setObject:request_id forKey:@"request_id"];
            }
            if (session_status) {
                [dict setObject:session_status forKey:@"session_status"];
            }
        }
        [rs close];
        dispatch_semaphore_signal(sem); //信号量+1
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
    return dict;
}

/**
 * 根据deviceId查询
 */
-(void) querySystem:(NSString *)device_id tableName:(NSString *) tableName callback:(void (^)(NSDictionary * _Nonnull)) resultDict{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
   
    FMResultSet *rs = [self.db executeQuery:sql];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    while ([rs next]) {
        NSString *device_id = [rs stringForColumnIndex:0];
        long long timestamp = [rs longLongIntForColumnIndex:1];
        BOOL enable_vad = [rs boolForColumnIndex:2];
        NSString *profile = [rs stringForColumnIndex:3];
        NSString *format = [rs stringForColumnIndex:4];
        if (device_id) {
            [dict setObject:device_id forKey:@"device_id"];
        }
        if (timestamp) {
            [dict setObject:@(timestamp) forKey:@"timestamp"];
        }
        [dict setObject:@(enable_vad) forKey:@"enable_vad"];
        if (profile) {
            [dict setObject:profile forKey:@"profile"];
        }
        if (format) {
            [dict setObject:format forKey:@"format"];
        }
    }
    [rs close];
    resultDict(dict);
}

/**
 * 根据deviceId查询
 */
-(NSDictionary *) asynQuerySystem:(NSString *)device_id tableName:(NSString *) tableName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where device_id = '%@'",tableName,device_id];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *device_id = [rs stringForColumnIndex:0];
            long long timestamp = [rs longLongIntForColumnIndex:1];
            BOOL enable_vad = [rs boolForColumnIndex:2];
            NSString *profile = [rs stringForColumnIndex:3];
            NSString *format = [rs stringForColumnIndex:4];
            if (device_id) {
                [dict setObject:device_id forKey:@"device_id"];
            }
            if (timestamp) {
                [dict setObject:@(timestamp) forKey:@"timestamp"];
            }
            [dict setObject:@(enable_vad) forKey:@"enable_vad"];
            if (profile) {
                [dict setObject:profile forKey:@"profile"];
            }
            if (format) {
                [dict setObject:format forKey:@"format"];
            }
        }
        [rs close];
        dispatch_semaphore_signal(sem); //信号量+1
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
    
    return dict;
}
@end
