//
//  PrinterViewController.m
//  Print
//
//  Created by 张旭 on 1/27/16.
//  Copyright © 2016 Cjm. All rights reserved.
//

#import "PrinterSettingTableViewCell.h"
#import "PrinterSettingViewController.h"
#import "SharedBlueToothManager.h"
#import "ZAActivityBar.h"

@interface PrinterSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation PrinterSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refreshButtonDidTouch:(id)sender {
    [self.tableView reloadData];
}

- (IBAction)backButtonDidTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[SharedBlueToothManager sharedBlueToothManager] foundPeripherals].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PrinterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrinterTableViewCell"];
    cell.titleLabel.text = ((CBPeripheral *)[[[SharedBlueToothManager sharedBlueToothManager] foundPeripherals] objectAtIndex:indexPath.row]).identifier.UUIDString;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[SharedBlueToothManager sharedBlueToothManager] setActivePeripherals:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
