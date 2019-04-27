//
//  Message.h
//  WeChatPlugin
//
//  Created by Vian on 2019/4/27.
//  Copyright © 2019 tk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *to;
@property(nonatomic, copy) NSString *content;

@end
