//
//  SearchCardViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/3.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SearchCardViewController.h"
#import "SCCardTableViewCell.h"
#import "STCardTableViewCell.h"
#import "TCardViewController.h"
#import "CCardViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ToolKit.h"
#import "UIView+empty.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define CCK @"储值卡"
#define TCK @"套餐卡"

@interface SearchCardViewController () {
    NSMutableArray *ccardArray;
    NSMutableArray *tcardArray;
    NSMutableDictionary *cardDict;
    NSMutableArray *keyArray;
    BOOL tbol;
    BOOL cbol;
}

@end

@implementation SearchCardViewController

- (void)initData {
    ccardArray = [[NSMutableArray alloc] init];
    tcardArray = [[NSMutableArray alloc] init];
    keyArray = [[NSMutableArray alloc] init];
    cardDict = [[NSMutableDictionary alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self getValueCard];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - private

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"卡查询";
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

- (NSMutableString *)getProject:(NSInteger)index {
    NSMutableString *buf = [[NSMutableString alloc] init];
    NSDictionary *dict = tcardArray[index];
    NSArray *array = dict[@"PackageCardProjects"];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *info = array[i];
        [buf appendString:[ToolKit getStringVlaue:info[@"ProjectName"]]];
        [buf appendString:[NSString stringWithFormat:@"（%@次）",[ToolKit getStringVlaue:info[@"SurplusNum"]]]];
        if (i + 1 != array.count) {
            [buf appendString:@"＋"];
        }
    }
    return buf;
}

- (void)setCardDict {
    if (cbol && tbol) {
        [cardDict removeAllObjects];
        [keyArray removeAllObjects];
        if (ccardArray.count > 0) {
            [keyArray addObject:CCK];
            [cardDict setObject:ccardArray forKey:CCK];
        }
        if (tcardArray.count > 0) {
            [keyArray addObject:TCK];
            [cardDict setObject:tcardArray forKey:TCK];
        }
        [_tableView reloadData];
        if (keyArray.count == 0) {
            [_tableView showEmpty];
        }else {
            [_tableView hiddenEmpty];
        }
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = keyArray[section];
    NSArray *values = cardDict[key];
    return values.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (cardDict) {
        return keyArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ccardCell = @"ccardCell";
    static NSString *tcardCell = @"tcardCell";
    UINib *nib = nil;
    UITableViewCell *cell = nil;
    NSString *key = keyArray[indexPath.section];
    if ([key isEqualToString:CCK]) {
        nib = [UINib nibWithNibName:@"SCCardTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ccardCell];
        cell = (SCCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ccardCell];
        ((SCCardTableViewCell *)cell).cardNumL.text = [ToolKit getStringVlaue:ccardArray[indexPath.row][@"MemberNum"]];
        ((SCCardTableViewCell *)cell).endTimeL.text = [ToolKit getStringVlaue:ccardArray[indexPath.row][@"CloseDate"]];
        ((SCCardTableViewCell *)cell).balanceL.text = [ToolKit getStringVlaue:ccardArray[indexPath.row][@"CardBal"]];
    }else {
        nib = [UINib nibWithNibName:@"STCardTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:tcardCell];
        cell = (STCardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tcardCell];
        ((STCardTableViewCell *)cell).memberNumL.text = [NSString stringWithFormat:@"卡号  %@",[ToolKit getStringVlaue:tcardArray[indexPath.row][@"RealCardId"]]];
        ((STCardTableViewCell *)cell).projectL.text = [self getProject:indexPath.row];
        ((STCardTableViewCell *)cell).closeDateL.text = [ToolKit getStringVlaue:tcardArray[indexPath.row][@"CloseDate"]];
        ((STCardTableViewCell *)cell).tccNameL.text = [NSString stringWithFormat:@"卡名称  %@",[ToolKit getStringVlaue:tcardArray[indexPath.row][@"Name"]]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 28)];
    view.backgroundColor = UIColorFromRGB(0xEEEEEE);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, CGRectGetWidth(tableView.frame), 28)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = UIColorFromRGB(0x414141);
    label.font = [UIFont systemFontOfSize:14];
    NSString *key = keyArray[section];
    label.text = key;
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    NSString *key = keyArray[indexPath.section];
    if ([key isEqualToString:CCK]) {
        CCardViewController *ccvc = [[CCardViewController alloc] initWithNibName:@"CCardViewController" bundle:nil];
        ccvc.info = cardDict[key][indexPath.row];
        [self.navigationController pushViewController:ccvc animated:YES];
    }else {
        WS(ws);
        TCardViewController *tcvc = [[TCardViewController alloc] initWithNibName:@"TCardViewController" bundle:nil];
        tcvc.info = cardDict[key][indexPath.row];
        tcvc.refreshData = ^(void) {
            [ws getValueCard];
        };
        [self.navigationController pushViewController:tcvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = keyArray[indexPath.section];
    if ([key isEqualToString:CCK])  {
        return 65;
    }else {
        return 121;
    }
}

#pragma mark - request 
- (void)getValueCard {
    cbol = NO;
    tbol = NO;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSString *companyId = userInfo[@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *phone = _info[@"TelNumber"];
    NSString *memberId = _info[@"MemberId"];
    NSString *carNumber = _info[@"CarNumber"];
    NSMutableDictionary *mutPar = [[NSMutableDictionary alloc] init];
    [mutPar setObject:storeId forKey:@"StoreId"];
    if (memberId.length > 0) {
        [mutPar setObject:memberId forKey:@"MemberId"];
    }
    if (phone.length > 0) {
        [mutPar setObject:phone forKey:@"Mobile"];
    }
    if (carNumber.length > 0) {
        [mutPar setObject:carNumber forKey:@"CarNumber"];
    }
    if (companyId.length > 0) {
        [mutPar setObject:companyId forKey:@"CompanyId"];
    }
    [mutPar setObject:userDict forKey:@"UserToken"];
    NSString *url1 = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetValueCard];
    [manager POST:url1 parameters:mutPar success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [ZAActivityBar dismiss];
        [ccardArray removeAllObjects];
        id result = responseObject[@"Result"];
        if ([result isKindOfClass:[NSDictionary class]]) {
            [ccardArray addObjectsFromArray:responseObject[@"Result"][@"ValueCardInfos"]];
            cbol = YES;
            [self setCardDict];
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
    
    NSString *url2 = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetPackageCard];
    [manager POST:url2 parameters:mutPar success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [ZAActivityBar dismiss];
        [tcardArray removeAllObjects];
        id result = responseObject[@"Result"];
        if ([result isKindOfClass:[NSDictionary class]]) {
            [tcardArray addObjectsFromArray:responseObject[@"Result"][@"PackageCardInfos"]];
            tbol = YES;
            [self setCardDict];
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
