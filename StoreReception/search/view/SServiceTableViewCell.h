//
//  SServiceTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/2.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SServiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *serviceNameL;
@property (weak, nonatomic) IBOutlet UILabel *serviceNL;
@property (weak, nonatomic) IBOutlet UILabel *serviceCountL;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;
@property (weak, nonatomic) IBOutlet UIView *lineV;


@end
