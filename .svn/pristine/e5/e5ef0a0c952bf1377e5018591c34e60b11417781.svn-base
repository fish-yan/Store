//
//  ScanningView.h
//  StoreReception
//
//  Created by cjm-ios on 15/7/17.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScanningView : UIView {
    int num;
    BOOL upOrdown;
}

@property (retain, nonatomic)NSTimer * timer;
@property (copy, nonatomic) void (^cancelClick)(void);
@property (copy, nonatomic) void (^commitClick)(void);
@property (retain,nonatomic) NSString *funType;
@property (assign, nonatomic) float width;
@property (assign, nonatomic) float height;
@property (assign, nonatomic) float topHeight;
@property (assign, nonatomic) float leftWidth;

- (void)setBtnEnabled:(BOOL)enabled;

@end
