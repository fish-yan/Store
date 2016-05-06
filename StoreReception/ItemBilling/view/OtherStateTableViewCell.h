//
//  OtherStateTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherStateTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) BOOL stBol;
@property (nonatomic, assign) BOOL hsBol;
@property (nonatomic, assign) BOOL axBol;
@property (nonatomic, assign) BOOL pzBol;
@property (nonatomic, assign) BOOL xfBol;

@property (nonatomic, assign) BOOL jjBol;
@property (nonatomic, assign) BOOL zBol;
@property (nonatomic, assign) BOOL hzBol;

@property (nonatomic, assign) BOOL bzBol;
@property (nonatomic, assign) BOOL zzBol;

@property (weak, nonatomic) IBOutlet UIButton *jjBtn;
@property (weak, nonatomic) IBOutlet UIButton *zBtn;
@property (weak, nonatomic) IBOutlet UIButton *hzBtn;
@property (weak, nonatomic) IBOutlet UIButton *styBtn;
@property (weak, nonatomic) IBOutlet UIButton *hsBtn;
@property (weak, nonatomic) IBOutlet UIButton *axBtn;
@property (weak, nonatomic) IBOutlet UIButton *pzBtn;

@property (weak, nonatomic) IBOutlet UIButton *bzBtn;
@property (weak, nonatomic) IBOutlet UIButton *zzBtn;

@property (nonatomic, retain) NSMutableArray *selectedArray;

@property (weak, nonatomic) IBOutlet UITextField *byTextField;
@property (weak, nonatomic) IBOutlet UITextField *gjTextField;
@property (weak, nonatomic) IBOutlet UITextField *cdTextField;
@property (weak, nonatomic) IBOutlet UITextField *dyqTextField;
@property (weak, nonatomic) IBOutlet UITextField *dhkTextField;
@property (weak, nonatomic) IBOutlet UITextField *jhTextField;
@property (weak, nonatomic) IBOutlet UITextField *qjdTextField;
@property (nonatomic, retain) NSMutableArray *addArray;

@property (copy, nonatomic) void (^setOffset)(int);
@property (copy, nonatomic) void (^backOffset)(void);

- (void)initData:(NSMutableArray *)array;
- (void)checkValue;
@end
