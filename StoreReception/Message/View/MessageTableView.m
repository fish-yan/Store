
//
//  MessageTableView.m
//  testMessage
//
//  Created by 薛焱 on 16/4/28.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "MessageTableView.h"

@implementation MessageTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setContentSize:(CGSize)contentSize {
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        if (contentSize.height > self.contentSize.height) {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = CGPointMake(offset.x, offset.y);
        }
    }
    [super setContentSize:contentSize];
}

@end
