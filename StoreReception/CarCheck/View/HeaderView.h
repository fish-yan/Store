//
//  HeaderView.h
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/21.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *scoresLab;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@end
