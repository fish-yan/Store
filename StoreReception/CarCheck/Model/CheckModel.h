//
//  CheckModel.h
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/2.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *problem;
@property (nonatomic, assign) NSInteger scores;
@property (nonatomic, assign) NSInteger badCount;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *allTitle;
@property (nonatomic, copy) NSString *KMTitle;
@property (nonatomic, copy) NSString *name;
@end
