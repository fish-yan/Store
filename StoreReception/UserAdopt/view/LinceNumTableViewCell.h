//
//  LinceNumTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/11/9.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinceNumTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *stTextField;
@property (weak, nonatomic) IBOutlet UITextField *subStTextField;
@property (copy, nonatomic) void (^noticeText)(void);
@property (copy, nonatomic) void (^noticeEdit)(void);
@end
