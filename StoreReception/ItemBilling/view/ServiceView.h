//
//  ServiceView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/10.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentV;
@property (copy, nonatomic) void (^addService)(void);

@end
