//
//  ItemListViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#define NORMAL_FROMPAGE @"NORMAL_FROMPAGE"
#define PICKUP_FROMPAGE @"PICKUP_FROMPAGE"

@interface ItemListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableDictionary *itemDict;
@property (copy, nonatomic) void (^passItemDict)(NSMutableDictionary *);
@property (retain, nonatomic) UITableView *typeTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *maskTableView;
@property (retain, nonatomic) NSArray *addArray;
@property (weak, nonatomic) IBOutlet UIView *typeBtn;
@property (retain, nonatomic) NSString *fromPage;

@end
