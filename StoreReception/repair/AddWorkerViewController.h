//
//  AddWorkerViewController.h
//  Repair
//
//  Created by Kassol on 15/9/7.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarInfoViewController.h"

@interface AddWorkerViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>
@property (weak, nonatomic) UIButton *sender;
@property (weak, nonatomic) NSString *carID;
@property (strong, nonatomic) NSMutableArray *workerStatus;
@property (strong, nonatomic) NSArray *serviceArray;
@property (weak, nonatomic) CarInfoViewController *sourceViewController;
@property (assign, nonatomic) float workTime;
@property (assign, nonatomic) float workTimePrice;
@property (nonatomic, assign) NSInteger sectionCount;
@end
