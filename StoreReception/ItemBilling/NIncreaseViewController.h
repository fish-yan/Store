//
//  NIncreaseViewController.h
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface NIncreaseViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, retain) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIToolbar * accessoryView;
@property (nonatomic, strong) NSDictionary *DataDict;
@property (nonatomic ,strong) NSArray *serArray;
@property (nonatomic, assign) BOOL isFromCarCheck;

@end
