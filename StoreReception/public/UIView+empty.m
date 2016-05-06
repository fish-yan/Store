//
//  UIView+empty.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/14.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "UIView+empty.h"
#import "NoDataView.h"

@implementation UIView (empty)


- (void)showEmpty {
    NoDataView *ndv = [[[NSBundle mainBundle] loadNibNamed:@"NoDataView" owner:self options:nil] lastObject];
    BOOL bol = NO;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[NoDataView class]]) {
            bol = YES;
            break;
        }
    }
    if (!bol) {
        [self addSubview:ndv];
        [ndv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
}

- (void)hiddenEmpty {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[NoDataView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

@end
