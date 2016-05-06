//
//  SearchPickUpTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchPickUpTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *carNumL;
@property (weak, nonatomic) IBOutlet UILabel *orderStateL;
@property (weak, nonatomic) IBOutlet UILabel *userNameL;
@property (weak, nonatomic) IBOutlet UILabel *serviceL;
@property (weak, nonatomic) IBOutlet UILabel *orderIdL;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeL;
@end
