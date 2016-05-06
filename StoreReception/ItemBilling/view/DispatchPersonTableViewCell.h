//
//  DispatchPersonTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DispatchPersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *personL;
@property (weak, nonatomic) IBOutlet UIButton *clickBtn;
@property (assign, nonatomic) BOOL bol;
@property (copy, nonatomic) void (^passPerson)(BOOL);
@end
