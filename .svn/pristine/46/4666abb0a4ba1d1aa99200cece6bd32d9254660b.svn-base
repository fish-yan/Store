//
//  AddItemView.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/23.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "AddItemView.h"
#import "ToolKit.h"

@implementation AddItemView

- (void)awakeFromNib {
    _priceTextField.delegate = self;
    _numTextField.delegate = self;
    self.numTextField.keyboardType = UIKeyboardTypeDecimalPad;
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
    [self.numTextField setInputAccessoryView:topView];
}

- (void)hidden {
//    _changePrice(self.tag);
//    _changeNum(self.tag);
    _numL.text = self.numTextField.text;
    [self.priceTextField resignFirstResponder];
    [self.numTextField resignFirstResponder];
}

- (IBAction)delClick:(id)sender {
    _delContent(self);
}

- (IBAction)addNumClick:(id)sender {
    _addNum(self.tag);
}

- (IBAction)reduceNumClick:(id)sender {
    _redNum(self.tag);
}

- (void)setNum:(NSString *)num {
    _numL.text = num;
    _numTextField.text = num;
}

- (BOOL)checkNumText {
    if( ![ToolKit isPureInt:_priceTextField.text] || ![ToolKit isPureFloat:_priceTextField.text])
    {
        return NO;
    }else {
        return YES;
    }
}

- (IBAction)searchHistoryPrice:(id)sender {
    if (_searchHistoryPrice) {
        _searchHistoryPrice(self.tag);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self checkNumText]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _numTextField) {
        _changeNum(self.tag);
    }else {
        _changePrice(self.tag);
    }
}

@end
