//
//  CCardViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/5.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *cardMsgView;
@property (weak, nonatomic) IBOutlet UITableView *cardMsgTableView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIButton *cardMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *cardRecordBtn;
@property (retain, nonatomic) NSDictionary *info;

@end
