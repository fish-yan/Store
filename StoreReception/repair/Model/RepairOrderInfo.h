//
//  RepairOrderInfo.h
//  Repair
//
//  Created by Kassol on 15/9/11.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepairOrderInfo : NSObject
@property (nonatomic, strong) NSMutableDictionary *isSelectDict;
+ (instancetype)sharedRepairOrderInfo;

- (void)setRepairOrderWithResponse:(NSDictionary *)response fromRework:(BOOL)fromRework;
- (NSDictionary *)getRepairOrderWithID:(NSString *)orderId;
- (void)addWorkers:(NSArray *)workers inCarID:(NSString *)carID withIndex:(NSInteger)index;
- (NSDictionary *)getRepairPersonOptionWithCarID:(NSString *)carID;
- (void)removeObjectWithCarID:(NSString *)carID;
- (void)changeWorkTime:(NSString *)workTime withCarID:(NSString *)carID withProjectIndex:(NSInteger)projectIndex withIndex:(NSInteger)index;
- (void)changeMoney:(NSString *)money withCarID:(NSString *)carID withProjectIndex:(NSInteger)projectIndex withIndex:(NSInteger)index;
- (void)clearCache;
- (NSMutableArray *)getWorkersWithIndex:(NSInteger)index inCarID:(NSString *)carID;
@end
