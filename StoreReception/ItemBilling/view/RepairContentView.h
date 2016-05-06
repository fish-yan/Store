//
//  RepairContentView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/23.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairContentView : UIView

@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (copy, nonatomic) void (^delContent)(UIView *);
@property (weak, nonatomic) IBOutlet UIView *bottomLineV;

@end
