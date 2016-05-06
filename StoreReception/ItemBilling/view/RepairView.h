//
//  RepairView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/10.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (nonatomic, copy) void (^photoClick)(void);
@property (nonatomic, copy) void (^addRepair)(void);
@property (weak, nonatomic) IBOutlet UIView *lineV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineVConstraint;

@end
