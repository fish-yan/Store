//
//  ToolKit.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/28.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolKit : NSObject 

+ (NSString*)deviceString;
+ (BOOL)isPureInt:(NSString*)string;
+ (BOOL)isPureFloat:(NSString*)string;
+ (NSString *)getStringVlaue:(id)object;


@end
