//
//  TKDatabase.h
//  WeChatPlugin
//
//  Created by TK on 2019/4/27.
//  Copyright © 2019 tk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKDatabase : NSObject

+ (void)init;

+ (void)saveMessage:(NSString *)content
         withSender:(NSString *)sender
        andReceiver:(NSString *)receiver
       atCreateTime:(int)createTime
               type:(int)type;
@end

