  //
//  IncreaseView.m
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "IncreaseView.h"

@implementation IncreaseView

- (void)awakeFromNib {
    _orederIdField.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_pushView) {
        _pushView();
    }
    return NO;
}

@end
