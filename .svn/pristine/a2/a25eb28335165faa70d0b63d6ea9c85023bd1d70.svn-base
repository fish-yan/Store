//
//  OrderTypeView.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/23.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "OrderTypeView.h"

@implementation OrderTypeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)serviceClick:(id)sender {
    if (!_serviceBol) {
        [self setBtnSelectedBg:sender];
        [self setBtnNormalBg:_repairBtn];
        _serviceBol = YES;
        _repairBol = NO;
    }
}

- (IBAction)repairClick:(id)sender {
    if (!_repairBol) {
        [self setBtnSelectedBg:sender];
        [self setBtnNormalBg:_serviceBtn];
        _repairBol = YES;
        _serviceBol = NO;
    }
}

- (void)setBtnSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"单选"] forState:UIControlStateNormal];
}

- (void)setBtnNormalBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
}

@end
