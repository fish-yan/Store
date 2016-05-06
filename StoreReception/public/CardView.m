//
//  CardView.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/27.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "CardView.h"

@interface CardView () {
}

@end

@implementation CardView

- (void)awakeFromNib {
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (IBAction)commitClick:(id)sender {
    if (_commitClick) {
        _commitClick();
    }
}

- (IBAction)cancelClick:(id)sender {
    if (_cancelClick) {
        _cancelClick();
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *info = _result[indexPath.row];
    NSArray *projects = info[@"PackageCardProjects"];
    NSMutableString *mutstr = [[NSMutableString alloc] init];
    for (int i = 0; i < projects.count; i++) {
        NSDictionary *proInfo = projects[i];
        [mutstr appendFormat:@"%@(%@)",proInfo[@"ProjectName"],proInfo[@"ProjectNum"]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = UIColorFromRGB(0x626262);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = mutstr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _result[indexPath.row];
    if (_selectedClick) {
        _selectedClick(dict);
    }
}


@end
