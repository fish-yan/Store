//
//  WashListViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WashListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>

@property (nonatomic, copy) void (^passService)(NSDictionary *);
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSDictionary *washInfo;

@end
