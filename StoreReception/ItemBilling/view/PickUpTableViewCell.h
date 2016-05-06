//
//  PickUpTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickUpTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *linceNumL;
@property (weak, nonatomic) IBOutlet UILabel *timeL;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (copy, nonatomic) void(^commitClick)(void);
@property (copy, nonatomic) void(^editClick)(void);
@end
