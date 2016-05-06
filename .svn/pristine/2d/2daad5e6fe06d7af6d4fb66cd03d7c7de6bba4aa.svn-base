//
//  UserView.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/9.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *licenNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *telPersonTextField;
@property (weak, nonatomic) IBOutlet UITextField *telNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *frameNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *roadHaulTextField;
@property (weak, nonatomic) IBOutlet UITextField *stTextField;
@property (copy, nonatomic) void (^editLicen)(void);
@property (weak, nonatomic) IBOutlet UITextField *validDate;
@property (nonatomic, copy) void (^editBegin)(void);
@property (nonatomic, copy) void (^endBegin)(void);
@property (nonatomic, copy) void (^passValue)(NSDictionary *);
@property (nonatomic, retain) NSDictionary *info;
@property (weak, nonatomic) IBOutlet UIView *linceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *frameNumL;
@property (weak, nonatomic) IBOutlet UILabel *roadHaulL;
@property (weak, nonatomic) IBOutlet UILabel *outTimeL;

- (void)repairInfobyCarNum;
- (void)getCarInfo:(NSString *)linceStr;
- (void)reset;

@end
