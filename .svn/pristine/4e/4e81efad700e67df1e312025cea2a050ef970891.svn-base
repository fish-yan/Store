//
//  TCardServiceSubView.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/4.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "TCardServiceSubView.h"

@implementation TCardServiceSubView

- (void)awakeFromNib {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    [self addGestureRecognizer:gestureRecognizer];
}

- (void)click:(UITapGestureRecognizer *)gestureRecognizer {
    if (_clickBol) {
        _imgV.image = [UIImage imageNamed:@"未选"];
    }else {
        _imgV.image = [UIImage imageNamed:@"勾选"];
    }
    _clickBol = !_clickBol;
}

@end
