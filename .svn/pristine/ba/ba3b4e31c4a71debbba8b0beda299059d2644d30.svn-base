//
//  WorkerCell.m
//  Repair
//
//  Created by Kassol on 15/9/14.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "WorkerCell.h"
#import "RepairOrderInfo.h"

@implementation WorkerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _workTimeTextField) {
        [[RepairOrderInfo sharedRepairOrderInfo] changeWorkTime:_workTimeTextField.text withCarID:_carID withProjectIndex:_section-2 withIndex:_workTimeTextField.tag-1];
    } else {
        NSLog(@"%ld",_section);
        [[RepairOrderInfo sharedRepairOrderInfo] changeMoney:_moneyTextField.text withCarID:_carID withProjectIndex:_section-2 withIndex:_moneyTextField.tag-1];
    }
}

@end
