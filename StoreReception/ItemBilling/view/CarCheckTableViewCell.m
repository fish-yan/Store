//
//  CarCheckTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "CarCheckTableViewCell.h"

@interface CarCheckTableViewCell () {
    NSArray *initArray;
}

@end

@implementation CarCheckTableViewCell

- (void)awakeFromNib {
    // Initialization code
    initArray = [[NSArray alloc] initWithObjects:_yearTextField,_validTextField,_jzBtn,_tmBtn, nil];
    NSDate *curDate = [NSDate date];
    NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [pickerFormatter setDateFormat:@"yyyy年MM月dd日(EEEE)"];
    NSString *text = @"";
    if(!curDate) {
        text = @"No date selected";
    }else {
        text = [pickerFormatter stringFromDate:curDate];
    }
    _yearTextField.placeholder = text;
    _validTextField.placeholder = text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)tmClick:(id)sender {
    _tmBol = !_tmBol;
    if (_tmBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)jzClick:(id)sender {
    _jzBol = !_jzBol;
    if (_jzBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (void)setBtnSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    [_addArray addObject:btn];
}

- (void)setBtnNormalBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    [_addArray removeObject:btn];
}

- (void)initData:(NSMutableArray *)array {
    _addArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++) {
        UIView *view = array[i];
        NSInteger aTag = view.tag;
        for (int j = 0; j < initArray.count; j++) {
            UIView *aView = initArray[j];
            NSInteger iTag = aView.tag;
            if (aTag == iTag) {
                if ([aView isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)aView;
                    [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
                    [_addArray addObject:btn];
                }else {
                    UITextField *tf = (UITextField *)view;
                    if (tf.tag == 16) {
                        _yearTextField.text = tf.text;
                    }else {
                        _validTextField.text = tf.text;
                    }
                }
                break;
            }
        }
    }
}

- (void)checkValue {
    if (_yearTextField.text.length > 0) {
        [_addArray addObject:_yearTextField];
    }else {
        [_addArray removeObject:_yearTextField];
    }
    if (_validTextField.text.length > 0) {
        [_addArray addObject:_validTextField];
    }else {
        [_addArray removeObject:_validTextField];
    }
}

@end
