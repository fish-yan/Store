//
//  LoginInfo.m
//  Repair
//
//  Created by Kassol on 15/9/10.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "LoginInfo.h"

@implementation LoginInfo

static LoginInfo *sharedInstance = nil;

- (instancetype)init {
    self = [super init];
    self.storeID = @"";
    self.userID = @"";
    self.token = @"";
    self.groupName = @"";
    self.name = @"";
    return self;
}

+ (instancetype)sharedLoginInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isDirector {
    return [_groupName isEqualToString:@"车间主管"];
}

@end
