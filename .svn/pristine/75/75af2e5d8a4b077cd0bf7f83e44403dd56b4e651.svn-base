//
//  AddServiceView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddServiceView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomLineV;
@property (copy, nonatomic) void (^delContent)(UIView *);
@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameL;
@property (weak, nonatomic) IBOutlet UILabel *serviceCodeL;
@property (nonatomic, copy) void (^changePrice)(NSInteger);
@property (nonatomic, copy) void (^changeWorkTime)(NSInteger);
@property (weak, nonatomic) IBOutlet UITextField *workTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;

@end
