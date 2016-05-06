//
//  CarWashBillingViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/9/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "CarWashBillingViewController.h"
#import "BillingUserView.h"
#import "EmptyView.h"
#import "BillingBottomView.h"
#import "ZAActivityBar.h"
#import "ToolKit.h"
#import "WashView.h"
#import "WashListViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "SearchUserViewController.h"
#import "AddWashView.h"
#import "ScanningRecognizeViewController.h"
#import "SharedBlueToothManager.h"
#import "PrinterSettingViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface CarWashBillingViewController () {
    BillingUserView *userView;
    WashView *washView;
    BillingBottomView *bbView;
    NSMutableArray *viewArray;
    float serverHeight;
    float userHeight;
    float bottomeTop;
    UIView *contentV;
    NSMutableArray *itemArray;
    int billingNum;
    float billingAccount;
    NSMutableArray *itemContentArray;
    NSDictionary *washInfo;
    AddWashView *washService;
    NSDictionary *printInfo;
    UIAlertView *printAlerView;
    UIAlertView *printingAlerView;
}

@end

@implementation CarWashBillingViewController

- (void)initViews {
    WS(ws);
    userView = [[[NSBundle mainBundle] loadNibNamed:@"BillingUserView" owner:self options:nil] lastObject];
    __weak BillingUserView *weakUser = userView;
    __block TPKeyboardAvoidingScrollView *weakScrollView = _scrollView;
    userView.editLicen = ^(void) {
        ScanningRecognizeViewController *srvc = [[ScanningRecognizeViewController alloc] init];
        srvc.passCarLince = ^(NSString *lince) {
            NSString *endLince = [lince substringFromIndex:2];
            weakUser.licenNumTextField.text = endLince;
            [weakUser getCarInfo:endLince];
        };
        [ws.navigationController pushViewController:srvc animated:YES];
    };
    userView.editBegin = ^(void) {
        weakScrollView.scrollEnabled = NO;
    };
    userView.endBegin = ^(void) {
        weakScrollView.scrollEnabled = YES;
    };
    userView.passValue = ^(NSDictionary *value) {
        _carInfo = value;
        NSString *carNum = value[@"CarNumber"];
        NSString *lince = [carNum stringByReplacingOccurrencesOfString:@" " withString:@""];
        lince = [lince stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *headerLince = @"";
        NSString *endLince = @"";
        if (lince.length >= 2) {
            headerLince = [lince substringToIndex:2];
        }
        if (lince.length >= 3) {
            endLince = [lince substringFromIndex:2];
        }
        weakUser.licenNumTextField.text = endLince;
        weakUser.stTextField.text = headerLince;
        [UIView animateWithDuration:0.5 animations:^{
            weakUser.constraintHeight.constant = 0;
            [weakUser.linceView layoutIfNeeded];
        }completion:^(BOOL finished) {
            weakScrollView.scrollEnabled = YES;
        }];
    };
    if (_carInfo) {
        NSString *lince = _carInfo[@"CarNumber"];
        lince = [lince stringByReplacingOccurrencesOfString:@" " withString:@""];
        lince = [lince stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *headerLince = @"";
        NSString *endLince = @"";
        if (lince.length >= 2) {
            headerLince = [lince substringToIndex:2];
        }
        if (lince.length >= 3) {
            endLince = [lince substringFromIndex:2];
        }
        weakUser.licenNumTextField.text = endLince;
        weakUser.stTextField.text = headerLince;
        userView.telNumberTextField.text = _carInfo[@"TelNumber"];
        userView.telPersonTextField.text = _carInfo[@"MemberName"];
    }
    washView = [[[NSBundle mainBundle] loadNibNamed:@"WashView" owner:self options:nil] lastObject];
    serverHeight = CGRectGetHeight(washView.frame);
    userHeight = CGRectGetHeight(userView.frame);
    washView.addWash = ^(void) {
        WashListViewController *slvc = [[WashListViewController alloc] initWithNibName:@"WashListViewController" bundle:nil];
        slvc.washInfo = washInfo;
        slvc.passService = ^(NSDictionary *dict) {
            washInfo = dict;
            [ws addServiceContent];
        };
        [ws.navigationController pushViewController:slvc animated:YES];
    };
    __block NSDictionary *weakWashInfo = washInfo;
    bbView = [[[NSBundle mainBundle] loadNibNamed:@"BillingBottomView" owner:self options:nil] lastObject];
    bbView.addClick = ^(void) {
        if (weakWashInfo) {
            [ZAActivityBar showErrorWithStatus:@"请选择洗车服务"];
        }
        if (weakUser.licenNumTextField.text.length > 0 && weakUser.telPersonTextField.text.length > 0 && weakUser.telNumberTextField.text.length == 11) {
            NSString *btnTitle = bbView.saveBtn.titleLabel.text;
            if ([btnTitle isEqualToString:@"保存"]) {
                [ws addWashCar];
            }else {
                [self printData];
            }
        }else {
            [weakUser.licenNumTextField resignFirstResponder];
            [weakUser.telPersonTextField resignFirstResponder];
            [weakUser.telNumberTextField resignFirstResponder];
            if (weakUser.licenNumTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请填写车牌号"];
            }
            if (weakUser.stTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请选择车牌"];
            }
            if (weakUser.telPersonTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请填写联系人"];
            }
            if (weakUser.telNumberTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请填写联系号码"];
            }
            if (weakUser.telNumberTextField.text.length > 11 || weakUser.telNumberTextField.text.length < 11) {
                [ZAActivityBar showErrorWithStatus:@"联系号码请正确填定手机号"];
            }
        }
    };
    viewArray = [[NSMutableArray alloc] initWithObjects:userView,washView, nil];
}

- (void)account:(AddWashView *)addWashView {
    float price = [addWashView.priceTextField.text floatValue];
    float workTime = [addWashView.workTimeTextField.text floatValue];
    billingAccount = (workTime * price);
    if (washInfo) {
        billingNum = 1;
    }else {
        billingNum = 0;
    }
    bbView.accountL.text = [NSString stringWithFormat:@"%.2f",billingNum * billingAccount];
    bbView.numL.text = [NSString stringWithFormat:@"%d",billingNum];
}

- (void)addServiceContent {
    WS(ws);
    for (UIView *view in [washView.contentV subviews]) {
        [view removeFromSuperview];
    }
    AddWashView *lastV = nil;
    if (washInfo) {
        [washView.selectedBtn setTitle:@"变更" forState:UIControlStateNormal];
        washService = [[[NSBundle mainBundle] loadNibNamed:@"AddWashView" owner:self options:nil] lastObject];
        __weak AddWashView *weakAsv = washService;
        washService.serviceNameL.text = [ToolKit getStringVlaue:washInfo[@"StyleName"]];
        washService.serviceCodeL.text = [NSString stringWithFormat:@"项目编码：%@",[ToolKit getStringVlaue:washInfo[@"projectCode"]]];
        float acount = [[ToolKit getStringVlaue:washInfo[@"CostMoney"]]floatValue];
        washService.priceTextField.text = [NSString stringWithFormat:@"%.2f",acount];
        washService.workTimeTextField.text = @"1";
        [self account:washService];
        washService.changePrice = ^(NSInteger tag) {
            [ws account:weakAsv];
        };
        washService.changeWorkTime = ^(NSInteger tag) {
            [ws account:weakAsv];
        };
        washService.delContent = ^(UIView *v) {
            washInfo = nil;
            [ws addServiceContent];
            [ws account:weakAsv];
        };
        [washView.contentV addSubview:washService];
        [washService mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(washView.contentV.left);
            make.right.equalTo(washView.contentV.right);
            make.height.mas_equalTo(CGRectGetHeight(washService.frame));
        }];
        if (lastV) {
            [washService mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastV.bottom);
            }];
        }else {
            [washService mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(washView.contentV.top);
            }];
        }
        lastV = washService;
        lastV.bottomLineV.hidden = YES;
        [washView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(washView.contentV.frame.origin.y + 5 + CGRectGetHeight(lastV.frame));
        }];
//        [bbView updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(washView.bottom).offset(86);
//        }];
    }else {
        [washView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(serverHeight);
        }];
        [self addEmptyView:washView.contentV];
        [bbView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(washView.bottom).offset(bottomeTop - 5);
        }];
    }
}

#pragma mark - private

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    if (printAlerView) {
        [printAlerView show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"洗车开单";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)addEmptyView:(UIView *)view {
    EmptyView *emptyView = [[[NSBundle mainBundle] loadNibNamed:@"EmptyView" owner:self options:nil] lastObject];
    emptyView.layer.borderWidth = 1;
    [view addSubview:emptyView];
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.left.equalTo(view);
        make.right.equalTo(view);
    }];
}

- (void)backAction {
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃订单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
    alerView.tag = 99;
    alerView.delegate = self;
    [alerView show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    // Do any additional setup after loading the view.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    // Do an
    [self initHeader];
    [self initViews];
    _scrollView = TPKeyboardAvoidingScrollView.new;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    //    _scrollView.backgroundColor = UIColorFromRGB(0xF3F3F3);
    _scrollView.backgroundColor = UIColorFromRGB(0xF3F3F3);
    [self.view addSubview:_scrollView];
    UIEdgeInsets scrollviewPadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(ws.view).with.insets(scrollviewPadding);
    }];
    contentV = UIView.new;
    contentV.backgroundColor = [UIColor clearColor];
    __weak BillingUserView *weakUser = userView;
    __block TPKeyboardAvoidingScrollView *weakScrollView = _scrollView;
    _scrollView.touchEvent = ^(void) {
        [UIView animateWithDuration:0.3 animations:^{
            weakUser.constraintHeight.constant = 0;
            [weakUser.linceView layoutIfNeeded];
        }completion:^(BOOL finished) {
            weakScrollView.scrollEnabled = YES;
        }];
    };
    [_scrollView addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    UIView *lastV = nil;
    int padding = 10;
    int bottomPadding = 13;
    int topPadding = 15;
    for (int i = 0; i < viewArray.count; i++) {
        UIView *subv = [viewArray objectAtIndex:i];
        subv.layer.cornerRadius = 8;
        subv.layer.borderWidth = 1;
        subv.layer.borderColor = [UIColorFromRGB(0xD9D9D9) CGColor];
        switch (i) {
            case 1:
            {
                [self addEmptyView:((WashView *)subv).contentV];
            }
                break;
            default:
                break;
        }
        
        [contentV addSubview:subv];
        
        [subv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentV.left).offset(padding);
            make.right.equalTo(contentV.right).offset(-padding);
            make.height.mas_equalTo(CGRectGetHeight(subv.frame));
            if (lastV) {
                make.top.equalTo(lastV.bottom).offset(bottomPadding);
            }else {
                make.top.equalTo(contentV).offset(topPadding);
            }
        }];
        lastV = subv;
    }
    [contentV addSubview:bbView];
    NSLog(@"ww:   %f-%f-%f",userHeight ,serverHeight ,CGRectGetHeight(bbView.frame));
    bottomeTop = (CGRectGetHeight(ws.view.frame) - 64 - userHeight - serverHeight - CGRectGetHeight(bbView.frame) -2*10 - 6);
    if (bottomeTop < 10) {
        bottomeTop = 10;
    }else {
        [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(CGRectGetHeight(ws.view.frame) - 64);
        }];
    }
    [bbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastV.bottom).offset(bottomeTop);
        make.left.equalTo(contentV.left);
        make.right.equalTo(contentV.right);
        make.bottom.equalTo(contentV.bottom);
        make.height.mas_equalTo(CGRectGetHeight(bbView.frame));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - request
- (void)addWashCar {
    bbView.saveBtn.enabled = NO;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *memberId = nil;
    if (_carInfo) {
        memberId = _carInfo[@"MemberId"];
    }
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *headerLicenNum = userView.stTextField.text;
    NSString *endLicenNum = userView.licenNumTextField.text;
    NSString *licenNum = @"";
    if (![headerLicenNum isEqualToString:@"军牌"]) {
        licenNum = [NSString stringWithFormat:@"%@-%@",headerLicenNum,endLicenNum];
    }else {
        licenNum = endLicenNum;
    }
    NSDictionary *parameters = @{@"UserToken":userDict,@"LicenNum":licenNum,@"TelPerson":userView.telPersonTextField.text,@"TelNumber":userView.telNumberTextField.text,@"UserId":userId};
    NSMutableDictionary *mutP = [parameters mutableCopy];
    if (washInfo) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:washInfo[@"ID"],@"ProjectId",washService.workTimeTextField.text,@"WorkTime",washService.priceTextField.text,@"WorkTimePrice", nil];
        NSArray *washArray = [[NSArray alloc] initWithObjects:info, nil];
        [mutP setObject:washArray forKey:@"ProjectItems"];
    }
    if (memberId) {
        [mutP setObject:memberId forKey:@"memberId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddWashCar];
    [manager POST:url parameters:mutP success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
//            [ZAActivityBar showSuccessWithStatus:@"开单成功"];
            [ZAActivityBar dismiss];
            [bbView.saveBtn setTitle:@"打印" forState:UIControlStateNormal];
            printInfo = responseObject[@"Result"];
            printAlerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"开单成功， 是否打印小票？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"打印", nil];
            printAlerView.tag = 100;
            printAlerView.delegate = self;
            [printAlerView show];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)printData {
    NSDictionary *info = [[SharedBlueToothManager sharedBlueToothManager] printWashNotesWithInfoDicts:printInfo];
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
                bbView.saveBtn.enabled = YES;
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
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            bbView.saveBtn.enabled = YES;
            [[SharedBlueToothManager sharedBlueToothManager] disconnectPrinter];
        }
    }else {
        bbView.saveBtn.enabled = YES;
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
