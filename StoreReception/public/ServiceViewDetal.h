//
//  ServiceViewDetal.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/2.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceViewDetal : UIView

@property (copy, nonatomic) void(^commitClick)(void);
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *codeL;
@property (weak, nonatomic) IBOutlet UILabel *sgNumL;
@property (weak, nonatomic) IBOutlet UILabel *descL;
@property (weak, nonatomic) IBOutlet UILabel *gsL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;

@end
