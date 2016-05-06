//
//  CarCollectionViewCell.m
//  Repair
//
//  Created by Kassol on 15/11/16.
//  Copyright © 2015年 CJM. All rights reserved.
//

#import "CarCollectionViewCell.h"
#import "Utils.h"

@interface CarCollectionViewCell ()
@property (strong, nonatomic) UIView *content;
@property (strong, nonatomic) CAShapeLayer *backlayer;
@end

@implementation CarCollectionViewCell

- (void)drawRect:(CGRect)rect {
    
    if (_content != nil) {
        [_content removeFromSuperview];
    }
    _content = [[UIView alloc] initWithFrame:_outView.bounds];
    [_outView addSubview:_content];
    
    _backlayer = [CAShapeLayer layer];
    [_content.layer addSublayer:_backlayer];
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect viewRect = self.outView.frame;
    CGPoint center = CGPointMake(CGRectGetMidX(_outView.bounds),CGRectGetMidY(_outView.bounds));
    [path addArcWithCenter:center radius:viewRect.size.width/2 startAngle:-2*M_PI endAngle:2*M_PI clockwise:YES];
    circle.strokeColor = [UIColor colorWithRed:0.83 green:0.84 blue:0.84 alpha:1].CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.lineWidth = 1.0;
    circle.path = path.CGPath;
    [_backlayer addSublayer:circle];
    
    
    CAShapeLayer *outCircle = [CAShapeLayer layer];
    UIBezierPath *outPath = [UIBezierPath bezierPath];
    
    CGFloat endAngle = 0;
//    if ([_status isEqualToString:QUALITYCHECK]) {
//        endAngle = 0;
//    } else if ([_status isEqualToString:WAITING]) {
//        endAngle = M_PI/2;
//    } else if ([_status isEqualToString:WORKING] || [_status isEqualToString:MYWORKING]) {
//        endAngle = M_PI;
//    } else {
//        endAngle = 3*M_PI/2;
//    }
    endAngle = -M_PI/2 + 2*M_PI*_percent;
    [outPath addArcWithCenter:center radius:viewRect.size.width/2 startAngle:-M_PI/2 endAngle:endAngle clockwise:YES];
    outCircle.strokeColor = [UIColor colorWithRed:0.13 green:0.59 blue:0.96 alpha:1].CGColor;
    outCircle.fillColor = [UIColor clearColor].CGColor;
    outCircle.lineWidth = 1.0;
    outCircle.path = outPath.CGPath;
    [_backlayer addSublayer:outCircle];
}

@end
