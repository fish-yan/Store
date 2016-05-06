//
//  ServicesViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/30.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *addServiceArray;
@property (copy, nonatomic) void (^passServiceArray)(NSMutableArray *);
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (retain, nonatomic) NSArray *addArray;
@property (retain, nonatomic) UITableView *typeTableView;
@property (weak, nonatomic) IBOutlet UIView *maskTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end
