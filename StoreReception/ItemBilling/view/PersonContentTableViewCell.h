//
//  PersonContentTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonContentTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UIView *lineV;
@property (copy, nonatomic) void (^passValue)(NSString *);
@property (copy, nonatomic) void (^passPrice)(NSString *);
@property (copy, nonatomic) void (^passCurrentCell)(PersonContentTableViewCell *);

@end
