//
//  NIncreaseViewController.m
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "NIncreaseViewController.h"
#import "IncreaseView.h"
#import "EmptyView.h"
#import "ItemView.h"
#import "ServiceView.h"
#import "BillingBottomView.h"
#import "ZAActivityBar.h"
#import "ItemListViewController.h"
#import "ServicesViewController.h"
#import "AddItemView.h"
#import "AddServiceView.h"
#import "ToolKit.h"
#import <AFNetworking/AFNetworking.h>
#import "SearchUserViewController.h"
#import "SearchItemHistoryPriceViewController.h"
#import "NoticeView.h"
#import "ScanningRecognizeViewController.h"
#import "SharedBlueToothManager.h"
#import "PrinterSettingViewController.h"
#import "SearchPickUpViewController.h"
#import "CarCheckViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface NIncreaseViewController () {
    IncreaseView *increaseView;
    ItemView *itemView;
    ServiceView *serviceView;
    BillingBottomView *bbView;
    NSMutableArray *viewArray;
    float itemHeight;
    float serverHeight;
    float userHeight;
    float bottomeTop;
    UIView *contentV;
    NSMutableArray *itemArray;
    NSMutableArray *serviceArray;
    int billingNum;
    float billingAccount;
    NSMutableArray *itemContentArray;
    NSMutableArray *serviceContentArray;
    NSDictionary *carInfo;
    NSString *dateString;
    BOOL bol;
    NoticeView *noticeView;
    NSDictionary *userInfo;
    NSDictionary *valueInfo;
}

@end

@implementation NIncreaseViewController

- (void)viewWillLayoutSubviews {
    if (!bol) {
        
        
        bol = YES;
    }
}

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

- (BOOL)checkInput {
    if (increaseView.orederIdField.text.length > 0 && increaseView.userNameField.text.length > 0 && increaseView.carNumField.text.length > 0 && increaseView.phoneField.text.length > 0 && increaseView.roadHudField.text.length > 0 && increaseView.serviceNameField.text.length > 0 && increaseView.serviceTypeField.text.length > 0 && increaseView.carTypeField.text.length > 0) {
        return YES;
    }
    return NO;
}

- (void)loadDataWithDict:(NSDictionary *)info{
    valueInfo = [[NSDictionary alloc] initWithDictionary:info];
    increaseView.orederIdField.text = info[@"ConNo"];
    increaseView.userNameField.text = info[@"MemberName"];
    increaseView.phoneField.text = info[@"TelNumber"];
    increaseView.carNumField.text = info[@"LicenNum"];
    increaseView.carTypeField.text = info[@"MotoType"];
    increaseView.roadHudField.text = info[@"RoadHaul"];
    increaseView.serviceNameField.text = info[@"ServerConsultant"];
    increaseView.serviceTypeField.text = info[@"ServiceType"];
}

- (void)initViews {
    WS(ws);
    increaseView = [[[NSBundle mainBundle] loadNibNamed:@"IncreaseView" owner:self options:nil] lastObject];
    if (_isFromCarCheck) {
        [self loadDataWithDict:_DataDict];
    }else{
        __block typeof(self) weakSelf = self;
        increaseView.pushView = ^(void) {
            SearchPickUpViewController *spuvc = [[SearchPickUpViewController alloc] initWithNibName:@"SearchPickUpViewController" bundle:nil];
            spuvc.passValue = ^(NSDictionary *info) {
                [weakSelf loadDataWithDict:info];
            };
            [ws.navigationController pushViewController:spuvc animated:YES];
        };
    }
    
    itemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
    itemHeight = CGRectGetHeight(itemView.frame);
    userHeight = CGRectGetHeight(increaseView.frame);
    __block NSMutableArray *weakItemArray = itemArray;
    itemView.addItem = ^(void) {
        ItemListViewController *ilvc = [[ItemListViewController alloc] initWithNibName:@"ItemListViewController" bundle:nil];
        ilvc.fromPage = PICKUP_FROMPAGE;
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
            [ws account];
        };
        [ws.navigationController pushViewController:ilvc animated:YES];
    };
    serviceView = [[[NSBundle mainBundle] loadNibNamed:@"ServiceView" owner:self options:nil] lastObject];
    serverHeight = CGRectGetHeight(serviceView.frame);
    serviceView.addService = ^(void) {
        __block NSMutableArray *weakServiceArray = serviceArray;
        ServicesViewController *slvc = [[ServicesViewController alloc] initWithNibName:@"ServicesViewController" bundle:nil];
        slvc.addArray = weakServiceArray;
        slvc.passServiceArray = ^(NSMutableArray *array) {
            for (int i = 0; i < array.count; i++) {
                NSDictionary *dict = array[i];
                [weakServiceArray addObject:dict];
            }
            [ws addServiceContent];
            [ws account];
        };
        [ws.navigationController pushViewController:slvc animated:YES];
    };
    
    noticeView = [[[NSBundle mainBundle] loadNibNamed:@"NoticeView" owner:self options:nil] lastObject];
    bbView = [[[NSBundle mainBundle] loadNibNamed:@"BillingBottomView" owner:self options:nil] lastObject];
    bbView.addClick = ^(void) {
        if ([ws checkInput]) {
            if (serviceArray.count == 0) {
                [ZAActivityBar showErrorWithStatus:@"请添加相关服务"];
            }else {
                [ws addIncrease];
            }
        }else {
            [ZAActivityBar showErrorWithStatus:@"请选择维修单号"];
        }
    };
    viewArray = [[NSMutableArray alloc] initWithObjects:increaseView,serviceView,itemView, nil];
}

- (void)addServiceContent {
    WS(ws);
    for (UIView *view in [serviceView.contentV subviews]) {
        [view removeFromSuperview];
    }
    AddServiceView *lastV = nil;
    [serviceContentArray removeAllObjects];
    __weak NSMutableArray *weakServiceArray = serviceArray;
    if (weakServiceArray.count > 0) {
        for (int i = 0; i < serviceArray.count; i++) {
            AddServiceView *asv = [[[NSBundle mainBundle] loadNibNamed:@"AddServiceView" owner:self options:nil] lastObject];
            asv.tag = 1000 + i;
            __weak AddServiceView *weakAsv = asv;
            asv.serviceNameL.text = [ToolKit getStringVlaue:serviceArray[i][@"Name"]];
            asv.serviceCodeL.text = [NSString stringWithFormat:@"项目编码：%@",[ToolKit getStringVlaue:serviceArray[i][@"Code"]]];
            float acount = [[ToolKit getStringVlaue:serviceArray[i][@"WorkTimePrice"]]floatValue];
            float workTime = [[ToolKit getStringVlaue:serviceArray[i][@"WorkTime"]] floatValue];
            asv.priceTextField.text = [NSString stringWithFormat:@"%.2f",acount];
            asv.workTimeTextField.text = [ToolKit getStringVlaue:serviceArray[i][@"WorkTime"]];
            asv.accountL.text = [NSString stringWithFormat:@"￥%.2f",acount * workTime];
            asv.changePrice = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakServiceArray[ctag] mutableCopy];
                [self changePrice:weakAsv info:info index:ctag];
                [ws countAccount:weakAsv];
                [ws account];
            };
            asv.changeWorkTime = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakServiceArray[ctag] mutableCopy];
                [self changeWorkTime:weakAsv info:info index:ctag];
                [ws countAccount:weakAsv];
                [ws account];
            };
            asv.delContent = ^(UIView *v) {
                NSInteger tag = v.tag - 1000;
                [weakServiceArray removeObjectAtIndex:tag];
                [ws addServiceContent];
                [ws account];
            };
            [serviceView.contentV addSubview:asv];
            [serviceContentArray addObject:asv];
            [asv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(serviceView.contentV.left);
                make.right.equalTo(serviceView.contentV.right);
                make.height.mas_equalTo(CGRectGetHeight(asv.frame));
            }];
            if (lastV) {
                [asv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastV.bottom);
                }];
            }else {
                [asv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(serviceView.contentV.top);
                }];
            }
            lastV = asv;
        }
        lastV.bottomLineV.hidden = YES;
        [serviceView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(serviceView.contentV.frame.origin.y + 5 + CGRectGetHeight(lastV.frame) * serviceArray.count);
        }];
    }else {
        [serviceView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(serverHeight);
        }];
        [self addEmptyView:serviceView.contentV];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)countAccount:(UIView *)view {
    float price = 0.f;
    float num = 0.f;
    if ([view isKindOfClass:[AddItemView class]]) {
        price = [((AddItemView *)view).priceTextField.text floatValue];
        num = [((AddItemView *)view).numL.text floatValue];
        ((AddItemView *)view).accountL.text = [NSString stringWithFormat:@"￥%.2f",price * num];
    }else {
        float unitPrice = [((AddServiceView *)view).priceTextField.text floatValue];
        float workPrice = [((AddServiceView *)view).workTimeTextField.text floatValue];
        ((AddServiceView *)view).accountL.text = [NSString stringWithFormat:@"￥%.2f",unitPrice * workPrice];
    }
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

- (void)changePrice:(UIView *)weakAiv info:(NSMutableDictionary *)info index:(NSInteger)ctag {
    NSString *price = @"";
    if ([weakAiv isKindOfClass:[AddItemView class]]) {
        price = ((AddItemView *)weakAiv).priceTextField.text;
        [info setObject:price forKey:@"SalePrice"];
        [itemArray removeObjectAtIndex:ctag];
        [itemArray insertObject:info atIndex:ctag];
    }else {
        price = ((AddServiceView *)weakAiv).priceTextField.text;
        [info setObject:price forKey:@"WorkTimePrice"];
        [serviceArray removeObjectAtIndex:ctag];
        [serviceArray insertObject:info atIndex:ctag];
    }
}

- (void)changeWorkTime:(UIView *)weakAiv info:(NSMutableDictionary *)info index:(NSInteger)ctag {
    NSString *price = ((AddServiceView *)weakAiv).workTimeTextField.text;
    [info setObject:price forKey:@"WorkTime"];
    [serviceArray removeObjectAtIndex:ctag];
    [serviceArray insertObject:info atIndex:ctag];
}

- (void)account {
    billingAccount = 0.f;
    billingNum = 0;
    [self getItemAccount];
    [self getServiceAccount];
    if (itemContentArray.count == 0 && serviceContentArray.count == 0) {
        billingAccount = 0;
        billingNum = 0;
    }
    bbView.accountL.text = [NSString stringWithFormat:@"￥%.2f",billingAccount];
    bbView.numL.text = [NSString stringWithFormat:@"%d",billingNum];
}

- (void)getItemAccount {
    for (int i = 0; i < itemContentArray.count; i++) {
        AddItemView *aiv = itemContentArray[i];
        NSString *acc = [aiv.accountL.text substringWithRange:NSMakeRange(1, aiv.accountL.text.length-1)];
        NSString *num = aiv.numL.text;
        float account = [acc floatValue];
        int inum = [num intValue];
        billingAccount += account;
        billingNum += inum;
    }
}

- (void)getServiceAccount {
    for (int i = 0; i < serviceContentArray.count; i++) {
        AddServiceView *asv = serviceContentArray[i];
        NSString *acc = [asv.accountL.text substringWithRange:NSMakeRange(1, asv.accountL.text.length-1)];
        float account = [acc floatValue];
        billingAccount += account;
        billingNum++;
    }
}

- (void)addItemContent {
    WS(ws);
    for (UIView *view in [itemView.contentV subviews]) {
        [view removeFromSuperview];
    }
    [itemContentArray removeAllObjects];
    AddItemView *lastV = nil;
    __weak NSMutableArray *weakItemArray = itemArray;
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
            //            int storeNum = [sstroeNum intValue];
            //            if ((num + 1) <= storeNum) {
            //                aiv.addBtn.enabled = YES;
            //            }else {
            //                aiv.addBtn.enabled = NO;
            //            }
            aiv.accountL.text = [NSString stringWithFormat:@"￥%.2f",acount * num];
            aiv.addNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                int num = [info[@"BuyNum"] intValue];
                ++num;
                //                int storeNum = [info[@"StoreNum"] intValue];
                //                if (num == storeNum) {
                //                    weakAiv.addBtn.enabled = NO;
                //                }else {
                //                    weakAiv.addBtn.enabled = YES;
                //                }
                weakAiv.addBtn.enabled = YES;
                NSString *cnum = [NSString stringWithFormat:@"%d",num];
                [self changeNum:weakAiv info:info index:ctag num:cnum];
                [ws account];
            };
            aiv.redNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                int num = [info[@"BuyNum"] intValue];
                --num;
                weakAiv.addBtn.enabled = YES;
                if (num != 0) {
                    NSString *cnum = [NSString stringWithFormat:@"%d",num];
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
                float num = [weakAiv.numTextField.text floatValue];
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
    }else {
        [itemView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(itemHeight);
        }];
        [self addEmptyView:itemView.contentV];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    itemArray = [[NSMutableArray alloc] init];
    itemContentArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    serviceContentArray = [[NSMutableArray alloc] init];
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
                [self addEmptyView:((ServiceView *)subv).contentV];
            }
                break;
            case 2:
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
    if (_serArray.count > 0) {
        serviceArray = [NSMutableArray arrayWithArray:_serArray];
        [ws addServiceContent];
        [ws account];
    }
}

#pragma mark - private

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
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
    self.title = @"增项开单";
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

- (NSMutableArray *)getProjectItems {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < serviceArray.count; i++) {
        NSDictionary *dict = serviceArray[i];
        AddServiceView *asv = serviceContentArray[i];
        NSString *price = asv.priceTextField.text;
        NSDictionary *info = @{@"ProjectId":dict[@"Id"],@"WorkTime":dict[@"WorkTime"],@"WorkTimePrice":price};
        [array addObject:info];
    }
    return array;
}


#pragma mark - request
- (void)addIncrease {
    if (valueInfo) {
        [ZAActivityBar showWithStatus:LODING_MSG];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *token = [userInfo objectForKey:@"Token"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSString *sourceConNo = valueInfo[@"ConNo"];
        NSString *sourceConID = valueInfo[@"ID"];
        NSDictionary *parameters = @{@"UserToken":userDict,@"SourceConNo":sourceConNo,@"SourceConID":sourceConID,@"Accesses":[self getSaleItems],@"Projects":[self getProjectItems],@"Remark":noticeView.textView.text};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddMaintainExtra];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [[responseObject objectForKey:@"Code"] intValue];
            if (code == 0) {
                [ZAActivityBar showSuccessWithStatus:responseObject[@"Message"]];
                NSLog(@"%@",self.navigationController.viewControllers);
                if ([self.navigationController.viewControllers[2] isKindOfClass:[CarCheckViewController class]]) {
                    [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }else {
                [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        }];
    }
}

- (void)hiddenActivityBar {
    [ZAActivityBar dismiss];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 99) {
        if (buttonIndex == 1) {
            //        [userView reset];
            if ([self.navigationController.viewControllers[2] isKindOfClass:[CarCheckViewController class]]) {
                [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
