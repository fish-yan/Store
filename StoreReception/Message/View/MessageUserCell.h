//
//  MessageUserCell.h
//  testMessage
//
//  Created by 薛焱 on 16/4/25.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UIImageView *servicerImage;
@property (weak, nonatomic) IBOutlet UILabel *servicerLab;
@end
