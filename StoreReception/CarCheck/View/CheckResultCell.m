//
//  CheckResultCell.m
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/2.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CheckResultCell.h"

@interface CheckResultCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIImageView *image5;
@property (weak, nonatomic) IBOutlet UIImageView *image6;
@end

@implementation CheckResultCell

- (void)awakeFromNib {
    
    
    
}

- (void)setBadCount:(NSInteger)badCount{
    self.image1.image = nil;
    self.image2.image = nil;
    self.image3.image = nil;
    self.image4.image = nil;
    self.image5.image = nil;
    self.image6.image = nil;
    if (badCount >= 1) {
        self.image1.image = [UIImage imageNamed:@"bad"];
    }
    if (badCount >= 2) {
        self.image2.image = [UIImage imageNamed:@"bad"];
    }
    if (badCount >= 3) {
        self.image3.image = [UIImage imageNamed:@"bad"];
    }
    if (badCount >= 4) {
        self.image4.image = [UIImage imageNamed:@"bad"];
    }
    if (badCount >= 5) {
        self.image5.image = [UIImage imageNamed:@"bad"];
    }
    if (badCount >= 6) {
        self.image6.image = [UIImage imageNamed:@"bad"];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
