//
//  ScanningView.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/17.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ScanningView.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ScanningView () {
    UIImageView *line;
    UIButton *btn;
}

@end

@implementation ScanningView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
    CGContextFillRect(context, CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)));
    CGContextStrokePath(context);
    if ([_funType isEqualToString:QRCODE]) {
        _leftWidth = 50;
        _width = CGRectGetWidth(self.frame) - _leftWidth * 2;
        _height = _width;
        _topHeight = (CGRectGetHeight(self.frame) - _height - 150) / 2;
    }else {
        _leftWidth = 20;
        _width = CGRectGetWidth(self.frame) - _leftWidth * 2;
        _height = _width*1/2;
        _topHeight = (CGRectGetHeight(self.frame) - _height - 150) / 2 + 32;
    }
    CGContextClearRect(context, CGRectMake(_leftWidth, _topHeight, _width, _height));
    [self initScanView];
    [self initBottomView];
    upOrdown = NO;
    num = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

- (void)initScanView {
    UIImageView *imgViewLu = [[UIImageView alloc] initWithFrame:CGRectMake(_leftWidth, _topHeight, 16, 16)];
    imgViewLu.image = [UIImage imageNamed:@"扫码框1"];
    [self addSubview:imgViewLu];
    UIImageView *imgViewLb = [[UIImageView alloc] initWithFrame:CGRectMake(_leftWidth, _topHeight+_height-16, 16, 16)];
    imgViewLb.image = [UIImage imageNamed:@"扫码框3"];
    [self addSubview:imgViewLb];
    UIImageView *imgViewRu = [[UIImageView alloc] initWithFrame:CGRectMake(_leftWidth+_width-16, _topHeight, 16, 16)];
    imgViewRu.image = [UIImage imageNamed:@"扫码框2"];
    [self addSubview:imgViewRu];
    UIImageView *imgViewRb = [[UIImageView alloc] initWithFrame:CGRectMake(_leftWidth+_width-16, _topHeight+_height-16, 16, 16)];
    imgViewRb.image = [UIImage imageNamed:@"扫码框4"];
    [self addSubview:imgViewRb];
    if ([_funType isEqualToString:QRCODE]) {
        line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_line"]];
    }else {
        line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_line_recognize"]];
    }
    
    [self addSubview:line];
}

- (void)initBottomView {
    WS(ws);
    UIView *bottomView = UIView.new;
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 21)];
    if ([_funType isEqualToString:QRCODE]) {
        label.text = @"将二维码/条码放入框内，即可自动扫描";
    }else {
        label.text = @"将车牌放入框内，即可自动扫描";
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = UIColorFromRGB(0xC9C9C9);
    [bottomView addSubview:label];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([_funType isEqualToString:QRCODE]) {
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromRGB(0x2878D2) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.frame = CGRectMake((CGRectGetWidth(self.frame)-30)/2, CGRectGetHeight(label.frame)+28, 30, 30);
    }else {
        [btn setBackgroundImage:[UIImage imageNamed:@"scan_拍照-普通"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"scan_拍照-点击"] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake((CGRectGetWidth(self.frame)-52)/2, CGRectGetHeight(label.frame)+28, 52, 52);
    }
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn];
    float bottomeViewHeight = CGRectGetHeight(label.frame) + 28 + CGRectGetHeight(btn.frame);
    float bottomHeight = (CGRectGetHeight(self.frame) - _height - _topHeight - bottomeViewHeight) / 2;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(ws.bottom).offset(-bottomHeight);
        make.height.mas_equalTo(bottomeViewHeight);
        make.left.equalTo(ws.left);
        make.right.equalTo(ws.right);
    }];
}

- (void)backAction {
    if ([_funType isEqualToString:QRCODE]) {
        [_timer invalidate];
        if (_cancelClick) {
            _cancelClick();
        }
    }else {
        if (_commitClick) {
            _commitClick();
        }
    }
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        if ([_funType isEqualToString:QRCODE]) {
            if (2*num >= _height) {
                upOrdown = YES;
            }
        }else {
            if (2*num >= _width) {
                upOrdown = YES;
            }
        }
    }
    else {
        num --;
        if (num <= 0) {
            upOrdown = NO;
        }
    }
    if ([_funType isEqualToString:QRCODE]) {
        line.frame = CGRectMake(_leftWidth, _topHeight+2*num, _width, 2);
    }else {
        line.frame = CGRectMake(_leftWidth+2*num, _topHeight, 2, _height);
    }
}

- (void)setBtnEnabled:(BOOL)enabled {
    btn.enabled = enabled;
}

@end
