//
//  WashView.m
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "WashView.h"

@implementation WashView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)selectedClick:(id)sender {
    if (_addWash) {
        _addWash();
    }
}

@end
