//
//  ConstructionTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/12/4.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "ConstructionTableViewCell.h"

@interface ConstructionTableViewCell () {
    BOOL bol;
}

@end

@implementation ConstructionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)selecteClick:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    if (!bol) {
        [_selectedBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        if (_addInfo) {
            _addInfo();
        }
    }else {
        [_selectedBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
        if (_removeInfo) {
            _removeInfo();
        }
    }
    bol = !bol;
}
@end
