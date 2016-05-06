//
//  SearchView.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/14.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

- (void)awakeFromNib {
    _begainTextField.delegate = self;
    _endTextField.delegate = self;
    _serviceBol = YES;
    _washBol = YES;
    _itemBol = YES;
    _pickBol = YES;
    _increaseBol = YES;
}

- (IBAction)searchClick:(id)sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (_serviceBol) {
        [dict setObject:@"\'项目结算单\'" forKey:@"service"];
    }
    if (_itemBol) {
        [dict setObject:@"\'商品零售单\'" forKey:@"item"];
    }
    if (_washBol) {
        [dict setObject:@"\'洗车单\'" forKey:@"wash"];
    }
    if (_pickBol) {
        [dict setObject:@"\'维修单\'" forKey:@"pick"];
    }
    if (_increaseBtn) {
        [dict setObject:@"\'增项单\'" forKey:@"increase"];
    }
    if (_searchClick) {
        _searchClick(dict);
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_getCurrentTextField) {
        _getCurrentTextField(textField);
    }
    return YES;
}

- (IBAction)serviceClick:(id)sender {
    _serviceBol = !_serviceBol;
    if (_serviceBol) {
        [_serviceBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_serviceBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
}

- (IBAction)washClick:(id)sender {
    _washBol = !_washBol;
    if (_washBol) {
        [_washBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_washBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
}

- (IBAction)itemClick:(id)sender {
    _itemBol = !_itemBol;
    if (_itemBol) {
        [_itemBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_itemBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
}

- (IBAction)pickClick:(id)sender {
    _pickBol = !_pickBol;
    if (_pickBol) {
        [_pickBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_pickBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
}

- (IBAction)increaseClick:(id)sender {
    _increaseBol = !_increaseBol;
    if (_increaseBol) {
        [_increaseBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_increaseBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
}
@end
