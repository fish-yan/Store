//
//  CarInfoCell.h
//  Repair
//
//  Created by Kassol on 15/9/7.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *carLabel;
@property (weak, nonatomic) IBOutlet UILabel *carCatalogLabel;
@property (weak, nonatomic) IBOutlet UILabel *carTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildFactoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *carType2Label;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *frontLabel;
@property (weak, nonatomic) IBOutlet UILabel *upTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *handoffTimeLabel;

@end
