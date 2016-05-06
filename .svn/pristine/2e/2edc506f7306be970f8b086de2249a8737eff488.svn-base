//
//  PersonContentTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "PersonContentTableViewCell.h"

@implementation PersonContentTableViewCell

- (void)awakeFromNib {
    _timeTextField.delegate = self;
    _priceTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _timeTextField) {
        if (_passValue) {
            _passValue(_timeTextField.text);
        }
    }else {
        if (_passPrice) {
            _passPrice(_priceTextField.text);
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_passCurrentCell) {
        _passCurrentCell(self);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
