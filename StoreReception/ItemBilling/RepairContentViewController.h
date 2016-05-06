//
//  RepairContentViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KNSemiModalViewController/UIViewController+KNSemiModal.h>
#import "TPKeyboardAvoidingTableView.h"

@interface RepairContentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, copy) void (^passContent)(NSArray *);
@property (nonatomic, retain) NSMutableArray *addArray;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIToolbar * accessoryView;

@end
