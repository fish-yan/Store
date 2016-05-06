//
//  ServicesViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/30.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ServicesViewController.h"
#import "ServiceTableViewCell.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ServiceViewDetal.h"
#import "ToolKit.h"
#import "ScanningQRViewController.h"
#import "UIView+empty.h"

@interface ServicesViewController () {
    ServiceViewDetal *sv;
    int pageIndex;
    int pageSize;
    NSString *textBuf;
    int totalRecordsService;
    NSMutableArray *serviceArray;
    BOOL typeBol;
    NSMutableArray *typeArray;
    NSString *typeId;
}

@end

@implementation ServicesViewController

- (void)initData {
    _addServiceArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    typeArray  = [[NSMutableArray alloc] init];
    pageSize = 20;
    pageIndex = 0;
    totalRecordsService = 0;
    typeId = @"";
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    [self getTypeTableView];
    [self initServiceView];
    [self getServiceList];
}

- (void)initServiceView {
    sv = [[[NSBundle mainBundle] loadNibNamed:@"ServiceViewDetal" owner:self options:nil] lastObject];
    __weak __typeof(& *self)weakSelf = self;
    sv.commitClick = ^(void) {
        [weakSelf hideAlertAction];
    };
    sv.layer.cornerRadius = 8;
    sv.layer.masksToBounds = YES;
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
    self.title = @"服务项目";
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
        [self getServiceTypeList];
    }
}

- (void)typeTableViewAnim:(float)height {
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    [_typeTableView updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [UIView commitAnimations];
}

- (void)doneAction {
    [self desSelected];
    [self hidden];
    if (_passServiceArray) {
        _passServiceArray(_addServiceArray);
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

- (void)checkAddService {
    for (int i = 0; i < _addArray.count; i++) {
        NSMutableDictionary *dict = _addArray[i];
        NSString *serviceId = [ToolKit getStringVlaue:dict[@"Id"]];
        for (int j = 0; j < serviceArray.count; j++) {
            NSMutableDictionary *_dict = [serviceArray[j] mutableCopy];
            NSString *_serviceId = [ToolKit getStringVlaue:_dict[@"Id"]];
            if ([serviceId isEqualToString:_serviceId]) {
                [_dict setObject:@"1" forKey:@"ifAdd"];
                [serviceArray removeObjectAtIndex:j];
                [serviceArray insertObject:_dict atIndex:j];
                break;
            }
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
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"PageIndex":[NSString stringWithFormat:@"%d",pageIndex]};
    NSMutableDictionary *mParameters = [parameters mutableCopy];
    if (textBuf.length > 0) {
        [mParameters setObject:textBuf forKey:@"Key"];
    }
    if (typeId.length > 0) {
        [mParameters setObject:typeId forKey:@"TypeId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProject];
    pageIndex++;
    [manager POST:url parameters:mParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            totalRecordsService = [responseObject[@"Result"][@"TotalRecords"] intValue];
            if (pageIndex == 1) {
                [serviceArray removeAllObjects];
            }
            [serviceArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Projects"]];
            [self checkAddService];
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
            [typeArray addObject:allInfo];
            [typeArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"ProjectTypes"]];
            [_typeTableView reloadData];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (ServiceTableViewCell *)getServiceCell:(NSIndexPath *)indexPath {
    static NSString *serviceCell = @"serviceCell";
    UINib *nib = [UINib nibWithNibName:@"ServiceTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:serviceCell];
    ServiceTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:serviceCell];
    cell.tag = 1000 + indexPath.row;
    __weak ServiceTableViewCell *weakCell = cell;
    cell.addNumL.hidden = YES;
    cell.addService = ^(NSInteger indexTag) {
        NSInteger tag = indexTag - 1000;
        NSMutableDictionary *dict = [serviceArray[tag] mutableCopy];
        [dict setObject:@"1" forKey:@"ifAdd"];
        weakCell.addNumL.hidden = NO;
        weakCell.addNumL.text = @"已添加";
        [_addServiceArray addObject:dict];
        [serviceArray removeObjectAtIndex:tag];
        [serviceArray insertObject:dict atIndex:tag];
    };
    cell.serviceNameL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Name"]];
    cell.serviceCodeL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Code"]];
    cell.serviceGsL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTime"]];
    float price = [[ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTimePrice"]] floatValue];
    cell.servicePriceL.text = [NSString stringWithFormat:@"￥%.2f",price];
    NSString *ifAdd = serviceArray[indexPath.row][@"ifAdd"];
    if (ifAdd) {
        cell.addNumL.hidden = NO;
        cell.addNumL.text = @"已添加";
    }
    return cell;
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
        return serviceArray.count;
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
        cell = [self getServiceCell:indexPath];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:typeCell];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:typeCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = typeArray[indexPath.row][@"TypeName"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = UIColorFromRGB(0x626262);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        if (indexPath.row == (serviceArray.count - 1) && serviceArray.count != totalRecordsService) {
            [self getServiceList];
        }
        if (indexPath.row == (serviceArray.count - 1) && serviceArray.count == totalRecordsService) {
            [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    if (tableView == _tableView) {
        sv.titleL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Name"]];
        sv.codeL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"Code"]];
        sv.gsL.text = [ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTime"]];
        sv.descL.text = @"";
        sv.sgNumL.text = @"";
        float price = [[ToolKit getStringVlaue:serviceArray[indexPath.row][@"WorkTimePrice"]] floatValue];
        sv.priceL.text = [NSString stringWithFormat:@"%.2f",price];
        [self showAlert];
    }else {
        [self typeClick:_typeBtn];
        pageIndex = 0;
        typeId = typeArray[indexPath.row][@"Id"];
        [self getServiceList];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        return 98;
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
    _maskView.hidden = YES;
}

- (void)show {
    _maskView.hidden = NO;
}


- (void)showAlert{
    [self show];
    sv.center = CGPointMake(self.maskView.center.x, self.maskView.center.y - 64/2);
    [self.view addSubview:sv];
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
    [sv.layer addAnimation:popAnimation forKey:nil];
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
    [sv.layer addAnimation:hideAnimation forKey:nil];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [sv removeFromSuperview];
    [self desSelected];
    [self hidden];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    pageIndex = 0;
    textBuf = searchText;
    [self getServiceList];
    typeId = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
