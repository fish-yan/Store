//
//  EngineCheckTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "EngineCheckTableViewCell.h"

@interface EngineCheckTableViewCell () {
     NSArray *initArray;
}

@end

@implementation EngineCheckTableViewCell

- (void)awakeFromNib {
    initArray = [[NSArray alloc] initWithObjects:_ysBtn,_fdBtn,_ghBtn,_lqBtn,_fdjBtn,_vxBtn,_kcjBtn,_dwBtn, nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ysClick:(id)sender {
    _ysBol = !_ysBol;
    if (_ysBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)fdClick:(id)sender {
    _fdBol = !_fdBol;
    if (_fdBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)ghClick:(id)sender {
    _ghBol = !_ghBol;
    if (_ghBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)lqClick:(id)sender {
    _lqBol = !_lqBol;
    if (_lqBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)fdjClick:(id)sender {
    _fdjBol = !_fdjBol;
    if (_fdjBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)vxClick:(id)sender {
    _vxBol = !_vxBol;
    if (_vxBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)kcjClick:(id)sender {
    _kcjBol = !_kcjBol;
    if (_kcjBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)dwClick:(id)sender {
    _dwBol = !_dwBol;
    if (_dwBol) {
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
