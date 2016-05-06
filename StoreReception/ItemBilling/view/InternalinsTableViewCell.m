//
//  InternalinsTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "InternalinsTableViewCell.h"

@interface InternalinsTableViewCell () {
    NSArray *initArray;
}

@end

@implementation InternalinsTableViewCell 

- (void)awakeFromNib {
    initArray = [[NSArray alloc] initWithObjects:_ybBtn,_lbBtn,_xhBtn,_ypBtn,_zxBtn,_ssBtn,_ktBtn, nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ybClick:(id)sender {
    _ybBol = !_ybBol;
    if (_ybBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)lbClick:(id)sender {
    _lbBol = !_lbBol;
    if (_lbBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)xhClick:(id)sender {
    _xhBol = !_xhBol;
    if (_xhBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)ypClick:(id)sender {
    _ypBol = !_ypBol;
    if (_ypBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)zxClick:(id)sender {
    _zxBol = !_zxBol;
    if (_zxBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)ssClick:(id)sender {
    _ssBol = !_ssBol;
    if (_ssBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)ktClick:(id)sender {
    _ktBol = !_ktBol;
    if (_ktBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (void)setBtnSelectedBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    [_addArray addObject:btn];
}

- (void)setBtnNormalBg:(UIButton *)btn {
    [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    [_addArray removeObject:btn];
}

- (void)initData:(NSMutableArray *)array {
    _addArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++) {
        UIView *view = array[i];
        NSInteger aTag = view.tag;
        for (int j = 0; j < initArray.count; j++) {
            UIView *aView = initArray[j];
            NSInteger iTag = aView.tag;
            if (aTag == iTag) {
                UIButton *btn = (UIButton *)aView;
                [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
                [_addArray addObject:btn];
                break;
            }
        }
        
        
    }
}

@end
