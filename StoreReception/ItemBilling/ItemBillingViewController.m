//
//  ItemBillingViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ItemBillingViewController.h"
#import "BillingUserView.h"
#import "EmptyView.h"
#import "ItemView.h"
#import "BillingBottomView.h"
#import "ZAActivityBar.h"
#import "ItemListViewController.h"
#import "AddItemView.h"
#import "ToolKit.h"
#import <AFNetworking/AFNetworking.h>
#import "SearchUserViewController.h"
#import "SearchItemHistoryPriceViewController.h"
#import "NoticeView.h"
#import "ScanningRecognizeViewController.h"
#import "SharedBlueToothManager.h"
#import "PrinterSettingViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ItemBillingViewController () {
    BillingUserView *userView;
    ItemView *itemView;
    BillingBottomView *bbView;
    NSMutableArray *viewArray;
    float itemHeight;
    float userHeight;
    float bottomeTop;
    UIView *contentV;
    NSMutableArray *itemArray;
    int billingNum;
    float billingAccount;
    NSMutableArray *itemContentArray;
    NSDictionary *carInfo;
    NoticeView *noticeView;
    NSDictionary *printInfo;
    UIAlertView *printAlerView;
    UIAlertView *printingAlerView;
}

@end

@implementation ItemBillingViewController

- (NSMutableDictionary *)checkSameItem:(NSDictionary *)info {
    NSString *itemId = info[@"Id"];
    for (int i = 0; i < itemArray.count; i++) {
        NSString *iid = [ToolKit getStringVlaue:itemArray[i][@"Id"]];
        if ([itemId isEqualToString:iid]) {
            NSMutableDictionary *temp = [itemArray[i] mutableCopy];
            NSString *buyNum = temp[@"BuyNum"];
            int _buyNum = [buyNum intValue];
            buyNum = [NSString stringWithFormat:@"%d",++_buyNum];
            [temp setObject:buyNum forKey:@"BuyNum"];
            [itemArray removeObjectAtIndex:i];
            [itemArray insertObject:temp atIndex:i];
            return nil;
        }
    }
    NSMutableDictionary *temp = [info mutableCopy];
    NSString *buyNum = temp[@"BuyNum"];
    if (!buyNum) {
        buyNum = @"1";
    }
    [temp setObject:buyNum forKey:@"BuyNum"];
    return temp;
}

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
        carInfo = value;
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
    itemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
    itemHeight = CGRectGetHeight(itemView.frame);
    userHeight = CGRectGetHeight(userView.frame);
    __block NSMutableArray *weakItemArray = itemArray;
    itemView.addItem = ^(void) {
        ItemListViewController *ilvc = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
        ilvc.fromPage = NORMAL_FROMPAGE;
        ilvc.addArray = weakItemArray;
        ilvc.passItemDict = ^(NSDictionary *dict) {
            NSArray *array = dict.allKeys;
            for (int i = 0; i < array.count; i++) {
                NSString *key = array[i];
                NSDictionary *itemInfo = [dict objectForKey:key];
                NSMutableDictionary *temp = [ws checkSameItem:itemInfo];
                if (temp) {
                    [weakItemArray addObject:temp];
                }
            }
            [ws addItemContent];
            [ws getItemAccount];
        };
        [ws.navigationController pushViewController:ilvc animated:YES];
    };
    noticeView = [[[NSBundle mainBundle] loadNibNamed:@"NoticeView" owner:self options:nil] lastObject];
    bbView = [[[NSBundle mainBundle] loadNibNamed:@"BillingBottomView" owner:self options:nil] lastObject];
    bbView.addClick = ^(void) {
        if (weakItemArray.count == 0) {
            [ZAActivityBar showErrorWithStatus:@"请选择商品"];
        }
        if (weakUser.stTextField.text.length > 0 && weakUser.licenNumTextField.text.length > 0 && weakUser.telPersonTextField.text.length > 0 && weakUser.telNumberTextField.text.length == 11) {
            NSString *btnTitle = bbView.saveBtn.titleLabel.text;
            if ([btnTitle isEqualToString:@"保存"]) {
                [ws addSaleProduct];
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
    viewArray = [[NSMutableArray alloc] initWithObjects:userView,itemView, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)countAccount:(AddItemView *)aiv {
    float price = [aiv.priceTextField.text floatValue];
    float num = [aiv.numL.text floatValue];
    aiv.accountL.text = [NSString stringWithFormat:@"￥%.2f",price * num];
}

- (void)account {
    billingAccount = 0.f;
    billingNum = 0;
    [self getItemAccount];
    if (itemContentArray.count == 0) {
        billingAccount = 0;
        billingNum = 0;
    }
    bbView.accountL.text = [NSString stringWithFormat:@"%.2f",billingAccount];
    bbView.numL.text = [NSString stringWithFormat:@"%d",billingNum];
}

- (void)changeNum:(AddItemView *)weakAiv info:(NSMutableDictionary *)info index:(NSInteger)ctag num:(NSString *)cnum {
    WS(ws);
    weakAiv.numTextField.text = cnum;
    weakAiv.numL.text = cnum;
    [ws countAccount:weakAiv];
    [info setObject:cnum forKey:@"BuyNum"];
    [itemArray removeObjectAtIndex:ctag];
    [itemArray insertObject:info atIndex:ctag];
}

- (void)changePrice:(AddItemView *)weakAiv info:(NSMutableDictionary *)info index:(NSInteger)ctag {
    NSString *price = weakAiv.priceTextField.text;
    [info setObject:price forKey:@"SalePrice"];
    [itemArray removeObjectAtIndex:ctag];
    [itemArray insertObject:info atIndex:ctag];
}

- (void)getItemAccount {
    billingAccount = 0.f;
    billingNum = 0;
    for (int i = 0; i < itemContentArray.count; i++) {
        AddItemView *aiv = itemContentArray[i];
        NSString *acc = [aiv.accountL.text substringWithRange:NSMakeRange(1, aiv.accountL.text.length-1)];
        NSString *num = aiv.numL.text;
        float account = [acc floatValue];
        int inum = [num intValue];
        billingAccount += account;
        billingNum += inum;
    }
    if (itemContentArray.count == 0) {
        billingAccount = 0;
        billingNum = 0;
    }
    bbView.accountL.text = [NSString stringWithFormat:@"￥%.2f",billingAccount];
    bbView.numL.text = [NSString stringWithFormat:@"%d",billingNum];
}

- (void)addItemContent {
    WS(ws);
    for (UIView *view in [itemView.contentV subviews]) {
        [view removeFromSuperview];
    }
    [itemContentArray removeAllObjects];
    AddItemView *lastV = nil;
    __block NSMutableArray *weakItemArray = itemArray;
    if (itemArray.count > 0) {
        for (int i = 0; i < itemArray.count; i++) {
            AddItemView *aiv = [[[NSBundle mainBundle] loadNibNamed:@"AddItemView" owner:self options:nil] lastObject];
            aiv.tag = 1000 + i;
            __weak AddItemView *weakAiv = aiv;
            aiv.itemNameL.text = [ToolKit getStringVlaue:itemArray[i][@"ProductName"]];
            aiv.itemGgL.text = [ToolKit getStringVlaue:itemArray[i][@"SpecModel"]];
            aiv.itemCodeL.text = [ToolKit getStringVlaue:itemArray[i][@"StockNo"]];
            float acount = [[ToolKit getStringVlaue:itemArray[i][@"SalePrice"]]floatValue];
            aiv.priceTextField.text = [NSString stringWithFormat:@"%.2f",acount];
            NSString *sstroeNum = [ToolKit getStringVlaue:itemArray[i][@"StoreNum"]];
            aiv.storeNumL.text = sstroeNum;
            NSString *buyNum = itemArray[i][@"BuyNum"];
            int num = 1;
            if (buyNum) {
                num = [buyNum intValue];
                aiv.numL.text = buyNum;
                aiv.numTextField.text = buyNum;
            }
            int storeNum = [sstroeNum intValue];
            if ((num + 1) <= storeNum) {
                aiv.addBtn.enabled = YES;
            }else {
                aiv.addBtn.enabled = NO;
            }
            [ws countAccount:weakAiv];
            aiv.accountL.text = [NSString stringWithFormat:@"￥%.2f",acount * num];
            aiv.addNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                int storeNum = [info[@"StoreNum"] intValue];
                float num = [info[@"BuyNum"] intValue];
                ++num;
                if (num == storeNum) {
                    weakAiv.addBtn.enabled = NO;
                }else {
                    weakAiv.addBtn.enabled = YES;
                }
                NSString *cnum = [NSString stringWithFormat:@"%.1f",num];
                [self changeNum:weakAiv info:info index:ctag num:cnum];
                [ws account];
            };
            aiv.redNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                float num = [info[@"BuyNum"] floatValue];
                --num;
                weakAiv.addBtn.enabled = YES;
                if (num > 0) {
                    NSString *cnum = [NSString stringWithFormat:@"%.1f",num];
                    [self changeNum:weakAiv info:info index:ctag num:cnum];
                    [ws account];
                }else {
                    [weakItemArray removeObjectAtIndex:ctag];
                    [ws addItemContent];
                    [ws account];
                }
            };
            aiv.changePrice = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                [self changePrice:weakAiv info:info index:ctag];
                [ws countAccount:weakAiv];
                [ws account];
            };
            aiv.changeNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                int storeNum = [info[@"StoreNum"] intValue];
                float num = [weakAiv.numTextField.text floatValue];
                if (num > storeNum) {
                    num = storeNum;
                }
                [self changeNum:weakAiv info:info index:ctag num:[NSString stringWithFormat:@"%.1f",num]];
                [ws account];
            };
            aiv.delContent = ^(UIView *v) {
                NSInteger tag = v.tag - 1000;
                [weakItemArray removeObjectAtIndex:tag];
                [ws addItemContent];
                [ws account];
            };
            aiv.searchHistoryPrice = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                SearchItemHistoryPriceViewController *sipvc = [[SearchItemHistoryPriceViewController alloc] initWithNibName:@"SearchItemHistoryPriceViewController" bundle:nil];
                sipvc.info = info;
                [ws.navigationController pushViewController:sipvc animated:YES];
            };
            [itemView.contentV addSubview:aiv];
            [itemContentArray addObject:aiv];
            [aiv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(itemView.contentV.left);
                make.right.equalTo(itemView.contentV.right);
                make.height.mas_equalTo(CGRectGetHeight(aiv.frame));
            }];
            if (lastV) {
                [aiv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastV.bottom);
                }];
            }else {
                [aiv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(itemView.contentV.top);
                }];
            }
            lastV = aiv;
        }
        lastV.bottomLineV.hidden = YES;
        [itemView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(itemView.contentV.frame.origin.y + 5 + CGRectGetHeight(lastV.frame) * itemArray.count);
        }];
        [noticeView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(itemView.bottom).offset(10);
        }];
    }else {
        [itemView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(itemHeight);
        }];
        [self addEmptyView:itemView.contentV];
        [noticeView updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(itemView.bottom).offset(bottomeTop - 5);
        }];
    }
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    // Do any additional setup after loading the view.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    itemArray = [[NSMutableArray alloc] init];
    itemContentArray = [[NSMutableArray alloc] init];
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
    _scrollView.touchEvent = ^(void) {
        [UIView animateWithDuration:0.3 animations:^{
            weakUser.constraintHeight.constant = 0;
            [weakUser.linceView layoutIfNeeded];
        }completion:^(BOOL finished) {
            _scrollView.scrollEnabled = YES;
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
                [self addEmptyView:((ItemView *)subv).contentV];
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
    [contentV addSubview:noticeView];
    noticeView.layer.cornerRadius = 8;
    noticeView.layer.borderWidth = 1;
    noticeView.layer.borderColor = [UIColorFromRGB(0xD9D9D9) CGColor];
    [noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastV.bottom).offset(topPadding);
        make.left.equalTo(contentV.left).offset(padding);
        make.right.equalTo(contentV.right).offset(-padding);
        make.height.mas_equalTo(CGRectGetHeight(noticeView.frame));
    }];
    [contentV addSubview:bbView];
    NSLog(@"ww:   %f-%f-%f",userHeight ,itemHeight ,CGRectGetHeight(bbView.frame));
    bottomeTop = (CGRectGetHeight(ws.view.frame) - 64 - userHeight - itemHeight - CGRectGetHeight(noticeView.frame) - CGRectGetHeight(bbView.frame) -2*10 - 4);
    if (bottomeTop < 10) {
        bottomeTop = 10;
    }
    [bbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(noticeView.bottom).offset(bottomeTop);
        make.left.equalTo(contentV.left);
        make.right.equalTo(contentV.right);
        make.bottom.equalTo(_scrollView.bottom);
        make.height.mas_equalTo(CGRectGetHeight(bbView.frame));
    }];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bbView.mas_bottom);
    }];
}

- (void)dealloc {
    printAlerView = nil;
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

- (void)backAction {
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃订单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
    alerView.tag = 99;
    alerView.delegate = self;
    [alerView show];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"汽车精品";
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

- (NSMutableArray *)getSaleItems {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < itemArray.count; i++) {
        AddItemView *aiv = itemContentArray[i];
        NSDictionary *info = itemArray[i];
        NSString *stockNo = [ToolKit getStringVlaue:info[@"Id"]];
        NSString *salePrice = aiv.priceTextField.text;
        NSString *amount = [ToolKit getStringVlaue:info[@"BuyNum"]];
        NSDictionary *dict = @{@"StockId":stockNo,@"SalePrice":salePrice,@"Amount":amount};
        [array addObject:dict];
    }
    return array;
}


#pragma mark - request
- (void)addSaleProduct {
    bbView.saveBtn.enabled = NO;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *memberId = nil;
    if (carInfo) {
        memberId = carInfo[@"MemberId"];
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
    NSDictionary *parameters = @{@"UserToken":userDict,@"LicenNum":licenNum,@"TelPerson":userView.telPersonTextField.text,@"TelNumber":userView.telNumberTextField.text,@"SaleItems":[self getSaleItems],@"UserId":userId};
    NSMutableDictionary *mutP = [parameters mutableCopy];
    if (noticeView.textView.text.length > 0) {
        [mutP setObject:noticeView.textView.text forKey:@"Remark"];
    }
    if (memberId) {
        [mutP setObject:memberId forKey:@"memberId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddSaleProduct];
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
    NSDictionary *info = [[SharedBlueToothManager sharedBlueToothManager] printSaleProductNotesWithInfoDicts:printInfo];
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
