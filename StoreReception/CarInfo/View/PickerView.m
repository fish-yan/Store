//
//  PickerView.m
//  CarInfo
//
//  Created by 薛焱 on 16/4/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "PickerView.h"

@interface PickerView()
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSArray *subArray;
@end

@implementation PickerView

- (void)awakeFromNib{
    _picker.delegate = self;
    _picker.dataSource = self;
}

- (void)setPickerData:(id)pickerData{
    _pickerData = pickerData;
    _row = 0;
    if ([_pickerData isKindOfClass:[NSArray class]]) {
        _array = _pickerData;
    }else{
        _array = ((NSDictionary *)_pickerData).allKeys;
        _subArray = [_pickerData objectForKey:_array[0]];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if ([_pickerData isKindOfClass:[NSArray class]]) {
        return 1;
    }else{
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return _array.count;
    }else{
        return _subArray.count;
    }
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return _array[row];
    }else {
        return _subArray[row];
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        _row = row;
        if ([_pickerData isKindOfClass:[NSDictionary class]]) {
            _subArray = [_pickerData objectForKey:_array[row]];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView reloadComponent:1];
        }
    }else{
        _subRow = row;
    }
    
}

@end
