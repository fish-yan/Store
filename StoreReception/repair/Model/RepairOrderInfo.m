//
//  RepairOrderInfo.m
//  Repair
//
//  Created by Kassol on 15/9/11.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "RepairOrderInfo.h"
#import "LoginInfo.h"
#include "JDStatusBarNotification.h"
#include "Utils.h"

@interface RepairOrderInfo ()
@property (strong, nonatomic) NSMutableDictionary *repairOrder;
@end

@implementation RepairOrderInfo

static RepairOrderInfo *sharedInstance = nil;

- (instancetype)init {
    self = [super init];
    _repairOrder = [NSMutableDictionary dictionary];
    _isSelectDict = [NSMutableDictionary dictionary];
    return self;
}

+ (instancetype)sharedRepairOrderInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setRepairOrderWithResponse:(NSDictionary *)response fromRework:(BOOL)fromRework{
    NSMutableDictionary *repair = [[response objectForKey:@"Result"] mutableCopy];
    NSMutableArray *Projects = [[repair objectForKey:@"ConPros"] mutableCopy];
    for (NSInteger index = 0; index < [Projects count]; ++index) {
        NSMutableDictionary *project = [[Projects objectAtIndex:index] mutableCopy];
        if ([[project objectForKey:@"Status"] isEqualToString:@"9"]) {
            continue;
        }
        if (fromRework && [[project objectForKey:@"Status"] isEqualToString:@"2"]) {
            continue;
        }
        [project setObject:@"0" forKey:@"ProjectStatus"];
        [Projects setObject:project atIndexedSubscript:index];
    }
    [repair setObject:Projects forKey:@"ConPros"];
    [_repairOrder setObject:repair forKey:[repair objectForKey:@"ID"]];
}

- (NSDictionary *)getRepairOrderWithID:(NSString *)orderId {
    return [_repairOrder objectForKey:orderId];
}

- (void)addWorkers:(NSArray *)workers inCarID:(NSString *)carID withIndex:(NSInteger)index {
    NSMutableDictionary *repair = [[_repairOrder objectForKey:carID] mutableCopy];
    NSMutableArray *Projects = [[repair objectForKey:@"ConPros"] mutableCopy];
    NSMutableDictionary *project = [[Projects objectAtIndex:index] mutableCopy];
    if (![[project objectForKey:@"Status"] isEqualToString:@"2"]) {
        [project setObject:workers forKey:@"Workers"];
        if ([workers count] == 0) {
            [project setObject:@"0" forKey:@"ProjectStatus"];
        } else {
            [project setObject:@"1" forKey:@"ProjectStatus"];
        }
    }
    [Projects setObject:project atIndexedSubscript:index];
    [repair setObject:Projects forKey:@"ConPros"];
    [_repairOrder setObject:repair forKey:carID];
}

- (NSMutableArray *)getWorkersWithIndex:(NSInteger)index inCarID:(NSString *)carID {
    NSMutableArray *workers = [NSMutableArray array];
    NSMutableDictionary *repair = [[_repairOrder objectForKey:carID] mutableCopy];
    NSMutableArray *Projects = [[repair objectForKey:@"ConPros"] mutableCopy];
    NSMutableDictionary *project = [[Projects objectAtIndex:index] mutableCopy];
    for (NSDictionary *worker in [project objectForKey:@"Workers"]) {
        [workers addObject:[worker objectForKey:@"FID"]];
    }
    return workers;
}

- (NSDictionary *)getRepairPersonOptionWithCarID:(NSString *)carID {
    NSDictionary *repair = [_repairOrder objectForKey:carID];
    NSArray *Projects = [repair objectForKey:@"ConPros"];
    BOOL isDelievered = YES;
    for (NSDictionary *project in Projects) {
        if ([[project objectForKey:@"ProjectStatus"] isEqualToString:@"0"] && ![[project objectForKey:@"Status"] isEqualToString:@"9"]) {
            isDelievered = NO;
            break;
        }
    }
    if (isDelievered) {
        NSMutableDictionary *option = [NSMutableDictionary dictionary];
        [option setObject:[repair objectForKey:@"ID"] forKey:@"MentId"];
        NSMutableArray *giveRepairs = [NSMutableArray array];
        for (NSInteger i = 0; i <[Projects count]; ++i) {
            if ([[Projects[i] objectForKey:@"Status"] isEqualToString:@"9"]) {
                continue;
            }
            NSArray *workers = [Projects[i] objectForKey:@"Workers"];
            float totalPrice = 0;
            float totalWorkTime = 0;
            for (NSInteger j = 0; j <[workers count]; ++j) {
                NSMutableDictionary *giveRepair = [NSMutableDictionary dictionary];
                [giveRepair setObject:[Projects[i] objectForKey:@"ProjectID"] forKey:@"ProjectId"];
                NSString *price = [workers[j] objectForKey:@"Price"];
                if ([price isEqualToString:@""]) {
                    [JDStatusBarNotification showWithStatus:ERROR_TEXTFIELDNONE dismissAfter:2];
                    return nil;
                }
                NSScanner* scan = [NSScanner scannerWithString:price];
                float var;
                if (![scan scanFloat:&var] || ![scan isAtEnd]) {
                    [JDStatusBarNotification showWithStatus:ERROR_NONUMBER dismissAfter:2];
                    return nil;
                }
                if (var < 0) {
                    [JDStatusBarNotification showWithStatus:ERROR_NUMBERLESSTHANZERO dismissAfter:2];
                    return nil;
                }
                totalPrice += var;
                [giveRepair setObject:price forKey:@"Price"];
                NSString *workTime = [workers[j] objectForKey:@"WorkTime"];
                if ([workTime isEqualToString:@""]) {
                    [JDStatusBarNotification showWithStatus:ERROR_TEXTFIELDNONE dismissAfter:2];
                    return nil;
                }
                scan = [NSScanner scannerWithString:workTime];
                if (![scan scanFloat:&var] || ![scan isAtEnd]) {
                    [JDStatusBarNotification showWithStatus:ERROR_NONUMBER dismissAfter:2];
                    return nil;
                }
                if (var < 0) {
                    [JDStatusBarNotification showWithStatus:ERROR_NUMBERLESSTHANZERO dismissAfter:2];
                    return nil;
                }
                totalWorkTime += var;
                [giveRepair setObject:workTime forKey:@"WorkTime"];
                [giveRepair setObject:[workers[j] objectForKey:@"Name"] forKey:@"Name"];
                [giveRepair setObject:[workers[j] objectForKey:@"FID"] forKey:@"UserID"];
                [giveRepairs addObject:giveRepair];
            }
            if (totalWorkTime-[[Projects[i] objectForKey:@"workTime"] floatValue] > 1e-5) {
                [JDStatusBarNotification showWithStatus:ERROR_WORKTIME dismissAfter:2];
                return nil;
            }
            if (totalPrice-[[Projects[i] objectForKey:@"TotalPay"] floatValue] >1e-5) {
                [JDStatusBarNotification showWithStatus:ERROR_WORKTIMEPRICE dismissAfter:2];
                return nil;
            }
        }
        [option setObject:giveRepairs forKey:@"giveRepairs"];
        NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *token = [userInfo objectForKey:@"Token"];
        [userToken setObject:userId forKey:@"UserId"];
        [userToken setObject:token forKey:@"Token"];
        [option setObject:userToken forKey:@"UserToken"];
        return option;
    } else {
        [JDStatusBarNotification showWithStatus:ERROR_NOTDELIEVERED dismissAfter:2];
    }
    return nil;
}

- (void)removeObjectWithCarID:(NSString *)carID {
    [_repairOrder removeObjectForKey:carID];
    [_isSelectDict removeObjectForKey:carID];
}

- (void)changeWorkTime:(NSString *)workTime withCarID:(NSString *)carID withProjectIndex:(NSInteger)projectIndex withIndex:(NSInteger)index {
    NSLog(@"%@", _repairOrder);
    NSMutableDictionary *repair = [[_repairOrder objectForKey:carID] mutableCopy];
    NSMutableArray *Projects = [[repair objectForKey:@"ConPros"] mutableCopy];
    NSMutableDictionary *project = [[Projects objectAtIndex:projectIndex] mutableCopy];
    NSMutableArray *workers = [[project objectForKey:@"Workers"] mutableCopy];
    NSMutableDictionary *worker = [[workers objectAtIndex:index] mutableCopy];
    [worker setObject:workTime forKey:@"WorkTime"];
    [workers setObject:worker atIndexedSubscript:index];
    [project setObject:workers forKey:@"Workers"];
    [Projects setObject:project atIndexedSubscript:projectIndex];
    [repair setObject:Projects forKey:@"ConPros"];
    [_repairOrder setObject:repair forKey:carID];
}

- (void)changeMoney:(NSString *)money withCarID:(NSString *)carID withProjectIndex:(NSInteger)projectIndex withIndex:(NSInteger)index {
    NSMutableDictionary *repair = [[_repairOrder objectForKey:carID] mutableCopy];
    NSMutableArray *Projects = [[repair objectForKey:@"ConPros"] mutableCopy];
    NSMutableDictionary *project = [[Projects objectAtIndex:projectIndex] mutableCopy];
    NSMutableArray *workers = [[project objectForKey:@"Workers"] mutableCopy];
    NSMutableDictionary *worker = [[workers objectAtIndex:index] mutableCopy];
    [worker setObject:money forKey:@"Price"];
    [workers setObject:worker atIndexedSubscript:index];
    [project setObject:workers forKey:@"Workers"];
    [Projects setObject:project atIndexedSubscript:projectIndex];
    [repair setObject:Projects forKey:@"ConPros"];
    [_repairOrder setObject:repair forKey:carID];
}

- (void)clearCache {
    [_repairOrder removeAllObjects];
}

@end
