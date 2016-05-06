//
//  CarCheckTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CarCheckTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) void (^editBegin)(NSInteger);
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *validTextField;
@property (nonatomic, assign) BOOL jzBol;
@property (nonatomic, assign) BOOL tmBol;
@property (weak, nonatomic) IBOutlet UIButton *jzBtn;
@property (weak, nonatomic) IBOutlet UIButton *tmBtn;
@property (nonatomic, retain) NSMutableArray *addArray;


- (void)initData:(NSMutableArray *)array;
- (void)checkValue;
@end
