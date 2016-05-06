//
//  InputMsgTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/8/11.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputMsgTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (copy, nonatomic) void (^noticeEdit)(void);
@property (copy, nonatomic) void (^noticeText)(void);
@property (weak, nonatomic) IBOutlet UIImageView *lineV;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *markL;
@property (weak, nonatomic) IBOutlet UITextField *selectedTextField;

- (void)setDelegagte;
@end
