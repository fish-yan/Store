//
//  ConstructionViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/12/4.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConstructionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSString *conId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) void (^refreshData)(void);

@end
