//
//  CarWashBillingViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface CarWashBillingViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) NSDictionary *carInfo;


@end
