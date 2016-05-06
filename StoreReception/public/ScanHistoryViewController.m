//
//  ScanHistoryViewController.m
//  StoreReception
//
//  Created by cjm-ios on 16/2/24.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "ScanHistoryViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+empty.h"
#import "ScanTableViewCell.h"
static NSString *scanCell = @"scanCell";

@interface ScanHistoryViewController () {
    NSArray *resultArray;
}

@end

@implementation ScanHistoryViewController

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"扫描清单";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    [self request];
    UINib *nib = [UINib nibWithNibName:@"ScanTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:scanCell];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:scanCell];
    NSDictionary *dict = resultArray[indexPath.row];
    cell.userNameL.text = dict[@"CarNum"];
    cell.linceNumL.text = dict[@"StoreName"];
    cell.timeL.text = dict[@"GreatDate"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}

#pragma mark - request
- (void)request {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"UserId":userId,@"StoreId":storeId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetCarNum];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            resultArray = [[NSArray alloc] initWithArray:responseObject[@"Result"][@"CarNums"]];
            if (resultArray.count == 0) {
                [_tableView showEmpty];
                [ZAActivityBar showErrorWithStatus:@"查无数据"];
            }else {
                [_tableView reloadData];
                [_tableView hiddenEmpty];
                [ZAActivityBar dismiss];
            }
        }else {
            NSLog(@"msg:  %@",responseObject[@"Message"]);
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
