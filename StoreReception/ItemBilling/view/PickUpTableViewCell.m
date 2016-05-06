//
//  PickUpTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "PickUpTableViewCell.h"

@implementation PickUpTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)commitClick:(id)sender {
    if (_commitClick) {
        _commitClick();
    }
}

- (IBAction)editClick:(id)sender {
    if (_editClick) {
        _editClick();
    }
}

@end
