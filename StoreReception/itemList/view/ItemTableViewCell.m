//
//  ItemTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ItemTableViewCell.h"

@implementation ItemTableViewCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addClick:(id)sender {
    _addItem(self.tag);
}

- (IBAction)searchHistoryPrice:(id)sender {
    if (_searchHistoryPrice) {
        _searchHistoryPrice(self.tag);
    }
}

- (IBAction)moreClick:(id)sender {
    if (_moreClick) {
        _moreClick();
    }
}
@end
