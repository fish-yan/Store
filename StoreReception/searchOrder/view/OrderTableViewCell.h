//
//  OrderTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/2.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderType;//订单类型
@property (weak, nonatomic) IBOutlet UILabel *ifCompleteL;//是否结算
@property (weak, nonatomic) IBOutlet UILabel *cpnL;//车牌号
@property (weak, nonatomic) IBOutlet UILabel *ordernL;//订单号
@property (weak, nonatomic) IBOutlet UILabel *priceL;//订单价格
@property (weak, nonatomic) IBOutlet UILabel *ordertL;//订单创建时间

@end
