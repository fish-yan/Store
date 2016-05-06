//
//  ItemViewDetal.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/2.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewDetal : UIView

@property (copy, nonatomic) void(^commitClick)(void);
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *codeL;
@property (weak, nonatomic) IBOutlet UILabel *ckL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet UILabel *ggL;
@property (weak, nonatomic) IBOutlet UILabel *kcNuml;
@property (weak, nonatomic) IBOutlet UILabel *gysL;

@end
