//
//  TCardViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/3.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "TCardViewController.h"
#import "TCardTableViewCell.h"
#import "CardMsgTableViewCell.h"
#import "TCardServiceSubView.h"
#import "CardRecordTableViewCell.h"
#import "ToolKit.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+empty.h"

@interface TCardViewController () {
    int click;
    NSMutableArray *serviceArray;
    NSMutableArray *okServiceArray;
    NSMutableArray *cardMsgArray;
    NSMutableArray *cardRecordArray;
    NSMutableArray *projectArray;
    UIView *lineV;
    float height;
    int subClick;
}

@end

@implementation TCardViewController

- (void)getProject {
    serviceArray = [[NSMutableArray alloc] init];
    NSArray *array = _info[@"PackageCardProjects"];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *info = array[i];
        NSString *serviceName = [ToolKit getStringVlaue:info[@"ProjectName"]];
        NSString *count = [ToolKit getStringVlaue:info[@"SurplusNum"]];
        NSString *projectNum = [ToolKit getStringVlaue:info[@"ProjectNum"]];
        NSString *content = [NSString stringWithFormat:@"%@（剩余%@次）",serviceName,count];
        int icount = [count intValue];
        NSString *key = nil;
        if (icount != 0) {
            key = @"1";
        }else {
            key = @"0";
        }
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:content,@"content",projectNum,@"ProjectNum",key,@"num", nil];
        [serviceArray addObject:dict];
    }
}

- (NSString *)getProjectMsg {
    NSString *content = nil;
    NSMutableString *buf = [[NSMutableString alloc] init];
    NSArray *array = _info[@"PackageCardProjects"];
    for (int i = 0; i < array.count; i++) {
        NSDictionary *info = array[i];
        NSString *serviceName = [ToolKit getStringVlaue:info[@"ProjectName"]];
        NSString *count = [ToolKit getStringVlaue:info[@"SurplusNum"]];
        content = [NSString stringWithFormat:@"%@（剩余%@次）\n",serviceName,count];
        [buf appendString:content];
    }
    return buf;
}

- (void)initCarMsgArray {
    NSString *activeDate = [ToolKit getStringVlaue:_info[@"ActiveDate"]];
    NSString *memberNum = [ToolKit getStringVlaue:_info[@"MemberNum"]];
    NSString *realCardId = [ToolKit getStringVlaue:_info[@"RealCardId"]];
    NSString *memberName = [ToolKit getStringVlaue:_info[@"MemberName"]];
    NSString *memberPhone = [ToolKit getStringVlaue:_info[@"MemberPhone"]];
    cardMsgArray = [[NSMutableArray alloc] initWithObjects:@{@"卡类型":@"套餐卡"},@{@"卡内剩余":[self getProjectMsg]},@{@"客户编号":memberNum},@{@"卡号":realCardId},@{@"姓名":memberName},@{@"会员手机":memberPhone},@{@"生效日期":activeDate}, nil];
}

- (void)initData {
    okServiceArray = [[NSMutableArray alloc] init];
    cardRecordArray = [[NSMutableArray alloc] init];
    [self getProject];
    [self initCarMsgArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initData];
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
    self.title = @"卡信息";
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

- (IBAction)serviceClick:(id)sender {
    click = 0;
    _cardMsgView.hidden = YES;
    _serviceView.hidden = NO;
    [_serviceTableView reloadData];
    [_serviceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_serviceBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
    [_cardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cardBtn setBackgroundColor:UIColorFromRGB(0xEDEDED)];
}

- (IBAction)cardClick:(id)sender {
    click = 1;
    self.title = @"卡信息";
    _cardMsgView.hidden = NO;
    _serviceView.hidden = YES;
    [_cardMsgTableView reloadData];
    [_cardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cardBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
    [_serviceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_serviceBtn setBackgroundColor:UIColorFromRGB(0xEDEDED)];
}

- (IBAction)cardMsgClick:(id)sender {
    subClick = 0;
    if (cardMsgArray.count == 0) {
        [_cardMsgTableView showEmpty];
    }else {
        [_cardMsgTableView hiddenEmpty];
    }
    [_cardMsgTableView reloadData];
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    _lineView.frame = CGRectMake(_cardMsgBtn.frame.origin.x, _lineView.frame.origin.y, _lineView.frame.size.width, _lineView.frame.size.height);
    [UIView commitAnimations];
    [_cardMsgBtn setTitleColor:UIColorFromRGB(0x2878d2) forState:UIControlStateNormal];
    [_cardRecordBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
}

- (IBAction)cardRecordClick:(id)sender {
    subClick = 1;
    [_cardMsgTableView reloadData];
    if (cardRecordArray.count == 0) {
        [self getPackageCardUsedRecord];
    }
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    _lineView.frame = CGRectMake(_cardRecordBtn.frame.origin.x, _lineView.frame.origin.y, _lineView.frame.size.width, _lineView.frame.size.height);
    [UIView commitAnimations];
    [_cardMsgBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_cardRecordBtn setTitleColor:UIColorFromRGB(0x2878d2) forState:UIControlStateNormal];
}

- (IBAction)commitClick:(id)sender {
    projectArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < okServiceArray.count; i++) {
        TCardServiceSubView *tssv = [okServiceArray objectAtIndex:i];
        if (tssv.clickBol) {
            NSLog(@"click:   %ld",tssv.tag);
            NSInteger tag = tssv.tag;
            NSArray *array = _info[@"PackageCardProjects"];
            NSDictionary *dict = array[tag];
            NSString *projectId = dict[@"ProjectId"];
            NSDictionary *info = @{@"ProjectId":projectId};
            [projectArray addObject:info];
        }
    }
    [self addPackageCardPos];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (click == 0) {
        return 2;
    }else {
        if (subClick == 0) {
            return cardMsgArray.count;
        }else {
            return cardRecordArray.count;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *serviceCell = @"serviceCell";
    static NSString *emptyCell = @"emptyCell";
    static NSString *carMsgCell = @"carMsgCell";
    static NSString *carRecordCell = @"carRecordCell";
    UINib *nib = nil;
    UITableViewCell *cell = nil;
    if (click == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:emptyCell];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emptyCell];
                cell.backgroundColor = [UIColor clearColor];
            }
        }else {
            height = 0.f;
            [okServiceArray removeAllObjects];
            cell = [tableView dequeueReusableCellWithIdentifier:serviceCell];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serviceCell];
                cell.backgroundColor = [UIColor whiteColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            _serviceSubHeadView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(_serviceSubHeadView.frame));
            [cell.contentView addSubview:_serviceSubHeadView];
            _cardNumL.text = _info[@"RealCardId"];
            _cardStopL.text = [_info[@"CloseDate"] substringWithRange:NSMakeRange(0, 10)];
            height += CGRectGetHeight(_serviceSubHeadView.frame);
            lineV = [[UIView alloc] initWithFrame:CGRectMake(11, CGRectGetHeight(_serviceSubHeadView.frame), CGRectGetWidth(tableView.frame) - 11 * 2, 1)];
            lineV.backgroundColor = UIColorFromRGB(0xD9D9D9);
            [cell.contentView addSubview:lineV];
            height += CGRectGetHeight(lineV.frame);
            for (int i = 0; i < serviceArray.count; i++) {
                NSDictionary *dict = serviceArray[i];
                NSString *key = dict[@"num"];
                int ob = [key intValue];
                int num = -999999;
                NSString *projectNum = dict[@"ProjectNum"];
                if (![projectNum isKindOfClass:[NSNull class]]) {
                    num = [projectNum intValue];
                }
                TCardServiceSubView *tssv = [[[NSBundle mainBundle] loadNibNamed:@"TCardServiceSubView" owner:self options:nil] lastObject];
                tssv.tag = i;
                tssv.frame = CGRectMake(0, height, CGRectGetWidth(tableView.frame), CGRectGetHeight(tssv.frame));
                tssv.serviceL.text = dict[@"content"];
                if (ob == 0 && num != 0 && num != -999999) {
                    tssv.userInteractionEnabled = NO;
                    tssv.imgV.hidden = YES;
                    tssv.lineV.hidden = NO;
                }else {
                    tssv.userInteractionEnabled = YES;
                    tssv.imgV.hidden = NO;
                    tssv.lineV.hidden = YES;
                }
                [cell.contentView addSubview:tssv];
                [okServiceArray addObject:tssv];
                height += CGRectGetHeight(tssv.frame);
            }
            _commitView.frame = CGRectMake(0, height, CGRectGetWidth(tableView.frame), CGRectGetHeight(_commitView.frame));
            [cell.contentView addSubview:_commitView];
            height += CGRectGetHeight(_commitView.frame);
        }
    }else {
        if (subClick == 0) {
            nib = [UINib nibWithNibName:@"CardMsgTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:carMsgCell];
            cell = (CardMsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:carMsgCell];
            NSDictionary *dict = cardMsgArray[indexPath.row];
            NSString *key = dict.allKeys[0];
            ((CardMsgTableViewCell *)cell).titleL.text = key;
            ((CardMsgTableViewCell *)cell).contentL.text = dict[key];
            if (indexPath.row == 1) {
                ((CardMsgTableViewCell *)cell).contentL.font = [UIFont systemFontOfSize:12];
                ((CardMsgTableViewCell *)cell).contentL.text = dict[key];
                ((CardMsgTableViewCell *)cell).contentL.numberOfLines = serviceArray.count;
            }
        }else {
            nib = [UINib nibWithNibName:@"CardRecordTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:carRecordCell];
            cell = (CardRecordTableViewCell *)[tableView dequeueReusableCellWithIdentifier:carRecordCell];
            NSDictionary *dict = cardRecordArray[indexPath.row];
            ((CardRecordTableViewCell *)cell).storeL.text = [ToolKit getStringVlaue:dict[@"StoreName"]];
            ((CardRecordTableViewCell *)cell).carNumL.text = [NSString stringWithFormat:@"客户车辆：%@",[ToolKit getStringVlaue:dict[@"LicenNum"]]];
            ((CardRecordTableViewCell *)cell).nameL.text = [NSString stringWithFormat:@"-%@ x%@",[ToolKit getStringVlaue:dict[@"ProjectName"]],[ToolKit getStringVlaue:dict[@"UsedNum"]]];
            ((CardRecordTableViewCell *)cell).dataL.text = [[ToolKit getStringVlaue:dict[@"UsedTime"]] substringWithRange:NSMakeRange(0, 10)];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (click == 0) {
        if (indexPath.row == 0) {
            return 11;
        }else {
            return height;
        }
    }else {
        if (subClick == 0) {
            return 50;
        }else {
            return 66;
        }
    }
}

#pragma mark - request
- (void)getPackageCardUsedRecord {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *cardId = [ToolKit getStringVlaue:_info[@"CardId"]];
    NSDictionary *parameters = @{@"CardId":cardId,@"UserToken":userDict,@"CompanyId":companyId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetPackageCardUsedRecord];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            id record = responseObject[@"Result"];
            if ([record isKindOfClass:[NSDictionary class]]) {
                [ZAActivityBar dismiss];
                [cardRecordArray addObjectsFromArray:responseObject[@"Result"][@"PackageCardUsedRecords"]];
                [_cardMsgTableView reloadData];
                if (cardRecordArray.count == 0) {
                    [_cardMsgTableView showEmpty];
                }else {
                    [_cardMsgTableView hiddenEmpty];
                }
            }else {
                [ZAActivityBar showErrorWithStatus:@"没有相关记录"];
            }
            NSLog(@"JSON: %@", responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)addPackageCardPos {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *cardId = [ToolKit getStringVlaue:_info[@"CardId"]];
    NSString *status = @"0";    //Status:0保存 1入账
    NSDictionary *parameters = @{@"CardId":cardId,@"UserToken":userDict,@"UserId":userId,@"CardItems":projectArray,@"status":status};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddPackageCardPos];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            if (_refreshData) {
                _refreshData();
            }
            [self.navigationController popViewControllerAnimated:YES];
            [ZAActivityBar showSuccessWithStatus:@"刷卡成功"];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
