//
//  AddServiceView.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "AddServiceView.h"

@implementation AddServiceView

- (void)awakeFromNib {
    _priceTextField.delegate = self;
    _workTimeTextField.delegate = self;
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *storeId = userInfo[@"CompanyId"];
    if ([storeId isEqualToString:GH_ID]) {
        _workTimeTextField.enabled = NO;
    }
    [self creatToolBar];
}

- (void)creatToolBar {
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hidden)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace, doneButton, nil];
    [topView setItems:buttonsArray];
    [self.priceTextField setInputAccessoryView:topView];
}

- (void)hidden {
    if (_changePrice) {
         _changePrice(self.tag);
    }
    [self.priceTextField resignFirstResponder];
}

- (IBAction)delClick:(id)sender {
    if (_delContent) {
        _delContent(self);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _priceTextField) {
        if (_changePrice) {
            _changePrice(self.tag);
        }
    }else {
        if (_changeWorkTime) {
            _changeWorkTime(self.tag);
        }
    }
}

@end
