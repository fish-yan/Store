//
//  SearchUserViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/3.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSString *type;
@property (copy, nonatomic) void (^backLicen)(NSDictionary *);
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
- (void)getCarInfo;
@end
