//
//  UICityPicker.h
//  DDMates
//
//  Created by cjm-ios on 15/5/28.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "InputMsgTableViewCell.h"

@interface TSLocateView : UIActionSheet<UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (retain, nonatomic) id pdata;
@property (retain, nonatomic) InputMsgTableViewCell *cell;
@property (retain, nonatomic) UIToolbar *accessoryView;
@property (assign, nonatomic) NSInteger curRow;
@property (assign, nonatomic) NSInteger subCurRow;
@property (copy, nonatomic) void (^passValue)(NSInteger);
@property (copy, nonatomic) void (^passAllValue)(NSInteger,NSInteger);

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate;

- (void)showInView:(UIView *)view;
- (void)initData:(id)data;

@end
