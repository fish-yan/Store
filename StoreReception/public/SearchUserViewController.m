//
//  SearchUserViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/3.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SearchUserViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "SearchCardViewController.h"
#import "UIView+empty.h"
#import "ScanningRecognizeViewController.h"
#import "InputMsgViewController.h"
#import "CardView.h"
#import "TCardViewController.h"
#import "CarWashBillingViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SearchUserViewController () {
    int pageIndex;
    int pageSize;
    NSString *textBuf;
    NSMutableArray *carArray;
    CardView *cardView;
    NSMutableArray *cardArray;
    NSDictionary *carInfo;
}

@end

@implementation SearchUserViewController

- (void)initData {
    pageIndex = 0;
    pageSize = 20;
    textBuf = [[NSMutableString alloc] init];
    carArray = [[NSMutableArray alloc] init];
}

- (void)initCardView {
    cardView = [[[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil] lastObject];
    WS(ws);
    cardView.commitClick = ^(void) {
        [ws hideAlertAction];
    };
    cardView.cancelClick = ^(void) {
        [ws hideAlertAction];
        [ws pushView];
    };
    cardView.selectedClick = ^(NSDictionary *info) {
        [ws hideAlertAction];
        TCardViewController *tcvc = [[TCardViewController alloc] initWithNibName:@"TCardViewController" bundle:nil];
        tcvc.info = info;
        [ws.navigationController pushViewController:tcvc animated:YES];
    };
    cardView.layer.cornerRadius = 8;
    cardView.layer.masksToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initCardView];
    if ([_type isEqualToString:@"InputMsgViewController"]) {
        self.bgView.hidden = NO;
        self.tableView.hidden = YES;
    }
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
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    [gesture setNumberOfTapsRequired:1];
    [_bgView addGestureRecognizer:gesture];
    UITextField * textField = [((UIView *)[_searchBar.subviews objectAtIndex:0]).subviews lastObject];
    CGRect r = textField.frame;
    textField.borderStyle = UITextBorderStyleNone;
    textField.background = [UIImage imageNamed:@"搜索框"];
    _searchBar.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender {
    [_searchBar resignFirstResponder];
}

#pragma mark - private

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)scanClick:(id)sender {
    ScanningRecognizeViewController *srvc = [[ScanningRecognizeViewController alloc] init];
    srvc.passCarLince = ^(NSString *lince) {
        [_searchBar resignFirstResponder];
//        NSString *headLince = [lince substringToIndex:2];
        NSString *endLince = [lince substringFromIndex:2];
//        NSString *_lince = [NSString stringWithFormat:@"%@-%@",headLince,endLince];
        _searchBar.text = endLince;
        textBuf = endLince;
        pageIndex = 0;
        [self getCarInfo];
    };
    [self.navigationController pushViewController:srvc animated:YES];
}

- (IBAction)createNewUser:(id)sender {
    InputMsgViewController *imvc = [[InputMsgViewController alloc] initWithNibName:@"InputMsgViewController" bundle:nil];
    imvc.isAddNew = YES;
    [self.navigationController pushViewController:imvc animated:YES];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"搜索客户车辆";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - request
- (void)getCarInfo {
    pageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSString *companyId = userInfo[@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"Key":textBuf,@"PageIndex":[NSString stringWithFormat:@"%d",pageIndex],@"PageSize":[NSString stringWithFormat:@"%d",pageSize]};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetCar];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            if (pageIndex == 1) {
                [carArray removeAllObjects];
            }
            [carArray addObjectsFromArray:responseObject[@"Result"][@"Cars"]];
            [_tableView reloadData];
            if (carArray.count == 0) {
                if ([_type isEqualToString:@"wash"]) {
                    [self pushView];
                }
                [ZAActivityBar showErrorWithStatus:@"未找到符合条件的数据！"];
                if ([_type isEqualToString:@"InputMsgViewController"]) {
                    _bgView.hidden = NO;
                    _tableView.hidden = YES;
                }else {
                    [_tableView showEmpty];
                    _tableView.hidden = NO;
                }
            }else {
                [ZAActivityBar dismiss];
                _tableView.hidden = NO;
                if ([_type isEqualToString:@"InputMsgViewController"]) {
                    _bgView.hidden = YES;
                }else {
                    [_tableView hiddenEmpty];
                }
            }
            NSLog(@"JSON: %@", responseObject);
        }else {
            NSLog(@"msg:  %@",responseObject[@"Message"]);
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getWashCard {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSString *memberId = carInfo[@"MemberId"];
    NSString *carNum = carInfo[@"CarNumber"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"MemberId":memberId,@"carNum":carNum,@"StoreId":storeId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetWashCarCard];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            NSArray *result = [[NSArray alloc] initWithArray:responseObject[@"Result"][@"PackageCardInfos"]];
            if (result.count > 0) {
                cardView.result = result;
                [cardView.tableView reloadData];
                [self showAlertAction];
            }else {
                [self pushView];
            }
        }else {
            NSLog(@"msg:  %@",responseObject[@"Message"]);
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)pushView {
    CarWashBillingViewController *cwbvc = [[CarWashBillingViewController alloc]init];
    cwbvc.carInfo = carInfo;
    [self.navigationController pushViewController:cwbvc animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return carArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *itemCell = @"itemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = carArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",dict[@"CarNumber"],dict[@"MemberName"]];
    cell.textLabel.textColor = UIColorFromRGB(0x5D5D5D);
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(cell.frame), 1)];
    lineV.backgroundColor = UIColorFromRGB(0xD9D9D9);
    [cell.contentView addSubview:lineV];
    __weak __typeof(UITableViewCell *)weakCell = cell;
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakCell).with.insets(UIEdgeInsetsMake(43, 0, 0, 0));
    }];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar resignFirstResponder];
    NSDictionary *dict = [carArray[indexPath.row] copy];
    if ([_type isEqualToString:@"ItemBillingViewController"]) {
        _backLicen(dict);
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([_type isEqualToString:@"InputMsgViewController"]) {
        InputMsgViewController *imvc = [[InputMsgViewController alloc] initWithNibName:@"InputMsgViewController" bundle:nil];
        imvc.info = dict;
        imvc.refresh = ^(){
            [self searchBarSearchButtonClicked:_searchBar];
        };
        [self.navigationController pushViewController:imvc animated:YES];
    }else if ([_type isEqualToString:@"wash"]) {
        carInfo = dict;
        [self getWashCard];
    }else {
        SearchCardViewController *scvc = [[SearchCardViewController alloc] initWithNibName:@"SearchCardViewController" bundle:nil];
        scvc.info = dict;
        [self.navigationController pushViewController:scvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    pageIndex = 0;
    textBuf = searchText.uppercaseString;
    if (textBuf.length > 0) {
        if (![_type isEqualToString:@"wash"]) {
            [self getCarInfo];
        }
    }else {
        if ([_type isEqualToString:@"InputMsgViewController"]) {
            _bgView.hidden = NO;
        }else {
            [_tableView hiddenEmpty];
        }
        self.tableView.hidden = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    pageIndex = 0;
    textBuf = searchBar.text.uppercaseString;
    [self getCarInfo];
    [searchBar resignFirstResponder];
}

#pragma mark - show CardView
#pragma mark - hiden or show popview
- (void)hidden {
    [cardView removeFromSuperview];
    _maskView.hidden = YES;
}

- (void)show {
    _maskView.hidden = NO;
}

- (void)showAlert{
    [self show];
    cardView.center = CGPointMake(self.maskView.center.x, self.maskView.center.y - 64/2);
    [self.view addSubview:cardView];
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
    [cardView.layer addAnimation:popAnimation forKey:nil];
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
    [cardView.layer addAnimation:hideAnimation forKey:nil];
    
}

- (void)showAlertAction{
    if ([cardView superview] == nil) {
        [self showAlert];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [cardView removeFromSuperview];
    [self desSelected];
    [self hidden];
}

- (void)desSelected {
    NSIndexPath *selected = [_tableView indexPathForSelectedRow];
    if(selected)
        [_tableView deselectRowAtIndexPath:selected animated:NO];
}

@end
