//
//  CarCheckAllTableViewCell.h
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarCheckAllTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL fdjBol;
@property (nonatomic, assign) BOOL qqBol;
@property (nonatomic, assign) BOOL qscBol;
@property (nonatomic, assign) BOOL hqBol;
@property (nonatomic, assign) BOOL hscBol;
@property (nonatomic, assign) BOOL scBol;
@property (nonatomic, assign) BOOL pqBol;
@property (nonatomic, assign) BOOL ryBol;
@property (weak, nonatomic) IBOutlet UIButton *fdjBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *qscBtn;
@property (weak, nonatomic) IBOutlet UIButton *hqBtn;
@property (weak, nonatomic) IBOutlet UIButton *hscBtn;
@property (weak, nonatomic) IBOutlet UIButton *scBtn;
@property (weak, nonatomic) IBOutlet UIButton *pqBtn;
@property (weak, nonatomic) IBOutlet UIButton *ryBtn;
@property (nonatomic, retain) NSMutableArray *addArray;

- (void)initData:(NSMutableArray *)array;
@end
