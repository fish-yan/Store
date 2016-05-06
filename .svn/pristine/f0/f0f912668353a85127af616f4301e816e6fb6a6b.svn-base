//
//  CardView.h
//  StoreReception
//
//  Created by cjm-ios on 15/10/27.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (retain, nonatomic) NSArray *result;
@property (copy, nonatomic) void(^commitClick)(void);
@property (copy, nonatomic) void(^cancelClick)(void);
@property (retain, nonatomic) void(^selectedClick)(NSDictionary *);

- (void)refreshData:(NSArray *)array;
@end
