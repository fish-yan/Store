//
//  CarDetailViewController.h
//  CarInfo
//
//  Created by 薛焱 on 16/4/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarDetailViewController : UIViewController
@property (nonatomic, assign) BOOL isFromAddNewCarBtn;
@property (nonatomic, strong) NSMutableDictionary *carInfo;

@end
