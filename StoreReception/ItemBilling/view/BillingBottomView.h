//
//  BillingBottomView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/10.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillingBottomView : UIView

@property (weak, nonatomic) IBOutlet UILabel *numL;
@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (copy, nonatomic) void (^addClick)(void);
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end
