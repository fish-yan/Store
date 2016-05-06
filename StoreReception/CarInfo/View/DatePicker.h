//
//  DatePicker.h
//  CarInfo
//
//  Created by 薛焱 on 16/4/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePicker : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePic;

@end
