//
//  WashListViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "WashListViewController.h"
#import "ServiceTableViewCell.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ServiceViewDetal.h"
#import "ToolKit.h"
#import "ScanningQRViewController.h"
#import "UIView+empty.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface WashListViewController () {
    NSString *textBuf;
    NSMutableArray *serviceArray;
}

@end

@implementation WashListViewController

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"添加洗车";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData {
    serviceArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    [self initData];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    for (UIView *view in self.searchBar.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    UITextField * textField = [((UIView *)[_searchBar.subviews objectAtIndex:0]).subviews lastObject];
    CGRect r = textField.frame;
    textField.borderStyle = UITextBorderStyleNone;
    textField.background = [UIImage imageNamed:@"搜索框"];
    _searchBar.delegate = self;
    [self getServiceList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)checkAddWash {
    for (int j = 0; j < serviceArray.count; j++) {
        NSMutableDictionary *_dict = [serviceArray[j] mutableCopy];
        NSString *_serviceId = [ToolKit getStringVlaue:_dict[@"ID"]];
        NSString *serviceId = [ToolKit getStringVlaue:_washInfo[@"ID"]];
        if ([serviceId isEqualToString:_serviceId]) {
            [_dict setObject:@"1" forKey:@"ifAdd"];
            [serviceArray removeObjectAtIndex:j];
            [serviceArray insertObject:_dict atIndex:j];
            break;
        }
    }
}

#pragma mark - request
- (void)getServiceList {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId};
    //,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"PageIndex":[NSString stringWithFormat:@"%d",pageIndex]
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    if (textBuf.length > 0) {
        [mParameters setObject:textBuf forKey:@"Key"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetWashCarItem];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [serviceArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"WashItemList"]];
            [self checkAddWash];
            [_tableView reloadData];
            if (serviceArray.count == 0) {
                [_tableView showEmpty];
            }else {
                [_tableView hiddenEmpty];
            }
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (ServiceTableViewCell *)getServiceCell:(NSIndexPath *)indexPath {
    WS(ws);
    static NSString *serviceCell = @"serviceCell";
    UINib *nib = [UINib nibWithNibName:@"ServiceTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:serviceCell];
    ServiceTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:serviceCell];
    cell.tag = 1000 + indexPath.row;
    cell.addBtn.enabled = YES;
    __weak ServiceTableViewCell *weakCell = cell;
    cell.addNumL.hidden = YES;
    cell.addService = ^(NSInteger indexTag) {
        NSInteger tag = indexTag - 1000;
        NSMutableDictionary *dict = [serviceArray[tag] mutableCopy];
        [dict setObject:@"1" forKey:@"ifAdd"];
        weakCell.addNumL.hidden = NO;
        weakCell.addNumL.text = @"已选择";
        weakCell.addBtn.enabled = NO;
        if (_passService) {
            _passService(dict);
            [ws.navigationController popViewControllerAnimated:YES];
        }
    };
    cell.serviceNameL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"StyleName"]];
    cell.serviceCodeL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"projectCode"]];
    cell.serviceGsL.text = @"1";
    float price = [[ToolKit getStringVlaue:serviceArray[indexPath.row][@"CostMoney"]] floatValue];
    cell.servicePriceL.text = [NSString stringWithFormat:@"￥%.2f",price];
    NSString *ifAdd = serviceArray[indexPath.row][@"ifAdd"];
    if (ifAdd) {
        cell.addNumL.hidden = NO;
        cell.addNumL.text = @"已选择";
        cell.addBtn.enabled = NO;
    }
    return cell;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return serviceArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self getServiceCell:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [serviceArray removeAllObjects];
    textBuf = searchText;
    [self getServiceList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
