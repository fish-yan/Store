//
//  ServerBillingViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/13.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ServerBillingViewController.h"
#import "UserView.h"
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
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ServerBillingViewController () {
    UserView *userView;
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
    NSDictionary *printInfo;
    UIAlertView *printAlerView;
    UIAlertView *printingAlerView;
    NSDictionary *userInfo;
}

@end

@implementation ServerBillingViewController

- (void)initToolBar {
    self.accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 70, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"完成" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.accessoryView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)OnTapDone:(id) sender{
    if ( [userView.validDate isFirstResponder] ) {
        [userView.validDate resignFirstResponder];
    }
}

- (void)viewWillLayoutSubviews {
    if (!bol) {
        
        
        bol = YES;
    }
}

- (void)initDatePicker {
    //添加一个时间选择器
    self.datePicker = [[UIDatePicker alloc] init];
    /**
     28      *  设置只显示中文
     29      */
    [_datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    /**
     32      *  设置只显示日期
     33      */
    _datePicker.datePickerMode=UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];//重点：UIControlEventValueChanged
    //默认根据手机本地设置显示为中文还是其他语言
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    _datePicker.locale = locale;
    _datePicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(void)dateChanged:(id)sender{
    UIDatePicker *control = (UIDatePicker*)sender;
    NSDate* date = control.date;
    //添加你自己响应代码
    NSLog(@"dateChanged响应事件：%@",date);
    
    //NSDate格式转换为NSString格式
    NSDate *pickerDate = [self.datePicker date];// 获取用户通过UIDatePicker设置的日期和时间
    NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [pickerFormatter setDateFormat:@"yyyy/MM/dd"];
    dateString = [pickerFormatter stringFromDate:pickerDate];
    //打印显示日期时间
    NSLog(@"格式化显示时间：%@",dateString);
    if ( [userView.validDate isFirstResponder] ) {
        userView.validDate.text = [NSString stringWithFormat:@"%@", dateString];
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
    NSString *companyId = userInfo[@"CompanyId"];
    if ([companyId isEqualToString:GH_ID]) {
        if (userView.stTextField.text.length > 0 && userView.licenNumTextField.text.length > 0 && userView.telNumberTextField.text.length == 11 && userView.telPersonTextField.text.length > 0 && userView.frameNumTextField.text.length > 0 && userView.roadHaulTextField.text.length > 0 && userView.validDate.text.length > 0) {
            return YES;
        }
    }else {
        if (userView.stTextField.text.length > 0 && userView.licenNumTextField.text.length > 0 && userView.telNumberTextField.text.length == 11 && userView.telPersonTextField.text.length > 0) {
            return YES;
        }
    }
    return NO;
}

- (void)initViews {
    WS(ws);
    userView = [[[NSBundle mainBundle] loadNibNamed:@"UserView" owner:self options:nil] lastObject];
    __weak UserView *weakUser = userView;
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
        [ws getPackageCardByCarNum];
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
    userView.validDate.inputView = _datePicker;
    userView.validDate.inputAccessoryView = _accessoryView;
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
            [ws account];
        };
        [ws.navigationController pushViewController:ilvc animated:YES];
    };
    serviceView = [[[NSBundle mainBundle] loadNibNamed:@"ServiceView" owner:self options:nil] lastObject];
    serverHeight = CGRectGetHeight(serviceView.frame);
    __weak NSMutableArray *weakServiceArray = serviceArray;
    serviceView.addService = ^(void) {
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
        if ([self checkInput]) {
            if (serviceArray.count == 0) {
                [ZAActivityBar showErrorWithStatus:@"请添加相关服务"];
            }else {
                NSString *btnTitle = bbView.saveBtn.titleLabel.text;
                if ([btnTitle isEqualToString:@"保存"]) {
                    [ws addSaleProject];
                }else {
                    [self printData];
                }
            }
        }else {
            if (weakUser.licenNumTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请输入车牌号"];
            }else if (weakUser.stTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请选择车牌"];
            }else if (weakUser.telPersonTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请输入联系人"];
            }else if (weakUser.telNumberTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请输入联系号码"];
            }else if (weakUser.telNumberTextField.text.length > 11 || weakUser.telNumberTextField.text.length < 11) {
                [ZAActivityBar showErrorWithStatus:@"请正确填写手机号码"];
            }else if (weakUser.frameNumTextField.text.length == 0) {
                [ZAActivityBar showErrorWithStatus:@"请填写车驾号"];
            }else {
                [ZAActivityBar showErrorWithStatus:@"请正确里程"];
            }
        }
    };
    viewArray = [[NSMutableArray alloc] initWithObjects:userView,serviceView,itemView, nil];
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
    bbView.accountL.text = [NSString stringWithFormat:@"%.2f",billingAccount];
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
            aiv.accountL.text = [NSString stringWithFormat:@"￥%.2f",acount * num];
            aiv.addNum = ^(NSInteger tag) {
                NSInteger ctag = tag - 1000;
                NSMutableDictionary *info = [weakItemArray[ctag] mutableCopy];
                int num = [info[@"BuyNum"] intValue];
                ++num;
                int storeNum = [info[@"StoreNum"] intValue];
                if (num == storeNum) {
                    weakAiv.addBtn.enabled = NO;
                }else {
                    weakAiv.addBtn.enabled = YES;
                }
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
                [self changeNum:weakAiv info:info index:ctag num:weakAiv.numTextField.text];
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
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    itemArray = [[NSMutableArray alloc] init];
    itemContentArray = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    serviceContentArray = [[NSMutableArray alloc] init];
    [self initHeader];
    [self initToolBar];
    [self initDatePicker];
    [self initViews];
    _scrollView = TPKeyboardAvoidingScrollView.new;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    //    _scrollView.backgroundColor = UIColorFromRGB(0xF3F3F3);
    _scrollView.backgroundColor = UIColorFromRGB(0xF3F3F3);
    __weak UserView *weakUser = userView;
    __block TPKeyboardAvoidingScrollView *weakScrollView = _scrollView;
    _scrollView.touchEvent = ^(void) {
        [UIView animateWithDuration:0.3 animations:^{
            weakUser.constraintHeight.constant = 0;
            [weakUser.linceView layoutIfNeeded];
        }completion:^(BOOL finished) {
            weakScrollView.scrollEnabled = YES;
        }];
    };
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
    [self closeKeybord];
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃订单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
    alerView.tag = 99;
    alerView.delegate = self;
    [alerView show];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"服务开单";
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
- (void)addSaleProject {
    bbView.saveBtn.enabled = NO;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *memberId = nil;
    if (carInfo) {
        memberId = carInfo[@"MemberId"];
    }
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *headerLicenNum = userView.stTextField.text;
    NSString *endLicenNum = userView.licenNumTextField.text;
    NSString *roadHaul = userView.roadHaulTextField.text;
    NSString *frameNum = userView.frameNumTextField.text;
    NSString *licenNum = @"";
    if (![headerLicenNum isEqualToString:@"军牌"]) {
        licenNum = [NSString stringWithFormat:@"%@-%@",headerLicenNum,endLicenNum];
    }else {
        licenNum = endLicenNum;
    }
    NSDictionary *parameters = @{@"UserToken":userDict,@"LicenNum":licenNum,@"completeTime":userView.validDate.text,@"TelPerson":userView.telPersonTextField.text,@"TelNumber":userView.telNumberTextField.text,@"AccessItems":[self getSaleItems],@"ProjectItems":[self getProjectItems],@"UserId":userId};
    NSMutableDictionary *mutP = [parameters mutableCopy];
    if (noticeView.textView.text.length > 0) {
        [mutP setObject:noticeView.textView.text forKey:@"Remark"];
    }
    if (memberId) {
        [mutP setObject:memberId forKey:@"memberId"];
    }
    if (roadHaul.length > 0) {
        [mutP setObject:roadHaul forKey:@"RoadHaul"];
    }
    if (frameNum.length > 0) {
        [mutP setObject:frameNum forKey:@"FrameNum"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddSaleProject];
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

- (void)getPackageCardByCarNum {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *carNum = carInfo[@"CarNumber"];
    NSString *memberId = carInfo[@"MemberId"];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"MemberId":memberId,@"CarNum":carNum,@"StoreId":storeId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetPackageCardByCarNum];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            int sum = [[responseObject objectForKey:@"Result"] intValue];
            if (sum > 0) {
                [ZAActivityBar showWithStatus:@"该客户拥有项目套餐卡"];
                [self performSelector:@selector(hiddenActivityBar) withObject:nil afterDelay:5];
            }else {
                [ZAActivityBar dismiss];
            }
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)hiddenActivityBar {
    [ZAActivityBar dismiss];
}

- (void)closeKeybord {
    if ( [userView.validDate isFirstResponder] ) {
        [userView.validDate resignFirstResponder];
    }
    if ( [userView.licenNumTextField isFirstResponder] ) {
        [userView.licenNumTextField resignFirstResponder];
    }
    if ( [userView.telPersonTextField isFirstResponder] ) {
        [userView.telPersonTextField resignFirstResponder];
    }
    if ( [userView.telNumberTextField isFirstResponder] ) {
        [userView.telNumberTextField resignFirstResponder];
    }
    if ( [userView.frameNumTextField isFirstResponder] ) {
        [userView.frameNumTextField resignFirstResponder];
    }
    if ( [userView.roadHaulTextField isFirstResponder] ) {
        [userView.roadHaulTextField resignFirstResponder];
    }
}

- (void)printData {
    NSDictionary *info = [[SharedBlueToothManager sharedBlueToothManager] printServiceNotesWithInfoDicts:printInfo];
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
