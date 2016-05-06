//
//  ItemListViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ItemListViewController.h"
#import "ItemTableViewCell.h"
#import "ZAActivityBar.h"
#import "ItemViewDetal.h"
#import <AFNetworking/AFNetworking.h>
#import "ToolKit.h"
#import "UIView+empty.h"
#import "ScanningQRViewController.h"
#import "SearchItemHistoryPriceViewController.h"
#import "StockViewDetal.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ItemListViewController () {
    ItemViewDetal *iv;
    NSMutableArray *itemArray;
    NSString *textBuf;
    int itemPageIndex;
    int pageSize;
    int totalRecordsItem;
    NSMutableArray *typeArray;
    BOOL typeBol;
    NSString *typeId;
    NSString *itemId;
    NSMutableArray *storeArray;
    StockViewDetal *svd;
    UIView *mv;
}

@end

@implementation ItemListViewController

- (void)initData {
    _itemDict = [[NSMutableDictionary alloc] init];
    itemArray = [[NSMutableArray alloc] init];
    typeArray  = [[NSMutableArray alloc] init];
    storeArray  = [[NSMutableArray alloc] init];
    typeId = @"";
    pageSize = 20;
}

- (void)initStoreView {
    svd = [[[NSBundle mainBundle] loadNibNamed:@"StockViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    svd.commitClick = ^(void) {
        [weakSelf hideAlertAction];
    };
    svd.layer.cornerRadius = 8;
    svd.layer.masksToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initStoreView];
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
    NSLog(@"ss:   %f-%f",_topView.frame.origin.y + _topView.frame.size.height,CGRectGetWidth(_topView.frame));
    [self getTypeTableView];
    [self initItemView];
    [self getItemList];
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

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"aa:   %@",itemArray);
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
    self.title = @"添加精品";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(250, 0, 44, 44)];
    [rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)initItemView {
    iv = [[[NSBundle mainBundle] loadNibNamed:@"ItemViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    iv.commitClick = ^(void) {
        [weakSelf hideAlertAction];
    };
    iv.layer.cornerRadius = 8;
    iv.layer.masksToBounds = YES;
}

- (void)typeTableViewAnim:(float)height {
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    [_typeTableView updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [UIView commitAnimations];
}

- (IBAction)typeClick:(id)sender {
    [self desSelected];
    if (!typeBol) {
        _maskTableView.hidden = NO;
        [self typeTableViewAnim:45 * 5];
    }else {
        _maskTableView.hidden = YES;
        [self typeTableViewAnim:0];
    }
    typeBol = !typeBol;
    [self hidden];
    if (typeArray.count == 0) {
        [self getTypeList];
    }
}

- (IBAction)scanClick:(id)sender {
    [self desSelected];
    [self hidden];
    ScanningQRViewController *svc = [[ScanningQRViewController alloc] init];
    svc.passScanResult = ^(NSString *result) {
        if (result.length > 0) {
            _searchBar.text = result;
            textBuf = _searchBar.text;
            itemPageIndex = 0;
            [self getItemList];
        }
    };
    [self.navigationController presentViewController:svc animated:YES completion:^{
        
            }];
}

- (void)doneAction {
    [self desSelected];
    [self hidden];
    if (_passItemDict) {
        _passItemDict(_itemDict);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backAction {
    [self desSelected];
    [self hidden];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:SHOP_CART];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)desSelected {
    NSIndexPath *selected = [_tableView indexPathForSelectedRow];
    if(selected)
        [_tableView deselectRowAtIndexPath:selected animated:NO];
}

- (void)checkAddItem {
    for (int i = 0; i < _addArray.count; i++) {
        NSMutableDictionary *dict = _addArray[i];
        NSString *itemId = [ToolKit getStringVlaue:dict[@"Id"]];
        NSString *buyNum = dict[@"BuyNum"];
        for (int j = 0; j < itemArray.count; j++) {
            NSMutableDictionary *_dict = [itemArray[j] mutableCopy];
            NSString *_itemId = [ToolKit getStringVlaue:_dict[@"Id"]];
            if ([itemId isEqualToString:_itemId]) {
                [_dict setObject:buyNum forKey:@"BuyNum"];
                [itemArray removeObjectAtIndex:j];
                [itemArray insertObject:_dict atIndex:j];
                break;
            }
        }
    }
}

- (ItemTableViewCell *)getItemCell:(NSIndexPath *)indexPath {
    WS(ws);
    static NSString *itemCell = @"itemCell";
    UINib *nib = [UINib nibWithNibName:@"ItemTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:itemCell];
    ItemTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:itemCell];
    cell.tag = 1000 + indexPath.row;
    cell.addNumL.hidden = YES;
    if ([_fromPage isEqualToString:NORMAL_FROMPAGE]) {
        cell.moreBtn.hidden = YES;
        cell.kcTL.hidden = NO;
        cell.kcNumL.hidden = NO;
    }else {
        cell.kcNumL.hidden = YES;
        cell.kcTL.hidden = YES;
        cell.moreBtn.hidden = NO;
    }
    NSString *buyNum = itemArray[indexPath.row][@"BuyNum"];
    int ibn = [buyNum intValue];
    int storeNum = [[ToolKit getStringVlaue:itemArray[indexPath.row][@"StoreNum"]]intValue];
    __weak ItemTableViewCell *weakCell = cell;
    cell.moreClick = ^(void) {
        NSDictionary *info = itemArray[indexPath.row];
        itemId = info[@"ProductId"];
        [ws getItemStoreList];
    };
    cell.addItem = ^(NSInteger indexTag) {
        NSInteger tag = indexTag - 1000;
        NSMutableDictionary *dict = _itemDict[[NSString stringWithFormat:@"%ld",(long)tag]];
        int _buyNum = 0;
        NSString *ssbuyNum = nil;
        if (dict) {
            ssbuyNum = dict[@"BuyNum"];
        }else {
            dict = [itemArray[tag] mutableCopy];
            ssbuyNum = dict[@"BuyNum"];
            if (!ssbuyNum) {
                ssbuyNum = @"0";
            }
        }
        _buyNum = [ssbuyNum intValue];
        NSString *sbuyNum = nil;
        if ((_buyNum + 1 )== storeNum) {
            if ([_fromPage isEqualToString:NORMAL_FROMPAGE]) {
                [weakCell.addBtn setTitle:@"卖光了" forState:UIControlStateNormal];
                weakCell.addBtn.enabled = NO;
            }
            sbuyNum = [NSString stringWithFormat:@"%d",++_buyNum ];
        }else {
            weakCell.addBtn.enabled = YES;
            sbuyNum = [NSString stringWithFormat:@"%d",++_buyNum ];
        }
        [dict setObject:sbuyNum forKey:@"BuyNum"];
        weakCell.addNumL.text = [NSString stringWithFormat:@"已添加：%@",sbuyNum];
        [_itemDict setObject:dict forKey:[NSString stringWithFormat:@"%ld",(long)tag]];
        [itemArray removeObjectAtIndex:tag];
        [itemArray insertObject:dict atIndex:tag];
        weakCell.addNumL.hidden = NO;
        
    };
    cell.searchHistoryPrice = ^(NSInteger tag) {
        NSInteger ctag = tag - 1000;
        NSMutableDictionary *dict = itemArray[ctag];
        SearchItemHistoryPriceViewController *sipvc = [[SearchItemHistoryPriceViewController alloc] initWithNibName:@"SearchItemHistoryPriceViewController" bundle:nil];
        sipvc.info = dict;
        [ws.navigationController pushViewController:sipvc animated:YES];
    };
    cell.titleL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"ProductName"]];
    cell.ggL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"SpecModel"]];
    cell.codeL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StockNo"]];
    cell.kcNumL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StoreNum"]];
    cell.unitL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Unit"]];
    cell.itemPpL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Brand"]];
    float acount = [[ToolKit getStringVlaue:itemArray[indexPath.row][@"SalePrice"]]floatValue];
    cell.priceL.text = [NSString stringWithFormat:@"￥%.2f",acount];
    if (buyNum) {
        cell.addNumL.hidden = NO;
        if ([_fromPage isEqualToString:NORMAL_FROMPAGE]) {
            if (ibn == storeNum) {
                [cell.addBtn setTitle:@"卖光了" forState:UIControlStateNormal];
                cell.addBtn.enabled = NO;
            }else {
                cell.addBtn.enabled = YES;
            }
        }
        cell.addNumL.text = [NSString stringWithFormat:@"已添加：%@",buyNum];
    }else {
        cell.addBtn.enabled = YES;
        [cell.addBtn setTitle:@"添加" forState:UIControlStateNormal];
    }
    return cell;
}

#pragma mark - request
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

- (void)getItemList {
    itemPageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"PageIndex":[NSString stringWithFormat:@"%d",itemPageIndex]};
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    if (textBuf.length > 0) {
        [mParameters setObject:textBuf forKey:@"Key"];
    }
    if (typeId.length > 0) {
        [mParameters setObject:typeId forKey:@"TypeId"];
    }
    NSString *url = @"";
    if ([_fromPage isEqualToString:NORMAL_FROMPAGE]) {
        url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProduct];
        [mParameters setObject:storeId forKey:@"StoreId"];
    }else {
        url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProductAll];
    }
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            if (itemPageIndex == 1) {
                [itemArray removeAllObjects];
            }
            totalRecordsItem = [responseObject[@"Result"][@"TotalRecords"] intValue];
            [itemArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Products"]];
            [self checkAddItem];
            [_tableView reloadData];
            if (itemArray.count == 0) {
                [_tableView showEmpty];
            }else {
                [_tableView hiddenEmpty];
            }
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getTypeList {
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
            [typeArray addObject:allInfo];
            [typeArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"ProductTypes"]];
            [_typeTableView reloadData];
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
    [self desSelected];
    [self hidden];
    return YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        return itemArray.count;
    }else {
        return typeArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *typeCell = @"typeCell";
    UITableViewCell *cell = nil;
    if (tableView == _tableView) {
        cell = [self getItemCell:indexPath];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:typeCell];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = typeArray[indexPath.row][@"ProType"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = UIColorFromRGB(0x626262);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        if (indexPath.row == (itemArray.count - 1) && itemArray.count != totalRecordsItem) {
            [self getItemList];
        }
        if (indexPath.row == (itemArray.count - 1) && itemArray.count == totalRecordsItem) {
            [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    if (tableView == _tableView) {
        mv = iv;
        iv.titleL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"ProductName"]];
        iv.codeL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StockNo"]];
        iv.ggL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"SpecModel"]];
        iv.ckL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"WarehouseName"]];
        float price = [[ToolKit getStringVlaue:itemArray[indexPath.row][@"SalePrice"]] floatValue];
        iv.priceL.text = [NSString stringWithFormat:@"%.2f",price];
        iv.kcNuml.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"StoreNum"]];
        iv.gysL.text = [ToolKit getStringVlaue:itemArray[indexPath.row][@"Supplier"]];
        [self showAlertAction];
    }else {
        [self typeClick:_typeBtn];
        itemPageIndex = 0;
        typeId = typeArray[indexPath.row][@"Id"];
        [self getItemList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        return 150;
    }else {
        return 45;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
    [self desSelected];
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
    [self desSelected];
    [self hidden];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    itemPageIndex = 0;
    textBuf = searchText;
    [self getItemList];
    typeId = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
