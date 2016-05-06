//
//  SearchPickUpView.m
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "SearchPickUpView.h"

@implementation SearchPickUpView

- (void)awakeFromNib {
    _startField.delegate = self;
    _endField.delegate = self;
    _userNameField.delegate = self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_getCurrentTextField) {
        _getCurrentTextField(textField);
    }
    return YES;
}

- (IBAction)searchClick:(id)sender {
    if (_searchClick) {
        _searchClick();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"bbb:   %@",textField.text);
    [textField resignFirstResponder];
    return YES;
}
@end
