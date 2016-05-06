//
//  ConstructionViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/12/4.
//  Copyright © 2015年 cjm-ios. All rights reserved.＼
//  接单开单－维修
//

#import "ConstructionViewController.h"
#import "ConstructionTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "ZAActivityBar.h"
#import <MJRefresh/MJRefresh.h>
static NSString *constructionCell = @"constructionCell";

@interface ConstructionViewController () {
    NSMutableArray *resultArray;
    NSMutableArray *selectedArray;
    BOOL allBol;
}

@end

@implementation ConstructionViewController

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"添加接单技师";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)backAction {
    if (_refreshData) {
        _refreshData();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    self.title = @"施工";
    resultArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"ConstructionTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:constructionCell];
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [resultArray removeAllObjects];
        [self reapirServerItem];
    }];
    [self reapirServerItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)completeClick:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"项目完工"]) {
        [self finishRepair:btn];
    }else {
        [self finishRepairLast];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (resultArray.count == 0) {
        return 0;
    }else {
        return resultArray.count + 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < resultArray.count) {
        NSMutableDictionary *info = resultArray[indexPath.row];
        ConstructionTableViewCell *ctvc = [tableView dequeueReusableCellWithIdentifier:constructionCell];
        ctvc.infoArray = resultArray;
        ctvc.projectNameL.text = info[@"ProjectName"];
        ctvc.personNameL.text = info[@"RepairPersons"];
        int status = [info[@"Status"] intValue];//1:未完工；2:已完工；9:已退项
        if (status == 2) {
            allBol = YES;
            ctvc.serverStatusL.text = @"已完工";
            ctvc.selectedBtn.hidden = NO;
            [ctvc.selectedBtn setImage:[UIImage imageNamed:@"完工"] forState:UIControlStateNormal];
        }else if (status == 1) {
            allBol = NO;
            ctvc.serverStatusL.text = @"未完工";
            ctvc.selectedBtn.hidden = NO;
            [ctvc.selectedBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
        }else if (status == 9) {
            allBol = YES;
            ctvc.serverStatusL.text = @"已退项";
            ctvc.selectedBtn.hidden = YES;
        }
        ctvc.addInfo = ^(void) {
            [selectedArray addObject:info];
        };
        ctvc.removeInfo = ^(void) {
            [selectedArray removeObject:info];
        };
        return ctvc;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(11, 30, CGRectGetWidth(tableView.frame) - 11*2, 30);
        [btn setBackgroundColor:UIColorFromRGB(0x2878D2)];
        if (!allBol) {
            [btn setTitle:@"项目完工" forState:UIControlStateNormal];
        }else {
            [btn setTitle:@"订单完工" forState:UIControlStateNormal];
        }
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(completeClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (resultArray.count != 0) {
        if (indexPath.row < resultArray.count) {
            return 50;
        }else {
            return 60;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - request
- (void)reapirServerItem {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"ConId":_conId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,ReapirServerItem];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            id info = responseObject[@"Result"];
            if ([info isKindOfClass:[NSArray class]]) {
                [resultArray addObjectsFromArray:info];
            }
            [_tableView reloadData];
            [_tableView.header endRefreshing];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (NSMutableArray *)encapData {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *info in selectedArray) {
        NSString *conProjectId = info[@"ID"];
        NSString *status = @"2";
        NSDictionary *_info = @{@"conProjectId":conProjectId,@"Status":status};
        [array addObject:_info];
    }
    return array;
}

- (void)finishRepair:(UIButton *)btn {
    if (selectedArray.count > 0) {
        [ZAActivityBar showWithStatus:LODING_MSG];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *token = [userInfo objectForKey:@"Token"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSDictionary *parameters = @{@"UserToken":userDict,@"TotalCount":[NSString stringWithFormat:@"%ld",selectedArray.count],@"finishRepairs":[self encapData]};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,FinishRepair];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [[responseObject objectForKey:@"Code"] intValue];
            if (code == 0) {
                [ZAActivityBar showSuccessWithStatus:responseObject[@"Message"]];
                NSLog(@"result:   %@",responseObject);
                [selectedArray removeAllObjects];
                [resultArray removeAllObjects];
                [_tableView.header beginRefreshing];
            }else {
                [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        }];
    }else {
        [ZAActivityBar showErrorWithStatus:@"请勾选完工项目"];
    }
}

- (void)finishRepairLast {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *userName = userInfo[@"UserName"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"ConId":_conId,@"UserId":userId,@"UserName":userName};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,FinishRepairLast];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar showSuccessWithStatus:responseObject[@"Message"]];
            NSLog(@"result:   %@",responseObject);
            [self performSelector:@selector(backAction) withObject:nil afterDelay:0.3];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
