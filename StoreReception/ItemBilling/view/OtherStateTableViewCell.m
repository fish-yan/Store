//
//  OtherStateTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "OtherStateTableViewCell.h"

@interface OtherStateTableViewCell () {
    NSArray *initArray;
}

@end

@implementation OtherStateTableViewCell

- (void)awakeFromNib {
    // Initialization code
    initArray = [[NSArray alloc] initWithObjects:_styBtn,_hsBtn,_axBtn,_pzBtn,_jjBtn,_zBtn,_hzBtn,_bzBtn,_zzBtn,_byTextField,_gjTextField,_cdTextField,_dyqTextField,_dhkTextField,_jhTextField,_qjdTextField, nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];
    _byTextField.delegate = self;
    _gjTextField.delegate = self;
    _cdTextField.delegate = self;
    _dyqTextField.delegate = self;
    _dhkTextField.delegate = self;
    _jhTextField.delegate = self;
    _qjdTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)stClick:(id)sender {
    _stBol = !_stBol;
    if (_stBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)hsClick:(id)sender {
    _hsBol = !_hsBol;
    if (_hsBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)axClick:(id)sender {
    _axBol = !_axBol;
    if (_axBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)pzClick:(id)sender {
    _pzBol = !_pzBol;
    if (_pzBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)xfClick:(id)sender {
    _xfBol = !_xfBol;
    if (_xfBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (void)setBtnSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    [_addArray addObject:btn];
}

- (void)setBtnAloneSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"单选"] forState:UIControlStateNormal];
    [_addArray addObject:btn];
}

- (void)setBtnNormalBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    [_addArray removeObject:btn];
}

- (IBAction)jjClick:(id)sender {
    if (!_jjBol) {
        [self setBtnAloneSelectedBg:sender];
        [self setBtnNormalBg:_zBtn];
        [self setBtnNormalBg:_hzBtn];
        _jjBol = YES;
        _zBol = NO;
        _hzBol = NO;
    }
}

- (IBAction)zClick:(id)sender {
    if (!_zBol) {
        [self setBtnAloneSelectedBg:sender];
        [self setBtnNormalBg:_jjBtn];
        [self setBtnNormalBg:_hzBtn];
        _zBol = YES;
        _jjBol = NO;
        _hzBol = NO;
    }
}
    
- (IBAction)hzClick:(id)sender {
    if (!_hzBol) {
        [self setBtnAloneSelectedBg:sender];
        [self setBtnNormalBg:_zBtn];
        [self setBtnNormalBg:_jjBtn];
        _hzBol = YES;
        _zBol = NO;
        _jjBol = NO;
    }
}

- (IBAction)bzClick:(id)sender {
    if (!_bzBol) {
        [self setBtnAloneSelectedBg:sender];
        [self setBtnNormalBg:_zzBtn];
        _bzBol = YES;
        _zzBol = NO;
    }
}

- (IBAction)zzClick:(id)sender {
    if (!_zzBol) {
        [self setBtnAloneSelectedBg:sender];
        [self setBtnNormalBg:_bzBtn];
        _zzBol = YES;
        _bzBol = NO;
    }
}

- (void)initData:(NSMutableArray *)array {
    _addArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++) {
        UIView *view = array[i];
        NSInteger aTag = view.tag;
        for (int j = 0; j < initArray.count; j++) {
            UIView *aView = initArray[j];
            NSInteger iTag = aView.tag;
            if (aTag == iTag) {
                if ([aView isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)aView;
                    [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
                    [_addArray addObject:btn];
                    break;
                }else {
                    UITextField *tf = (UITextField *)view;
                    UITextField *_tf = (UITextField *)aView;
                    _tf.text = tf.text;
                }
            }
        }
    }
}

- (void)checkValue {
    if (_byTextField.text.length > 0) {
        [_addArray addObject:_byTextField];
    }else {
        [_addArray removeObject:_byTextField];
    }
    if (_gjTextField.text.length > 0) {
        [_addArray addObject:_gjTextField];
    }else {
        [_addArray removeObject:_gjTextField];
    }
    if (_cdTextField.text.length > 0) {
        [_addArray addObject:_cdTextField];
    }else {
        [_addArray removeObject:_cdTextField];
    }
    if (_dyqTextField.text.length > 0) {
        [_addArray addObject:_dyqTextField];
    }else {
        [_addArray removeObject:_dyqTextField];
    }
    if (_dhkTextField.text.length > 0) {
        [_addArray addObject:_dhkTextField];
    }else {
        [_addArray removeObject:_dhkTextField];
    }
    if (_jhTextField.text.length > 0) {
        [_addArray addObject:_jhTextField];
    }else {
        [_addArray removeObject:_jhTextField];
    }
    if (_qjdTextField.text.length > 0) {
        [_addArray addObject:_qjdTextField];
    }else {
        [_addArray removeObject:_qjdTextField];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_setOffset) {
        NSInteger tag = textField.tag;
        NSInteger otag = _byTextField.tag;
        int t = tag - otag + 1;
        _setOffset(t);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (_backOffset) {
        _backOffset();
    }
    return YES;
}

-(void) keyboardHidden:(NSNotification*) notification {
    if (_backOffset) {
        _backOffset();
    }
}

@end
