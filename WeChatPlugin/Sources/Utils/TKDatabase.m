//
//  TKDatabase.m
//  WeChatPlugin
//
//  Created by TK on 2019/4/27.
//  Copyright © 2019 tk. All rights reserved.
//

#import "TKDatabase.h"
#import <FMDB.h>
#import <sqlite3.h>

#define DATABASE_KEY @"wechat"

@implementation TKDatabase

+ (void)init{

    NSString *path = [self path];
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    if (![fm fileExistsAtPath:path]){
        [FMDatabase databaseWithPath:path];
    }
    
    const char * sql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' as unencrypt KEY ''", path] UTF8String];
    sqlite3 *encrypted_db;
    if (sqlite3_open([path UTF8String], &encrypted_db) == SQLITE_OK){
        
        NSLog(@"encrypt database");
        NSData *keyData = [NSData dataWithBytes:[DATABASE_KEY UTF8String] length:(NSUInteger)strlen([DATABASE_KEY UTF8String])];
        NSLog(@"secret:%@", keyData);
        sqlite3_key(encrypted_db, [keyData bytes], (int)[keyData length]);
        
        sqlite3_exec(encrypted_db, sql, NULL, NULL, NULL);
        sqlite3_exec(encrypted_db, "SELECT sqlcipher_export('unencrypt');", NULL, NULL, NULL);
        sqlite3_exec(encrypted_db, "DETACH DATABASE unencrypt;", NULL, NULL, NULL);
        sqlite3_close(encrypted_db);
        
    }else{
        
        sqlite3_close(encrypted_db);
    }
    
    [self initTable];
}

+ (NSString *)path{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSSharedPublicDirectory, NSUserDomainMask, YES);
    NSString * libraryPath = [paths lastObject];
    NSString *path = [libraryPath stringByAppendingPathComponent:@"temp"];
    
    return path;
}

+ (FMDatabaseQueue *)queue{
    NSString *path = [self path];
    
    static FMDatabaseQueue *queue;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        queue = [FMDatabaseQueue databaseQueueWithPath:path
                                                 flags:(SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE )];
    });
    
    return queue;
}

+ (void)initTable{
    
    NSString *sql = @"create table if not exists message(id integer NOT NULL primary key AUTOINCREMENT, sender varchar(255), receiver varchar(255), content varchar(255), create_time integer, type integer)";
    
    FMDatabaseQueue *queue = [self queue];
    [queue inDatabase:^(FMDatabase * _Nonnull database) {
        
        [database setKey:DATABASE_KEY];
        
        [database executeUpdate:sql];
    }];
}

+ (void)saveMessage:(NSString *)content
         withSender:(NSString *)sender
        andReceiver:(NSString *)receiver
       atCreateTime:(int)createtime
               type:(int)type{
    
    NSString *sql = @"insert into message(sender, receiver, content, create_time, type) values(?, ?, ?, ?, ?)";
    NSArray *params = @[sender, receiver, content, @(createtime), @(type)];
    
    FMDatabaseQueue *queue = [self queue];
    [queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        [db setKey:DATABASE_KEY];
        
        [db executeUpdate:sql withArgumentsInArray:params];
    }];
}
@end
