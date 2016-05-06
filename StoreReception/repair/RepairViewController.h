//
//  RepairViewController.h
//  Repair
//
//  Created by Kassol on 15/9/8.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface RepairViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString *conId;
@property (strong, nonatomic) HomeViewController *sender;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, copy) NSString *isChecked;
@end
