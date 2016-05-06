//
//  CarCheckAllTableViewCell.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "CarCheckAllTableViewCell.h"

@interface CarCheckAllTableViewCell () {
    NSArray *initArray;
}

@end

@implementation CarCheckAllTableViewCell

- (void)awakeFromNib {
    initArray = [[NSArray alloc] initWithObjects:_fdjBtn,_qqBtn,_qscBtn,_hqBtn,_hscBtn,_scBtn,_pqBtn,_ryBtn, nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)fdjClick:(id)sender {
    _fdjBol = !_fdjBol;
    if (_fdjBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)qqClick:(id)sender {
    _qqBol = !_qqBol;
    if (_qqBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)qscClick:(id)sender {
    _qscBol = !_qscBol;
    if (_qscBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)hqClick:(id)sender {
    _hqBol = !_hqBol;
    if (_hqBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)hscClick:(id)sender {
    _hscBol = !_hscBol;
    if (_hscBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)scClick:(id)sender {
    _scBol = !_scBol;
    if (_scBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)pqClick:(id)sender {
    _pqBol = !_pqBol;
    if (_pqBol) {
        [self setBtnSelectedBg:sender];
    }else {
        [self setBtnNormalBg:sender];
    }
}

- (IBAction)ryCLick:(id)sender {
    _ryBol = !_ryBol;
    if (_ryBol) {
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
