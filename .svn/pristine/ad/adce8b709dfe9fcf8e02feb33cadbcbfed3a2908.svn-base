//
//  InputMsgTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/8/11.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "InputMsgTableViewCell.h"

@implementation InputMsgTableViewCell

- (void)awakeFromNib {
    _titleTextField.delegate = self;
    _selectedTextField.delegate = self;
}

- (void)setDelegagte {
    _titleTextField.delegate = self;
    _selectedTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_noticeEdit) {
        _noticeEdit();
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField != _selectedTextField) {
        if (_noticeText) {
            _noticeText();
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if (_noticeText) {
//        _noticeText();
//    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
