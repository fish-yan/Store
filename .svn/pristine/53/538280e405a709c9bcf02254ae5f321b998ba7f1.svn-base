//
//  LinceNumTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/11/9.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "LinceNumTableViewCell.h"
#import "TSLocateView.h"

@interface LinceNumTableViewCell () {
    NSDictionary *licensePlateDict;
    TSLocateView *linceView;
    NSInteger linceRow;
    NSInteger subLinceRow;
}

@end

@implementation LinceNumTableViewCell

- (void)awakeFromNib {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"LicensePlate" ofType:@"plist"];
    licensePlateDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    linceView = [[TSLocateView alloc] initWithTitle:@"选择车牌" delegate:self];
    linceView.passAllValue = ^(NSInteger row,NSInteger subRow) {
        linceRow = row;
        subLinceRow = subRow;
    };
    [linceView initData:licensePlateDict];
    _stTextField.inputView = linceView;
    _subStTextField.delegate = self;
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *storeConfig = userInfo[@"StoreConfig"];
    NSString *carProvince = storeConfig[@"CarProvince"];
    NSString *carRegion = storeConfig[@"CarRegion"];
    if (storeConfig) {
        if (![storeConfig isKindOfClass:[NSNull class]]) {
            _stTextField.text = [NSString stringWithFormat:@"%@%@",carProvince,carRegion];
        }
    }
    [self creatToolBar];
}

- (void)creatToolBar {
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    UIButton* cancelDone = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelDone.frame = CGRectMake(10, 5, 60, 20);
    [cancelDone setBackgroundColor:[UIColor clearColor]];
    [cancelDone setTitle:@"取消" forState:UIControlStateNormal];
    cancelDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:cancelDone];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(topView.frame.size.width-70, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"确定" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelDone addTarget:self action:@selector(OnTapCancel:) forControlEvents:UIControlEventTouchUpInside];
    _stTextField.inputAccessoryView = topView;
}

- (void)OnTapCancel:(id) sender{
    [_stTextField resignFirstResponder];
}

-(void)OnTapDone:(id) sender{
    if ([_stTextField isFirstResponder]) {
        NSArray *array = licensePlateDict.allKeys;
        NSString *key = array[linceRow];
        NSArray *subArray = licensePlateDict[key];
        NSString *subValue = @"";
        if (subArray.count > 0) {
            subValue = subArray[subLinceRow];
        }
        _stTextField.text = [NSString stringWithFormat:@"%@%@",key,subValue];
    }
    [_stTextField resignFirstResponder];
    if (_noticeText) {
        _noticeText();
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_noticeEdit) {
        _noticeEdit();
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_noticeText) {
        _noticeText();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
