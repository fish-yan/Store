//
//  UICityPicker.m
//  DDMates
//
//  Created by cjm-ios on 15/5/28.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "TSLocateView.h"

#define kDuration 0.3

@interface TSLocateView () {
    NSArray *array;
    NSArray *subArray;
}

@end

@implementation TSLocateView

@synthesize titleLabel;
@synthesize locatePicker;

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"TSLocateView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.titleLabel.text = title;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
    }
    return self;
}

- (void)initData:(id)data {
    _pdata = data;
    if ([_pdata isKindOfClass:[NSArray class]]) {
        array = _pdata;
    }else {
        array = ((NSDictionary *)_pdata).allKeys;
        NSString *key = array[0];
        subArray = [_pdata objectForKey:key];
    }
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([_pdata isKindOfClass:[NSArray class]]) {
        return 1;
    }else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return array.count;
    }else {
        return subArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return array[row];
    }else {
        return subArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([_pdata isKindOfClass:[NSArray class]]) {
        if (_passValue) {
            _passValue(row);
        }
    }else {
        if (component == 0) {
            _curRow = row;
            _subCurRow = 0;
            NSString *key = array[row];
            subArray = [_pdata objectForKey:key];
            //选择指定的item
            [pickerView selectRow:0 inComponent:1 animated:YES];
            //刷新指定列中的行
            [pickerView reloadComponent:1];
            
        }else {
            _subCurRow = row;
        }
        if (_passAllValue) {
            _passAllValue(_curRow,_subCurRow);
        }
    }
    
}




@end
