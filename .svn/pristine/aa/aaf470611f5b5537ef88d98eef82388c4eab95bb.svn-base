//
//  SearchHistoryPriceView.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/23.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "SearchHistoryPriceView.h"

@implementation SearchHistoryPriceView

- (void)awakeFromNib {
    _beginTextField.delegate = self;
    _endTextField.delegate = self;
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

@end
