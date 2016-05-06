//
//  ServiceTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FROMSEVICE @"fromService"
#define FROMWASH @"fromWash"

@interface ServiceTableViewCell : UITableViewCell

@property (copy, nonatomic) void (^addService)(NSInteger);
@property (weak, nonatomic) IBOutlet UILabel *serviceNameL;
@property (weak, nonatomic) IBOutlet UILabel *serviceCodeL;
@property (weak, nonatomic) IBOutlet UILabel *serviceGsL;
@property (weak, nonatomic) IBOutlet UILabel *servicePriceL;
@property (weak, nonatomic) IBOutlet UILabel *addNumL;
@property (retain, nonatomic) NSString *typeFrom;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@end
