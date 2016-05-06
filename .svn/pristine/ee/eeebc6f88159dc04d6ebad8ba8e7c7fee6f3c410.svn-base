//
//  DispatchingViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DETAIL @"DETAIL"
#define REPAIRPERSON @"REPAIRPERSON"
#import "TPKeyboardAvoidingTableView.h"

@interface DispatchingViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView *tableView;
@property (retain, nonatomic) NSString *orderId;
@property (retain, nonatomic) NSString *type;
@property (copy,nonatomic) void (^repaireComplete)(void);
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end
