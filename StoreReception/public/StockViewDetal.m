//
//  StockViewDetal.m
//  StoreReception
//
//  Created by cjm-ios on 15/8/7.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "StockViewDetal.h"

@implementation StockViewDetal

- (void)awakeFromNib {
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (IBAction)commitClick:(id)sender {
    _commitClick();
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _storeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@            %@",_storeArray[indexPath.row][@"StoreName"],_storeArray[indexPath.row][@"StoreNum"]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = UIColorFromRGB(0x626262);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}


@end
