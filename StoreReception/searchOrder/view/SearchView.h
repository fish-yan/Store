//
//  SearchView.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/14.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *begainTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTextField;

@property (nonatomic, assign) BOOL washBol;
@property (nonatomic, assign) BOOL serviceBol;
@property (nonatomic, assign) BOOL itemBol;
@property (nonatomic, assign) BOOL pickBol;
@property (nonatomic, assign) BOOL increaseBol;
@property (weak, nonatomic) IBOutlet UIButton *washBtn;
@property (weak, nonatomic) IBOutlet UIButton *itemBtn;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *pickBtn;
@property (weak, nonatomic) IBOutlet UIButton *increaseBtn;

@property (copy, nonatomic) void (^getCurrentTextField)(UITextField *);
@property (copy, nonatomic) void (^searchClick)(NSMutableDictionary *);
@end
