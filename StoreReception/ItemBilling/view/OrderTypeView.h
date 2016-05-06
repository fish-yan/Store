//
//  OrderTypeView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/23.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTypeView : UIView
@property (assign, nonatomic) BOOL serviceBol;
@property (assign, nonatomic) BOOL repairBol;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *repairBtn;

@end
