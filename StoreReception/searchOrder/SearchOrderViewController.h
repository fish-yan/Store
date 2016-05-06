//
//  SearchOrderViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchOrderViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *orderTable;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIToolbar * accessoryView;
@property (weak, nonatomic) IBOutlet UIButton *myOrderBtn;
@property (weak, nonatomic) IBOutlet UIView *lineV;
@property (weak, nonatomic) IBOutlet UIButton *otherOrderBtn;

@end
