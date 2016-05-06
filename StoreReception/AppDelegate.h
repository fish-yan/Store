//
//  AppDelegate.h
//  StoreReception
//
//  Created by cjm-ios on 15/5/19.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedBlueToothManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CBCentralManager* blueToothManager;


@end

