//
//  DispatchPersonTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "DispatchPersonTableViewCell.h"

@implementation DispatchPersonTableViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)click:(id)sender {
    _bol = !_bol;
    if (_bol) {
        [_clickBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [_clickBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
    if (_passPerson) {
        _passPerson(_bol);
    }
}
@end
