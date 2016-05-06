//
//  CCardViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/5.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "CCardViewController.h"
#import "TCardTableViewCell.h"
#import "CardMsgTableViewCell.h"
#import "TCardServiceSubView.h"
#import "CardRecordTableViewCell.h"
#import "ToolKit.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+empty.h"

@interface CCardViewController () {
    UIView *lineV;
    float height;
    int subClick;
    NSMutableArray *cardMsgArray;
    NSMutableArray *cardRecordArray;
}

@end

@implementation CCardViewController

- (void)initData {
    [self initCarMsgArray];
    cardRecordArray = [[NSMutableArray alloc] init];
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

- (void)initCarMsgArray {
    NSString *account = [NSString stringWithFormat:@"￥%@",_info[@"CardBal"]];
    NSString *activeDate = [ToolKit getStringVlaue:_info[@"ActiveDate"]];
    NSString *memberNum = [ToolKit getStringVlaue:_info[@"MemberNum"]];
    NSString *realCardId = [ToolKit getStringVlaue:_info[@"RealCardId"]];
    NSString *memberName = [ToolKit getStringVlaue:_info[@"MemberName"]];
    NSString *memberPhone = [ToolKit getStringVlaue:_info[@"MemberPhone"]];
    cardMsgArray = [[NSMutableArray alloc] initWithObjects:@{@"卡类型":@"储值卡"},@{@"余额":account},@{@"客户编号":memberNum},@{@"卡号":realCardId},@{@"姓名":memberName},@{@"会员手机":memberPhone},@{@"生效日期":activeDate}, nil];
}

- (IBAction)cardMsgClick:(id)sender {
    subClick = 0;
    [_cardMsgTableView reloadData];
    [_cardMsgTableView hiddenEmpty];
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
        [self getValueCardUsedRecord];
    }
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    _lineView.frame = CGRectMake(_cardRecordBtn.frame.origin.x, _lineView.frame.origin.y, _lineView.frame.size.width, _lineView.frame.size.height);
    [UIView commitAnimations];
    [_cardMsgBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_cardRecordBtn setTitleColor:UIColorFromRGB(0x2878d2) forState:UIControlStateNormal];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (subClick == 0) {
        return cardMsgArray.count;
    }else {
        return cardRecordArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *carMsgCell = @"carMsgCell";
    static NSString *carRecordCell = @"carRecordCell";
    UINib *nib = nil;
    UITableViewCell *cell = nil;
    if (subClick == 0) {
        nib = [UINib nibWithNibName:@"CardMsgTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:carMsgCell];
        cell = (CardMsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:carMsgCell];
        NSDictionary *dict = cardMsgArray[indexPath.row];
        NSString *key = dict.allKeys[0];
        ((CardMsgTableViewCell *)cell).titleL.text = key;
        ((CardMsgTableViewCell *)cell).contentL.text = dict[key];
    }else {
        nib = [UINib nibWithNibName:@"CardRecordTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:carRecordCell];
        cell = (CardRecordTableViewCell *)[tableView dequeueReusableCellWithIdentifier:carRecordCell];
        NSDictionary *dict = cardRecordArray[indexPath.row];
        ((CardRecordTableViewCell *)cell).storeL.text = [ToolKit getStringVlaue:dict[@"StoreName"]];
        ((CardRecordTableViewCell *)cell).carNumL.text = [NSString stringWithFormat:@"客户车辆：%@",[ToolKit getStringVlaue:dict[@"LicenNum"]]];
        ((CardRecordTableViewCell *)cell).nameL.text = [NSString stringWithFormat:@"-￥%@",[ToolKit getStringVlaue:dict[@"UsedPrice"]]];
        ((CardRecordTableViewCell *)cell).dataL.text = [[ToolKit getStringVlaue:dict[@"UsedTime"]] substringWithRange:NSMakeRange(0, 10)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (subClick == 0) {
        return 50;
    }else {
        return 66;
    }
}

#pragma mark - request
- (void)getValueCardUsedRecord {
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
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetValueCardUsedRecord];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            id record = responseObject[@"Result"];
            if ([record isKindOfClass:[NSDictionary class]]) {
                [ZAActivityBar dismiss];
                [cardRecordArray addObjectsFromArray:responseObject[@"Result"][@"ValueCardUsedRecords"]];
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

@end
