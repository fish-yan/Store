//
//  AddWorkerViewController.m
//  Repair
//
//  Created by Kassol on 15/9/7.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "AddWorkerViewController.h"
#import "AddWorkerCell.h"
#import "MJRefresh.h"
#import "HttpClient.h"
#import "LoginInfo.h"
#import "CarInfoViewController.h"
#import "RepairOrderInfo.h"
#import "JDStatusBarNotification.h"
#import "MBProgressHUD.h"
#import "Utils.h"

@interface AddWorkerViewController (){
    NSDictionary *userInfo;
    NSString *userId;
    NSString *token;
    NSString *storeId;
    NSInteger row;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *workerArray;

@end

@implementation AddWorkerViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_workerStatus == nil) {
        _workerStatus = [NSMutableArray array];
    }
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    userId = [userInfo objectForKey:@"UserId"];
    token = [userInfo objectForKey:@"Token"];
    storeId = [userInfo objectForKey:@"StoreId"];
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
    [userToken setObject:userId forKey:@"UserId"];
    [userToken setObject:token forKey:@"Token"];
    [option setObject:storeId forKey:@"StoreId"];
    [option setObject:userToken forKey:@"UserToken"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpClient sharedHttpClient] getWorkerList:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            _workerArray = [[(NSDictionary *)responseObject objectForKey:@"Result"] mutableCopy];
            [_collectionView reloadData];
        } else {
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backButtonDidTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)finishButtonDidTouch:(id)sender {
    if (_sender.tag == 100) {
        for (int i = 0; i <= _sectionCount; i++) {
            [self addWorkers:i];
        }
    }else{
        [self addWorkers:_sender.tag];
    }
    
    [_sourceViewController refreshView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addWorkers:(NSInteger)tag{
    _workTime = [[_serviceArray[tag] objectForKey:@"workTime"] floatValue];
    _workTimePrice = [[_serviceArray[tag] objectForKey:@"TotalPay"] floatValue];
    NSMutableArray *workers = [NSMutableArray array];
    NSInteger selectedCount = [_workerStatus count];
    for (NSInteger i = 0; i < [_workerArray count]; ++i) {
        NSMutableDictionary *worker = [_workerArray[i] mutableCopy];
        if ([_workerStatus containsObject:[worker objectForKey:@"FID"]]) {
            [worker setObject:[NSString stringWithFormat:@"%.2f", _workTimePrice/selectedCount] forKey:@"Price"];
            [worker setObject:[NSString stringWithFormat:@"%.2f", _workTime/selectedCount] forKey:@"WorkTime"];
            [workers addObject:worker];
        }
    }
    [[RepairOrderInfo sharedRepairOrderInfo] addWorkers:workers inCarID:_carID withIndex:tag];
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AddWorkerCell *cell = (AddWorkerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_workerStatus containsObject:[_workerArray[indexPath.row] objectForKey:@"FID"]]) {
        [_workerStatus removeObject:[_workerArray[indexPath.row] objectForKey:@"FID"]];
        [cell.selectedView setHidden:YES];
    } else {
        [_workerStatus addObject:[_workerArray[indexPath.row] objectForKey:@"FID"]];
        [cell.selectedView setHidden:NO];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize frame = collectionView.frame.size;
    CGFloat width = (frame.width-2)/3;
    CGFloat height = width *4/3;
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDataSouce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_workerArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddWorkerCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"AddWorkerCell" forIndexPath:indexPath];
    cell.workerLabel.text = [_workerArray[indexPath.row] objectForKey:@"Name"];
    if (indexPath.row % 12 == 0) {
        row = 1;
    }else {
        row++;
    }
    NSLog(@"aaa:%ld--%ld",row,indexPath.row);
    cell.personImgView.image = [UIImage imageNamed:@"avarter"];
    if ([_workerStatus containsObject:[_workerArray[indexPath.row] objectForKey:@"FID"]]) {
        [cell.selectedView setHidden:NO];
    } else {
        [cell.selectedView setHidden:YES];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [_workerArray count];
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//    
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

#pragma mark - UITableViewDataSource

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    AddWorkerCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"AddWorkerCell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddWorkerCell"];
//    }
//    cell.workerLabel.text = [_workerArray[indexPath.row] objectForKey:@"Name"];
//    cell.selectButton.tag = indexPath.row;
//    if ([[_workerStatus objectForKey:[_workerArray[indexPath.row] objectForKey:@"FID"]]  isEqualToString: @"1"]) {
//        [cell.selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
//    } else {
//        [_workerStatus setObject:@"0" forKey:[_workerArray[cell.selectButton.tag] objectForKey:@"FID"]];
//        [cell.selectButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
//    }
//    return cell;
//}

@end
