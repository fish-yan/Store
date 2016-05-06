//
//  OrderDetailViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/5.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "UserTableViewCell.h"
#import "SServiceTableViewCell.h"
#import "SItemTableViewCell.h"
#import "SharedBlueToothManager.h"
#import "PrinterSettingViewController.h"

@interface OrderDetailViewController () {
    NSDictionary *infoDict;
    NSMutableArray *pickArray;
    NSDictionary *printInfo;
    UIAlertView *printAlerView;
    UIAlertView *printingAlerView;
    UIButton *rightBtn;
}

@end

@implementation OrderDetailViewController

- (void)initData {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self getOrderInfo];
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
    self.title = @"订单详情";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    if (![_orderName isEqualToString:@"维修单"] || ![_orderName isEqualToString:@"增项单"]) {
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(250, 0, 44, 44)];
        [rightBtn addTarget:self action:@selector(printAction) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"打印" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)printAction {
    rightBtn.enabled = NO;
    printAlerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否打印小票？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打印", nil];
    printAlerView.tag = 100;
    [printAlerView show];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getPickArray {
    pickArray = [[NSMutableArray alloc] init];
    id carCheck = infoDict[@"carCheck"];
    if (![carCheck isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *carrDict = [[NSMutableDictionary alloc] initWithDictionary:infoDict[@"carCheck"]];
        for (int i = 0; i < carrDict.allKeys.count; i++) {
            NSString *key = carrDict.allKeys[i];
            NSString *value = carrDict[key];
            if (![value isKindOfClass:[NSNull class]]) {
                if (!([value isEqualToString:@"False"] || [value isEqualToString:@"否"] || [value isEqualToString:@"NO"])) {
                    if (value.length > 0) {
                        NSString *content = [NSString stringWithFormat:@"%@：%@",key,value];
                        [pickArray addObject:content];
                    }
                }
            }
        }
    }
    id carDetcList = infoDict[@"carDetcList"];
    if (![carDetcList isKindOfClass:[NSNull class]]) {
        NSMutableDictionary *ctarrDict = [[NSMutableDictionary alloc] initWithDictionary:infoDict[@"carDetcList"]];
        for (int i = 0; i < ctarrDict.allKeys.count; i++) {
            NSString *key = ctarrDict.allKeys[i];
            NSString *value = ctarrDict[key];
            if (![value isKindOfClass:[NSNull class]]) {
                if (!([value isEqualToString:@"False"] || [value isEqualToString:@"否"] || [value isEqualToString:@"NO"])) {
                    if (value.length > 0) {
                        NSString *content = [NSString stringWithFormat:@"%@：%@",key,value];
                        [pickArray addObject:content];
                    }
                }
            }
        }
    }
}

#pragma mark - request
- (void)getOrderInfo {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"Id":_orderId,@"OrderName":_orderName};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetSaleInfo];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            infoDict = [[NSDictionary alloc] initWithDictionary:responseObject[@"Result"]];
//            if ([_orderName isEqualToString:@"项目结算单"]) {
//                printInfo = responseObject[@"Result"];
//            }else {
//                printInfo = responseObject[@"Result"][@"PaintInfo"];
//            }
            printInfo = responseObject[@"Result"][@"PaintInfo"];
            [self getPickArray];
            self.tableView.tableHeaderView = _headView;
            int status = [infoDict[@"Status"] intValue];
            _orderStateL.text = status?@"已结算":@"未结算";
            _numL.text = [NSString stringWithFormat:@"数量总计   %@",infoDict[@"TotalNum"]];
            _priceL.text = [NSString stringWithFormat:@"合计   ￥%@",infoDict[@"TotalPay"]];
            [_tableView reloadData];
            NSLog(@"JSON: %@", responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (SItemTableViewCell *)getItemCell:(NSIndexPath *)indexPath {
    static NSString *itemCell = @"itemCell";
    NSArray *darray = infoDict[@"SaleProducts"];
    UINib *nib = [UINib nibWithNibName:@"SItemTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:itemCell];
    SItemTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:itemCell];
    cell.lsBtn.hidden = YES;
    cell.kcBtn.hidden = YES;
    cell.kctL.hidden = YES;
    cell.unitL.hidden = YES;
    cell.unitTL.hidden = YES;
    cell.numL.hidden = NO;
    cell.numTL.hidden = NO;
    cell.itemNameL.text = darray[indexPath.row][@"ProductName"];
    cell.itemGgL.text = darray[indexPath.row][@"ProductSpecification"];
    cell.itemPpL.text = darray[indexPath.row][@"Brand"];
    cell.itemCodeL.text = darray[indexPath.row][@"ProductCode"];
    cell.numL.text = [NSString stringWithFormat:@"%@",darray[indexPath.row][@"Amount"]];
    cell.acountL.text = [NSString stringWithFormat:@"￥%@",darray[indexPath.row][@"TotalPay"]];
    return cell;
}

- (UITableViewCell *)getPickCell:(NSIndexPath *)indexPath {
    static NSString *pickCell = @"pickCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:pickCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:pickCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = pickArray[indexPath.row];
    cell.textLabel.textColor = UIColorFromRGB(0x5D5D5D);
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 1)];
    lineV.backgroundColor = UIColorFromRGB(0xD9D9D9);
    [cell.contentView addSubview:lineV];
    return cell;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1) {
        NSArray *jarray = infoDict[@"SaleProjects"];
        NSArray *darray = infoDict[@"SaleProducts"];
        if (darray.count > 0) {
            return darray.count;
        }else if (jarray.count > 0) {
            return jarray.count;
        }else {
            return pickArray.count;
        }
    }else if (section == 2) {
        NSArray *darray = infoDict[@"SaleProducts"];
        NSArray *jarray = infoDict[@"SaleProjects"];
        if (darray.count > 0) {
            return jarray.count;
        }else {
            return pickArray.count;
        }
    }else {
        return pickArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int i = 0;
    if (infoDict) {
        i = 1;
        NSArray *jarray = infoDict[@"SaleProjects"];
        NSArray *darray = infoDict[@"SaleProducts"];
        if (jarray.count > 0 ) {
            i++;
        }
        if (darray.count >0) {
            i++;
        }
        if (pickArray.count > 0) {
            i++;
        }
    }
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *userCell = @"userCell";
    static NSString *serviceCell = @"serviceCell";
    NSArray *jarray = infoDict[@"SaleProjects"];
    NSArray *darray = infoDict[@"SaleProducts"];
    UINib *nib = nil;
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        nib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:userCell];
        cell = [tableView dequeueReusableCellWithIdentifier:userCell];
        ((UserTableViewCell *)cell).cpcL.text = infoDict[@"LicenNum"];
        ((UserTableViewCell *)cell).lxcL.text = infoDict[@"MemberName"];
        ((UserTableViewCell *)cell).lxhmcL.text = infoDict[@"TelNumber"];
    }else if (indexPath.section == 1){
        if (darray.count > 0) {
            cell = [self getItemCell:indexPath];
        }else if (jarray.count > 0){
            nib = [UINib nibWithNibName:@"SServiceTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:serviceCell];
            cell = [tableView dequeueReusableCellWithIdentifier:serviceCell];
            ((SServiceTableViewCell *)cell).serviceCountL.hidden = YES;
            if (jarray.count == (indexPath.row + 1) && darray.count != 0) {
                ((SServiceTableViewCell *)cell).lineV.hidden = YES;
            }
            ((SServiceTableViewCell *)cell).serviceNameL.text = jarray[indexPath.row][@"ProjectName"];
            ((SServiceTableViewCell *)cell).serviceNL.text = [NSString stringWithFormat:@"项目编码 %@",jarray[indexPath.row][@"ProjectCode"]];
            NSString *price = [NSString stringWithFormat:@"￥%@",jarray[indexPath.row][@"TotalPay"]];
            [((SServiceTableViewCell *)cell).serviceBtn setTitle:price forState:UIControlStateNormal];
        }else {
            cell = [self getPickCell:indexPath];
        }
    }else if (indexPath.section == 2){
        if (darray.count > 0){
            nib = [UINib nibWithNibName:@"SServiceTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:serviceCell];
            cell = [tableView dequeueReusableCellWithIdentifier:serviceCell];
            ((SServiceTableViewCell *)cell).serviceCountL.hidden = YES;
            if (jarray.count == (indexPath.row + 1) && darray.count != 0) {
                ((SServiceTableViewCell *)cell).lineV.hidden = YES;
            }
            ((SServiceTableViewCell *)cell).serviceNameL.text = jarray[indexPath.row][@"ProjectName"];
            ((SServiceTableViewCell *)cell).serviceNL.text = [NSString stringWithFormat:@"项目编码 %@",jarray[indexPath.row][@"ProjectCode"]];
            NSString *price = [NSString stringWithFormat:@"￥%@",jarray[indexPath.row][@"TotalPay"]];
            [((SServiceTableViewCell *)cell).serviceBtn setTitle:price forState:UIControlStateNormal];
        }else {
            cell = [self getPickCell:indexPath];
        }
    }else {
        cell = [self getPickCell:indexPath];
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
    NSArray *darray = infoDict[@"SaleProducts"];
    NSArray *jarray = infoDict[@"SaleProjects"];
    if (section == 0) {
        label.text = @"客户基本信息";
    }else if (section == 1){
        if (darray.count > 0) {
            label.text = @"项目配件";
        }else if (jarray.count > 0) {
            label.text = @"项目服务";
        }else {
            label.text = @"车辆检查";
        }
    }else if (section == 2){
        if (darray.count > 0) {
            label.text = @"项目服务";
        }else {
            label.text = @"车辆检查";
        }
    }else {
        label.text = @"车辆检查";
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *darray = infoDict[@"SaleProducts"];
    NSArray *jarray = infoDict[@"SaleProjects"];
    if (indexPath.section == 0) {
        return 90;
    }else if (indexPath.section == 1){
        if (darray.count > 0) {
            return 152;
        }else if (jarray.count > 0){
            return 71;
        }else {
            return 30;
        }
    }else if (indexPath.section == 2){
        if (darray.count > 0) {
            return 71;
        }else {
            return 30;
        }
    }else {
        return 30;
    }
}

- (void)printData {
//    NSDictionary *info = [[SharedBlueToothManager sharedBlueToothManager] printSaleProductNotesWithInfoDicts:printInfo];
    NSDictionary *info = nil;
    if ([_orderName isEqualToString:@"项目结算单"]) {
        info = [[SharedBlueToothManager sharedBlueToothManager] printServiceNotesWithInfoDicts:printInfo];
    }else if ([_orderName isEqualToString:@"商品零售单"]) {
        info = [[SharedBlueToothManager sharedBlueToothManager] printSaleProductNotesWithInfoDicts:printInfo];
    }else if ([_orderName isEqualToString:@"洗车单"]) {
        info = [[SharedBlueToothManager sharedBlueToothManager] printWashNotesWithInfoDicts:printInfo];
    }
    NSString *code = info[@"Code"];
    if ([code isEqualToString:@"1"]) {
        if ([SharedBlueToothManager sharedBlueToothManager].isBluetoothOpened) {
            UIStoryboard *printStoryBoard = [UIStoryboard storyboardWithName:@"PrinterSettingViewController" bundle:nil];
            PrinterSettingViewController *vc = [printStoryBoard instantiateViewControllerWithIdentifier:@"printerID"];
            [self.navigationController pushViewController:vc animated:YES];
        }else {
            UIAlertView *setPrintView = [[UIAlertView alloc] initWithTitle:nil message:@"打开蓝牙来允许车赢家导购连接到配件" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:@"好", nil];
            setPrintView.tag = 102;
            [setPrintView show];
        }
    }else {
        if ([SharedBlueToothManager sharedBlueToothManager].isBluetoothOpened) {
            printingAlerView = [[UIAlertView alloc] initWithTitle:@"开始连接打印机,准备打印！" message:@"如打印机没反应，可能是其他设备正在执行打印任务，请耐心等待" delegate:self cancelButtonTitle:@"取消打印" otherButtonTitles:nil, nil];
            printingAlerView.tag = 101;
            printingAlerView.delegate = self;
            [printingAlerView show];
            [SharedBlueToothManager sharedBlueToothManager].startConnect = ^(void) {
                
            };
            [SharedBlueToothManager sharedBlueToothManager].didConnect = ^(void) {
                rightBtn.enabled = YES;
                [printingAlerView dismissWithClickedButtonIndex:printingAlerView.cancelButtonIndex animated:YES];
                [self.navigationController popViewControllerAnimated:YES];
            };
        }else {
            UIAlertView *setPrintView = [[UIAlertView alloc] initWithTitle:nil message:@"打开蓝牙来允许车赢家导购连接到配件" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:@"好", nil];
            setPrintView.tag = 102;
            [setPrintView show];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 99) {
        if (buttonIndex == 1) {
            //        [userView reset];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag == 100){
        if (buttonIndex == 1) {
            [self printData];
        }
    }else if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            rightBtn.enabled = YES;
            [[SharedBlueToothManager sharedBlueToothManager] disconnectPrinter];
        }
    }else {
        rightBtn.enabled = YES;
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
