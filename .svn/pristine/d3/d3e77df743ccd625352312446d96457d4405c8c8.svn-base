//
//  SearchUserNameViewController.m
//  StoreReception
//
//  Created by 薛焱 on 16/4/21.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "SearchUserNameViewController.h"
#import "CarInfoListCell.h"
#import <AFNetworking.h>
#import "JDStatusBarNotification.h"
#import "MJRefresh.h"
#import "CarDetailViewController.h"
#import "MBProgressHUD.h"
@interface SearchUserNameViewController ()<UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, copy) NSString *searchKey;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *searchText;
@end

@implementation SearchUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.hidden = YES;
    _searchText = @"";
    _pageSize = 20;
    _pageIndex = 1;
    _dataArray = [NSMutableArray array];
    [_searchBar becomeFirstResponder];
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
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageIndex = 1;
        [self readDataSource];
    }];
    
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _pageIndex++;
        [self readDataSource];
    }];
    // Do any additional setup after loading the view.
}
- (IBAction)backItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)readDataSource{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSString *companyId = userInfo[@"CompanyId"];
    NSDictionary *userToken = @{ @"UserId" : userId, @"Token" : token };
    NSMutableDictionary *parameters = @{@"CompanyId" : companyId, @"Key" : _searchText, @"PageIndex" : [NSString stringWithFormat:@"%ld", _pageIndex], @"PageSize" : [NSString stringWithFormat:@"%ld", _pageSize], @"UserToken" : userToken}.mutableCopy;
    NSString *url = [NSString stringWithFormat:@"%@%@", URL_HEADER, GetMember];
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];   //请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; //响应
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        int code = [responseObject[@"Code"] intValue];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (code == 0) {
            if (_pageIndex == 1) {
                _dataArray = responseObject[@"Result"][@"Cars"];
            }else{
                NSLog(@"%@",_dataArray);
                _dataArray = [_dataArray arrayByAddingObjectsFromArray:responseObject[@"Result"][@"Cars"]].mutableCopy;
            }
            
            if (_dataArray.count == 0) {
                _tableView.hidden = YES;
                [JDStatusBarNotification showWithStatus:@"没有查询到数据"
                                           dismissAfter:2];
            }else{
                _tableView.hidden = NO;
            }
            if ([responseObject[@"Result"][@"Cars"] count] == 0) {
                [_tableView.footer endRefreshingWithNoMoreData];
            }else{
                [_tableView.footer endRefreshing];
            }
            [_tableView.header endRefreshing];
            [_tableView reloadData];
        } else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"]
                                       dismissAfter:2];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _pageIndex = 1;
    _searchText = searchText;
    if (_searchText.length == 0) {
        _tableView.hidden = YES;
    }else{
        _tableView.hidden = NO;
        [self readDataSource];
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CarInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarInfoListCell" forIndexPath:indexPath];
    cell.CarNumLab.text = [NSString stringWithFormat:@"%@-%@",_dataArray[indexPath.row][@"MemberName"], _dataArray[indexPath.row][@"TelNumber"]];
    return cell;
}


#pragma mark - UItableViewDelegete

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBar resignFirstResponder];
    [self performSegueWithIdentifier:@"ToCarDetailVCFromSearchUserNameVC" sender:_dataArray[indexPath.row]];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CarDetailViewController *carDetailVC = segue.destinationViewController;
    [carDetailVC.carInfo setObject:((NSDictionary *)sender)[@"MemberName"] forKey:@"LeaguName"];
    [carDetailVC.carInfo setObject:((NSDictionary *)sender)[@"MemberId"] forKey:@"MemberId"];
    [carDetailVC.carInfo setObject:((NSDictionary *)sender)[@"TelNumber"] forKey:@"DRIVECONTACT"];
}


@end
