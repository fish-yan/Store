//
//  FirstCheck.m
//  StoreReception
//
//  Created by cjm-ios on 15/8/31.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "FirstCheck.h"

@interface FirstCheck () {
    NSArray *initArray;
    NSMutableArray *addArray;
}

@end

@implementation FirstCheck

- (void)awakeFromNib {
    [self resetView];
}

- (IBAction)boClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    [self setBtnAloneSelectedBg:sender];
    if (tag == 1) {
        [self setBtnNormalBg:_blYesBtn];
        _blNoBol = YES;
        _blYesBol = NO;
    }else {
        [self setBtnNormalBg:_blNoBtn];
        _blNoBol = NO;
        _blYesBol = YES;
    }
}

- (IBAction)ybClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    [self setBtnAloneSelectedBg:sender];
    if (tag == 3) {
        [self setBtnNormalBg:_ybYesBtn];
        _ybNoBol = YES;
        _ybYesBol = NO;
    }else {
        [self setBtnNormalBg:_ybNoBtn];
        _ybNoBol = NO;
        _ybYesBol = YES;
    }
}

- (IBAction)jjClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    [self setBtnAloneSelectedBg:sender];
    if (tag == 5) {
        [self setBtnNormalBg:_jjYesBtn];
        _jjNoBol = YES;
        _jjYesBol = NO;
    }else {
        [self setBtnNormalBg:_jjNoBtn];
        _jjNoBol = NO;
        _jjYesBol = YES;
    }
}

- (IBAction)cnClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    [self setBtnAloneSelectedBg:sender];
    if (tag == 7) {
        [self setBtnNormalBg:_cnYesBtn];
        _cnNoBol = YES;
        _cnYesBol = NO;
    }else {
        [self setBtnNormalBg:_cnNoBtn];
        _cnNoBol = NO;
        _cnYesBol = YES;
    }
}

- (IBAction)scClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    [self setBtnAloneSelectedBg:sender];
    if (tag == 9) {
        [self setBtnNormalBg:_scYesBtn];
        _scNoBol = YES;
        _scYesBol = NO;
    }else {
        [self setBtnNormalBg:_scNoBtn];
        _scNoBol = NO;
        _scYesBol = YES;
    }
}

- (void)setBtnAloneSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"单选"] forState:UIControlStateNormal];
}

- (void)setBtnNormalBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
}

- (void)addDict:(NSString *)key value:(NSString *)value {
    NSDictionary *dict = @{@"key":key,@"value":value};
    [addArray addObject:dict];
}

- (NSMutableArray *)getData {
    if (_blNoBol) {
        [self addDict:@"SurfaceGlass" value:@"N"];
    }else if (_blYesBol){
        [self addDict:@"SurfaceGlass" value:@"Y"];
    }
    if (_ybNoBol) {
        [self addDict:@"SurfaceMeter" value:@"N"];
    }else if (_ybYesBol){
        [self addDict:@"SurfaceMeter" value:@"Y"];
    }
    if (_jjNoBol) {
        [self addDict:@"SurfaceOld" value:@"N"];
    }else if (_jjYesBol){
        [self addDict:@"SurfaceOld" value:@"Y"];
    }
    if (_cnNoBol) {
        [self addDict:@"SurfacePrecious" value:@"N"];
    }else if (_cnYesBol){
        [self addDict:@"SurfacePrecious" value:@"Y"];
    }
    if (_scNoBol) {
        [self addDict:@"SurfaceTrial" value:@"N"];
    }else if (_scYesBol){
        [self addDict:@"SurfaceTrial" value:@"Y"];
    }
    return addArray;
}

- (void)resetView {
    _blNoBol = NO;
    _blYesBol = NO;
    _ybNoBol = NO;
    _ybYesBol = NO;
    _jjNoBol = NO;
    _jjYesBol = NO;
    _cnNoBol = NO;
    _cnYesBol = NO;
    _scNoBol = NO;
    _scYesBol = NO;
    addArray = [[NSMutableArray alloc] init];
    [self boClick:_blNoBtn];
    [self ybClick:_ybNoBtn];
    [self jjClick:_jjNoBtn];
    [self cnClick:_cnNoBtn];
    [self scClick:_scNoBtn];
}

@end
