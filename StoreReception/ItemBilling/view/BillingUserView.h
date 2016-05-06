//
//  BillingUserView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillingUserView : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *licenNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *telPersonTextField;
@property (weak, nonatomic) IBOutlet UITextField *telNumberTextField;
@property (copy, nonatomic) void (^editLicen)(void);
@property (nonatomic, copy) void (^editBegin)(void);
@property (nonatomic, copy) void (^endBegin)(void);
@property (nonatomic, copy) void (^passValue)(NSDictionary *);
@property (weak, nonatomic) IBOutlet UITextField *stTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *linceView;
@property (nonatomic, retain) NSDictionary *info;

- (void)getCarInfo:(NSString *)linceStr;
- (void)reset;
@end
