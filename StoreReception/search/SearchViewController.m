//
//  ItemListViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SearchViewController.h"
#import "SItemTableViewCell.h"
#import "ScanningQRViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ServiceViewDetal.h"
#import "ItemViewDetal.h"
#import "SServiceTableViewCell.h"
#import "ToolKit.h"
#import "UIView+empty.h"
#import "StockViewDetal.h"
#import "SearchItemHistoryPriceViewController.h"

@interface SearchViewController () {
    int click;
    ServiceViewDetal *sv;
    ItemViewDetal *iv;
    StockViewDetal *svd;
    UIView *mv;
    int servicePageIndex;
    int itemPageIndex;
    int pageSize;
    NSMutableArray *itemArray;
    NSMutableArray *serviceArray;
    NSString *text;
    int totalRecordsService;
    int totalRecordsItem;
    NSMutableArray *itemTypeArray;
    NSMutableArray *serviceTypeArray;
    BOOL typeBol;
    BOOL outView;
    NSString *typeId;
    NSString *itemId;
    NSMutableArray *storeArray;
    BOOL subFunBol;
}

@end

@implementation SearchViewController

- (void)initData {
    subFunBol = NO;
    click = 0;
    itemArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    itemTypeArray = [[NSMutableArray alloc] init];
    serviceTypeArray = [[NSMutableArray alloc] init];
    storeArray = [[NSMutableArray alloc] init];
    servicePageIndex = 0;
    itemPageIndex = 0;
    pageSize = 20;
    typeId = @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initData];
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
    _typeBtn.hidden = NO;
    [self initServiceView];
    [self initItemView];
    [self initStoreView];
    mv = sv;
    [self getServiceList];
    [self getTypeTableView];
}

- (void)getTypeTableView {
    _typeTableView = UITableView.new;
    _typeTableView.delegate = self;
    _typeTableView.dataSource = self;
    [self.view addSubview:_typeTableView];
    [_typeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.height.mas_equalTo(0);
    }];
}

- (void)typeTableViewAnim:(float)height {
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    [_typeTableView updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"查询";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)closeFun { //打开子窗口的时候，关掉类别，扫描，父层的点击功能  例如打开更多库存小窗口
    _typeBtn.enabled = NO;
    _scanBtn.enabled = NO;
    subFunBol = YES;
}

- (void)openFun {//关掉子窗口的时候，打开类别，扫描，父层的点击功能  例如关掉更多库存小窗口
    _typeBtn.enabled = YES;
    _scanBtn.enabled = YES;
    subFunBol = NO;
}

- (void)initStoreView {
    svd = [[[NSBundle mainBundle] loadNibNamed:@"StockViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    svd.commitClick = ^(void) {
        [weakSelf openFun];
        [weakSelf hideAlertAction];
    };
    svd.layer.cornerRadius = 8;
    svd.layer.masksToBounds = YES;
}

- (void)initServiceView {
    sv = [[[NSBundle mainBundle] loadNibNamed:@"ServiceViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    sv.commitClick = ^(void) {
        [weakSelf openFun];
        [weakSelf hideAlertAction];
    };
    sv.layer.cornerRadius = 8;
    sv.layer.masksToBounds = YES;
}

- (void)initItemView {
    iv = [[[NSBundle mainBundle] loadNibNamed:@"ItemViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    iv.commitClick = ^(void) {
        [weakSelf openFun];
        [weakSelf hideAlertAction];
    };
    iv.layer.cornerRadius = 8;
    iv.layer.masksToBounds = YES;
}

- (IBAction)typeClick:(id)sender {
    if (!typeBol) {
        _maskTableView.hidden = NO;
        [self typeTableViewAnim:45 * 5];
    }else {
        _maskTableView.hidden = YES;
        [self typeTableViewAnim:0];
    }
    typeBol = !typeBol;
    [self hidden];
    if (click == 1) {
        if (itemTypeArray.count == 0) {
            [self getItemTypeList];
        }
    }else {
        if (serviceTypeArray.count == 0) {
            [self getServiceTypeList];
        }
    }
    [_typeTableView reloadData];
}

- (IBAction)scanClick:(id)sender {
    [self hidden];
    ScanningQRViewController *svc = [[ScanningQRViewController alloc] init];
    svc.passScanResult = ^(NSString *result) {
        if (result.length > 0) {
            _searchBar.text = result;
            text = _searchBar.text;
            itemPageIndex = 0;
            [self getItemList];
        }
    };
    [self presentViewController:svc animated:YES completion:^{}];
}

- (void)backAction {
    [self hidden];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)serviceClick:(id)sender {
    click = 0;
    text = @"";
    _searchBar.placeholder = @"请输入项目名称/编码";
    [self hidden];
    _typeBtn.hidden = NO;
    _scanBtn.hidden = YES;
    _itemTable.hidden = YES;
    _serviceTable.hidden = NO;
    _searchBar.placeholder = @"请输入项目名称/编码";
    [_serviceTable reloadData];
    [_serviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_serviceBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
    [_itemBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_itemBtn setBackgroundColor:UIColorFromRGB(0xEDEDED)];
    if (serviceArray.count == 0) {
        servicePageIndex = 0;
        [self getServiceList];
    }
}

- (IBAction)itemClick:(id)sender {
    click = 1;
    text = @"";
    [self hidden];
    _typeBtn.hidden = NO;
    _scanBtn.hidden = NO;
    _itemTable.hidden = NO;
    _serviceTable.hidden = YES;
    _searchBar.placeholder = @"请输入名称/品牌/编码/规格/条形码";
    [_itemTable reloadData];
    [_itemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_itemBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
    [_serviceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_serviceBtn setBackgroundColor:UIColorFromRGB(0xEDEDED)];
    if (itemArray.count == 0) {
        itemPageIndex = 0;
        [self getItemList];
    }
}

- (SItemTableViewCell *)getItemCell:(NSIndexPath *)indexPath {
    static NSString *itemCell = @"itemCell";
    UINib *nib = [UINib nibWithNibName:@"SItemTableViewCell" bundle:nil];
    [_itemTable registerNib:nib forCellReuseIdentifier:itemCell];
    SItemTableViewCell *cell = [_itemTable dequeueReusableCellWithIdentifier:itemCell];
    cell.tag = indexPath.row;
    __weak __typeof(& *self)weakSelf = self;
    cell.moreKc = ^(NSInteger indexTag) {
        [weakSelf closeFun];
        NSDictionary *info = itemArray[indexTag];
        itemId = info[@"ProductId"];
        [weakSelf getItemStoreList];
    };
    cell.searchHistoryPrice = ^(NSInteger tag) {
        NSMutableDictionary *dict = itemArray[tag];
        SearchItemHistoryPriceViewController *sipvc = [[SearchItemHistoryPriceViewController alloc] initWithNibName:@"SearchItemHistoryPriceViewController" bundle:nil];
        sipvc.info = dict;
        [weakSelf.navigationController pushViewController:sipvc animated:YES];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.kcBtn.hidden = NO;
    cell.kctL.hidden = NO;
    cell.unitL.hidden = NO;
    cell.unitTL.hidden = NO;
    cell.numL.hidden = YES;
    cell.numTL.hidden = YES;
    cell.itemNameL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"ProductName"]];
    cell.itemGgL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"SpecModel"]];
    cell.itemCodeL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StockNo"]];
    cell.unitL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Unit"]];
    cell.itemPpL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Brand"]];
    float acount = [[ToolKit getStringVlaue:itemArray[indexPath.row][@"SalePrice"]]floatValue];
    cell.acountL.text = [NSString stringWithFormat:@"￥%.2f",acount];
    return cell;
}

- (SServiceTableViewCell *)getServiceCell:(NSIndexPath *)indexPath {
    static NSString *serviceCell = @"serviceCell";
    UINib *nib = [UINib nibWithNibName:@"SServiceTableViewCell" bundle:nil];
    [_serviceTable registerNib:nib forCellReuseIdentifier:serviceCell];
    SServiceTableViewCell *cell = [_serviceTable dequeueReusableCellWithIdentifier:serviceCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.serviceNameL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Name"]];
    cell.serviceCountL.hidden = NO;
    cell.serviceCountL.text = [NSString stringWithFormat:@"工时  %@",[ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTime"]]];
    float price = [[ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTimePrice"]] floatValue];
    cell.serviceNL.text = [NSString stringWithFormat:@"项目编码  %@",[ToolKit getStringVlaue:serviceArray[indexPath.row][@"Code"]]];
    [cell.serviceBtn setTitle:[NSString stringWithFormat:@"￥%.2f",price] forState:UIControlStateNormal];
    return cell;
}

#pragma mark - request
- (void)getItemList {
    itemPageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreId":storeId,@"CompanyId":companyId,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"PageIndex":[NSString stringWithFormat:@"%d",itemPageIndex]};
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    if (text.length > 0) {
        [mParameters setObject:text forKey:@"Key"];
    }
    if (typeId.length > 0) {
        [mParameters setObject:typeId forKey:@"TypeId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProductByCompany];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            totalRecordsItem = [responseObject[@"Result"][@"TotalRecords"] intValue];
            if (itemPageIndex == 1) {
                [itemArray removeAllObjects];
            }
            [itemArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Products"]];
            [_itemTable reloadData];
            if (itemArray.count == 0) {
                [_itemTable showEmpty];
                //[ZAActivityBar showErrorWithStatus:@"查无数据"];
            }else {
                [_itemTable hiddenEmpty];
                [ZAActivityBar dismiss];
            }
            [ZAActivityBar dismiss];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getServiceList {
    servicePageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"PageIndex":[NSString stringWithFormat:@"%d",servicePageIndex]};
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    if (text.length > 0) {
        [mParameters setObject:text forKey:@"Key"];
    }
    if (typeId.length > 0) {
        [mParameters setObject:typeId forKey:@"TypeId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProject];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            totalRecordsService = [responseObject[@"Result"][@"TotalRecords"] intValue];
            if (servicePageIndex == 1) {
                [serviceArray removeAllObjects];
            }
            [serviceArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Projects"]];
            [_serviceTable reloadData];
            if (serviceArray.count == 0) {
                [_serviceTable showEmpty];
                //                    [ZAActivityBar showErrorWithStatus:@"查无数据"];
            }else {
                [_serviceTable hiddenEmpty];
                [ZAActivityBar dismiss];
            }
            [ZAActivityBar dismiss];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getServiceTypeList {
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
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProjectTypes];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            NSDictionary *allInfo = @{@"ID":@"",@"Code":@"",@"TypeName":@"全部"};
            [serviceTypeArray addObject:allInfo];
            [serviceTypeArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"ProjectTypes"]];
            [_typeTableView reloadData];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getItemTypeList {
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
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProductType];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            NSDictionary *allInfo = @{@"Id":@"",@"ProType":@"全部"};
            [itemTypeArray addObject:allInfo];
            [itemTypeArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"ProductTypes"]];
            [_typeTableView reloadData];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getItemStoreList {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreId":storeId,@"CompanyId":companyId,@"ProId":itemId};
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProSumByCompany];
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            mv = svd;
            [storeArray removeAllObjects];
            [storeArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Products"]];
            svd.storeArray = storeArray;
            [svd.tableView reloadData];
            [self showAlertAction];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self hidden];
    return YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (click == 0) {
        if (tableView == _serviceTable) {
            return serviceArray.count;
        }else {
            return serviceTypeArray.count;
        }
    }else {
        if (tableView == _itemTable) {
            return itemArray.count;
        }else {
            return itemTypeArray.count;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *typeCell = @"typeCell";
    UITableViewCell *cell = nil;
    if (click == 1) {
        if (tableView == _itemTable) {
            cell = [self getItemCell:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:typeCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (itemTypeArray.count > 0) {
                cell.textLabel.text = itemTypeArray[indexPath.row][@"ProType"];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.textColor = UIColorFromRGB(0x626262);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
        }
    }else {
        if (tableView == _serviceTable) {
            cell = [self getServiceCell:indexPath];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:typeCell];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if (serviceTypeArray.count > 0) {
                cell.textLabel.text = serviceTypeArray[indexPath.row][@"TypeName"];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.textColor = UIColorFromRGB(0x626262);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    if (!subFunBol) {
        if (tableView != _typeTableView) {
            if (click == 0) {
                mv = sv;
                sv.titleL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Name"]];
                sv.codeL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Code"]];
                sv.gsL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTime"]];
                sv.descL.text = @"";
                sv.sgNumL.text = @"";
                float price = [[ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTimePrice"]] floatValue];
                sv.priceL.text = [NSString stringWithFormat:@"%.2f",price];
            }else {
                mv = iv;
                iv.titleL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"ProductName"]];
                iv.codeL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StockNo"]];
                iv.ggL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"SpecModel"]];
                iv.ckL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"WarehouseName"]];
                float price = [[ToolKit getStringVlaue:itemArray[indexPath.row][@"SalePrice"]] floatValue];
                iv.priceL.text = [NSString stringWithFormat:@"%.2f",price];
                iv.kcNuml.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StoreNum"]];
                iv.gysL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Supplier"]];
            }
            [self showAlertAction];
        }else {
            [self typeClick:_typeBtn];
            if (click == 0) {
                servicePageIndex = 0;
                typeId = serviceTypeArray[indexPath.row][@"Id"];
                [self getServiceList];
            }else {
                itemPageIndex = 0;
                typeId = itemTypeArray[indexPath.row][@"Id"];
                [self getItemList];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (click == 1) {
        if (tableView == _itemTable) {
            return 152;
        }else {
            return 45;
        }
    }else {
        if (tableView == _serviceTable) {
            return 72;
        }else {
            return 45;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (click == 0) {
        if (indexPath.row == (serviceArray.count - 1) && serviceArray.count != totalRecordsService) {
            [self getServiceList];
        }
        if (indexPath.row == (serviceArray.count - 1) && serviceArray.count == totalRecordsService) {
            [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
        }
    }else {
        if (tableView == _itemTable) {
            if (indexPath.row == (itemArray.count - 1)  && itemArray.count != totalRecordsItem) {
                [self getItemList];
            }
            if (indexPath.row == (itemArray.count - 1) && itemArray.count == totalRecordsItem) {
                [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
    [self hidden];
}

#pragma mark - hiden or show popview
- (void)hidden {
    [mv removeFromSuperview];
    _maskView.hidden = YES;
}

- (void)show {
    _maskView.hidden = NO;
}

- (void)showAlert{
    [self show];
    mv.center = CGPointMake(self.maskView.center.x, self.maskView.center.y - 64/2);
    [self.view addSubview:mv];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [mv.layer addAnimation:popAnimation forKey:nil];
}

- (void)hideAlertAction {
    CAKeyframeAnimation *hideAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    hideAnimation.duration = 0.4;
    hideAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.00f, 0.00f, 0.00f)]];
    hideAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f];
    hideAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    hideAnimation.delegate = self;
    [mv.layer addAnimation:hideAnimation forKey:nil];
    
}

- (void)showAlertAction{
    if ([mv superview] == nil) {
        [self showAlert];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [mv removeFromSuperview];
    [self hidden];
}

- (void)searchText {
    if (click == 0) {
        servicePageIndex = 0;
        [serviceArray removeAllObjects];
        [self getServiceList];
    }else {
        itemPageIndex = 0;
        [itemArray removeAllObjects];
        [self getItemList];
    }
}

#pragma mark - UISearchBarDelegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    text = searchText;
//    [self searchText];
//    typeId = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    text = _searchBar.text;
    [self searchText];
}

@end
