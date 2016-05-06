//
//  KZChartItem.m
//  IntelliTerminal
//
//  Created by Kassol on 15/8/7.
//  Copyright (c) 2015年 Kassol. All rights reserved.
//

#import "KZChartItem.h"

@implementation KZChartItem

+ (instancetype)dataItemWithValue:(CGFloat)value color:(UIColor *)color {
    KZChartItem *item = [KZChartItem new];
    item.value = value;
    item.color = color;
    return item;
}

- (void)setValue:(CGFloat)value{
    NSAssert(value >= 0, @"value should >= 0");
    if (value != _value){
        _value = value;
    }
}

@end
