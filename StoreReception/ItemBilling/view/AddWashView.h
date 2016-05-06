//
//  AddWashView.h
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWashView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameL;
@property (weak, nonatomic) IBOutlet UILabel *serviceCodeL;
@property (weak, nonatomic) IBOutlet UITextField *workTimeTextField;
@property (nonatomic, copy) void (^changePrice)(NSInteger);
@property (nonatomic, copy) void (^changeWorkTime)(NSInteger);
@property (weak, nonatomic) IBOutlet UIView *bottomLineV;
@property (copy, nonatomic) void (^delContent)(UIView *);

@end
