//
//  CommitViewController.h
//  StoreReception
//
//  Created by 薛焱 on 16/4/14.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface CommitViewController : UIViewController
@property (weak, nonatomic) NSString *status;
@property (weak, nonatomic) NSString *carID;
@property (weak, nonatomic) HomeViewController *sender;
@end
