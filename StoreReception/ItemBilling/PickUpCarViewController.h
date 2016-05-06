//
//  PickUpCarViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/9.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"

@interface PickUpCarViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIToolbar * accessoryView;

@end
