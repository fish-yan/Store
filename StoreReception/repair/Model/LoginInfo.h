//
//  LoginInfo.h
//  Repair
//
//  Created by Kassol on 15/9/10.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject

@property (strong, nonatomic) NSString *storeID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSString *name;

+ (instancetype)sharedLoginInfo;
- (BOOL)isDirector;

@end
