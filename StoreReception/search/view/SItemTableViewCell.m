//
//  SItemTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SItemTableViewCell.h"

@implementation SItemTableViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)moreKcClick:(id)sender {
    _moreKc(self.tag);
}

- (IBAction)searchHistoryPrice:(id)sender {
    if (_searchHistoryPrice) {
        _searchHistoryPrice(self.tag);
    }
}

@end
