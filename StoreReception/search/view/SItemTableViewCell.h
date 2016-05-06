//
//  SItemTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *kctL;
@property (weak, nonatomic) IBOutlet UILabel *itemNameL;
@property (weak, nonatomic) IBOutlet UILabel *itemGgL;
@property (weak, nonatomic) IBOutlet UILabel *itemCodeL;
@property (weak, nonatomic) IBOutlet UILabel *numTL;
@property (weak, nonatomic) IBOutlet UILabel *numL;
@property (weak, nonatomic) IBOutlet UILabel *unitTL;
@property (weak, nonatomic) IBOutlet UILabel *unitL;
@property (weak, nonatomic) IBOutlet UILabel *acountL;
@property (weak, nonatomic) IBOutlet UIButton *kcBtn;
@property (weak, nonatomic) IBOutlet UIButton *lsBtn;
@property (weak, nonatomic) IBOutlet UILabel *itemPpL;
@property (copy, nonatomic) void (^moreKc)(NSInteger);
@property (nonatomic, copy) void (^searchHistoryPrice)(NSInteger);

@end
