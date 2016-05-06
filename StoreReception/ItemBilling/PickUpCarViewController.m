//
//  PickUpCarViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/9.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "PickUpCarViewController.h"
#import "PickUserView.h"
#import "RepairView.h"
#import "EmptyView.h"
#import "ServiceView.h"
#import "ItemView.h"
#import "BillingBottomView.h"
#import "ZAActivityBar.h"
#import "ShowPhotoViewController.h"
#import "RepairContentViewController.h"
#import "RepairContentView.h"
#import "ServicesViewController.h"
#import "ItemListViewController.h"
#import "AddItemView.h"
#import "OrderTypeView.h"
#import "AddServiceView.h"
#import "FirstCheck.h"
#import "ToolKit.h"
#import "SearchUserViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+jsonString.h"
#import "SearchItemHistoryPriceViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "PickUpTableViewCell.h"
#import "UIView+empty.h"
#import "DispatchingViewController.h"
#import "NoticeView.h"
#import "ScanningRecognizeViewController.h"
#import "SocketKit.h"
#import "ConstructionViewController.h"

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
static NSString *pickCell = @"pickCell";
int padding = 10;
int bottomPadding = 13;
int topPadding = 15;

@interface PickUpCarViewController () {
    PickUserView *userView;
    RepairView *repaiView;
    ServiceView *serviceView;
    ItemView *itemView;
    OrderTypeView *orderView;
    FirstCheck *firstView;
    BillingBottomView *bbView;
    NoticeView *noticeView;
    NSMutableArray *viewArray;
    UIScrollView *imageScrollView;
    NSMutableArray *imageArray;
    NSMutableArray *imageViews;
    UIView *imageContentV;
    float repairHeight;
    float itemHeight;
    float serverHeight;
    float repairContentHeight;
    UIView *contentV;
    NSMutableArray *repairContentArray;
    NSMutableArray *itemContentArray;
    NSMutableArray *serviceContentArray;
    UIView *contentView;
    float repairChangedHeight;
    RepairContentView *orcv;
    NSMutableArray *itemArray;
    NSMutableArray *serviceArray;
    int billingNum;
    float billingAccount;
    NSDictionary *carInfo;
    NSDictionary *plistDict;
    NSMutableString *carCondition;
    UIView *bottomView;
    UITableView *pickTableView;
    NSMutableArray *resultArray;
    UIButton *pickBtn;
    UIButton *commitBtn;
    int pageIndex;
    int pageSize;
    int countResult;
    int selectedTag;
    NSString *currentOrderId;//提交后的派工单id
    NSDictionary *infoDict;
}

@end

@implementation PickUpCarViewController

- (void)addBottomView {
    bottomView = UIView.new;
    bottomView.backgroundColor = UIColorFromRGB(0xEDEDED);
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
        make.height.mas_equalTo(49);
    }];
    pickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pickBtn setTitle:@"维修开单" forState:UIControlStateNormal];
    [pickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pickBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
    pickBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [pickBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    pickBtn.tag = 1;
    [bottomView addSubview:pickBtn];
    [pickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.top);
        make.left.equalTo(bottomView.left);
        make.bottom.equalTo(bottomView.bottom);
    }];
    commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setBackgroundColor:[UIColor clearColor]];
    commitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [commitBtn setTitle:@"单据提交" forState:UIControlStateNormal];
    [commitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    commitBtn.tag = 2;
    [bottomView addSubview:commitBtn];
    [commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pickBtn.right);
        make.top.equalTo(bottomView.top);
        make.right.equalTo(bottomView.right);
        make.bottom.equalTo(bottomView.bottom);
        make.width.equalTo(pickBtn.width);
    }];
}

- (void)initTableView {
    pickTableView = UITableView.new;
    pickTableView.backgroundColor = [UIColor clearColor];
    pickTableView.delegate = self;
    pickTableView.dataSource = self;
    pickTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    pickTableView.hidden = YES;
    pickTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        pageIndex = 0;
        [self unRepairList];
    }];
    pickTableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        pageIndex++;
        [self unRepairList];
    }];
    [self.view addSubview:pickTableView];
    UIEdgeInsets tableviewPadding = UIEdgeInsetsMake(0, 0, 49, 0);
    [pickTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(tableviewPadding);
    }];
}

- (void)click:(UIButton *)btn {
    NSInteger tag = btn.tag;
    if (tag == 1) {
        _scrollView.hidden = NO;
        pickTableView.hidden = YES;
        [commitBtn setBackgroundColor:[UIColor clearColor]];
        [commitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pickBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
        [pickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        _scrollView.hidden = YES;
        pickTableView.hidden = NO;
        [pickTableView.header beginRefreshing];
        [pickBtn setBackgroundColor:[UIColor clearColor]];
        [pickBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [commitBtn setBackgroundColor:UIColorFromRGB(0x256ECD)];
        [commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)initViews {
    WS(ws);
    userView = [[[NSBundle mainBundle] loadNibNamed:@"PickUserView" owner:self options:nil] lastObject];
    __weak PickUserView *weakUser = userView;
    __block TPKeyboardAvoidingScrollView *weakScrollView = _scrollView;
    userView.editLicen = ^(void) {
        /**
        SearchUserViewController *suvc = [[SearchUserViewController alloc] initWithNibName:@"SearchUserViewController" bundle:nil];
        suvc.type = @"ItemBillingViewController";
        suvc.backLicen = ^(NSDictionary *dict) {
            carInfo = [[NSDictionary alloc] initWithDictionary:dict];
            weakCarinfo = carInfo;
            weakUser.info = weakCarinfo;
            NSString *lince = weakCarinfo[@"CarNumber"];
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
            [weakUser repairInfobyCarNum];
        };
        [ws.navigationController pushViewController:suvc animated:YES];
         **/
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
            weakUser.viewConstraintHeight.constant = 0;
            [weakUser.lincenView layoutIfNeeded];
        }completion:^(BOOL finished) {
            weakScrollView.scrollEnabled = YES;
        }];
    };
    firstView = [[[NSBundle mainBundle] loadNibNamed:@"FirstCheck" owner:self options:nil] lastObject];
    repaiView = [[[NSBundle mainBundle] loadNibNamed:@"RepairView" owner:self options:nil] lastObject];
    itemView = [[[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:self options:nil] lastObject];
    serviceView = [[[NSBundle mainBundle] loadNibNamed:@"ServiceView" owner:self options:nil] lastObject];
    noticeView = [[[NSBundle mainBundle] loadNibNamed:@"NoticeView" owner:self options:nil] lastObject];
    repairHeight = CGRectGetHeight(repaiView.frame);
    itemHeight = CGRectGetHeight(itemView.frame);
    serverHeight = CGRectGetHeight(serviceView.frame);
    repairContentHeight = CGRectGetHeight(repaiView.contentV.frame);
    repaiView.photoClick = ^(void) {
        if (imageArray.count < 6) {
            UIActionSheet *actionSheet;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"照片选择", nil) delegate:ws cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"相册", nil),NSLocalizedString(@"拍照", nil), nil];
            } else {
                actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"", nil) delegate:ws cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"相册", nil), nil];
            }
            [actionSheet showInView:ws.view];
        }else {
            [ZAActivityBar showErrorWithStatus:@"最多拍照6张"];
        }
    };
    repaiView.addRepair = ^(void) {
        RepairContentViewController *rcvc = [[RepairContentViewController alloc] initWithNibName:@"RepairContentViewController" bundle:nil];
        rcvc.addArray = repairContentArray;
        rcvc.passContent = ^(NSArray *array) {
            repairContentArray = nil;
            repairContentArray = [[NSMutableArray alloc] initWithArray:array];
            [ws addRepairContent];
        };
        [ws.navigationController pushViewController:rcvc animated:YES];
    };
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
    __weak NSMutableArray *weakItemArray = itemArray;
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
//    orderView = [[[NSBundle mainBundle] loadNibNamed:@"OrderTypeView" owner:self options:nil] lastObject];
    bbView = [[[NSBundle mainBundle] loadNibNamed:@"BillingBottomView" owner:self options:nil] lastObject];
    bbView.saveBtn.enabled = YES;
    bbView.addClick = ^(void) {
        if (serviceArray.count == 0) {
            [ZAActivityBar showErrorWithStatus:@"请添加相关服务"];
        }else {
            [ws addNewMaintain];
        }
//        if (userView.licenNumTextField.text.length > 0 && userView.telNumberTextField.text.length == 11 && userView.telPersonTextField.text.length > 0 && userView.frameNumTextField.text.length > 0 && userView.roadHaulTextField.text.length > 0) {
//            if (serviceArray.count == 0) {
//                [ZAActivityBar showErrorWithStatus:@"请添加相关服务"];
//            }else {
//                [ws addNewMaintain];
//            }
//        }else {
//            if (weakUser.licenNumTextField.text.length == 0) {
//                [ZAActivityBar showErrorWithStatus:@"请输入车牌号"];
//            }else if (weakUser.telPersonTextField.text.length == 0) {
//                [ZAActivityBar showErrorWithStatus:@"请输入联系人"];
//            }else if (weakUser.telNumberTextField.text.length == 0) {
//                [ZAActivityBar showErrorWithStatus:@"请输入联系号码"];
//            }else if (weakUser.telNumberTextField.text.length > 11 || weakUser.telNumberTextField.text.length < 11) {
//                [ZAActivityBar showErrorWithStatus:@"请正确填写手机号码"];
//            }else if (weakUser.frameNumTextField.text.length == 0) {
//                [ZAActivityBar showErrorWithStatus:@"请填写车驾号"];
//            }else {
//                [ZAActivityBar showErrorWithStatus:@"请正确里程"];
//            }
//        }
    };
    viewArray = [[NSMutableArray alloc] initWithObjects:userView,firstView,repaiView,serviceView,itemView, nil];
    [self addBottomView];
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

- (void)addRepairContent {
    WS(ws);
    if (contentView) {
        for (UIView *view in [contentView subviews]) {
            [view removeFromSuperview];
        }
        [contentView removeFromSuperview];
        contentView = nil;
    }
    if (imageArray.count == 0) {
        for (UIView *view in [repaiView.contentV subviews]) {
            [view removeFromSuperview];
        }
        repairChangedHeight = repaiView.contentV.frame.origin.y + 10;
    }
    if (repairContentArray.count == 0 && imageArray.count == 0) {
        [repaiView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(repairHeight);
        }];
        [self addEmptyView:repaiView.contentV];
    }else {
        contentView = UIView.new;
        contentView.backgroundColor = [UIColor clearColor];
        [repaiView.contentV addSubview:contentView];
        BOOL bol = NO;
        for (UIView *view in [repaiView.contentV subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                bol = YES;
                [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(imageScrollView.bottom);
                }];
            }
        }
        if (!bol) {
            [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(repaiView.contentV.top);
            }];
        }
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(repaiView.contentV.left).offset(10);
            make.right.equalTo(repaiView.contentV.right).offset(-10);
            make.bottom.equalTo(repaiView.contentV.bottom).offset(-10);
            //        make.height.mas_equalTo(130);
        }];
        RepairContentView *lastV = nil;
        for (int i = 0; i < repairContentArray.count; i++) {
            RepairContentView *rcv = [[[NSBundle mainBundle] loadNibNamed:@"RepairContentView" owner:self options:nil] lastObject];
            rcv.tag = 1000 + i;
            rcv.delContent = ^(UIView *v) {
                NSInteger tag = v.tag - 1000;
                [repairContentArray removeObjectAtIndex:tag];
                [ws addRepairContent];
            };
            UIView *view = [repairContentArray objectAtIndex:i];
            if ([view isKindOfClass:[UIButton class]]) {
                if (view.tag == 33 || view.tag == 34 || view.tag == 37) {
                    rcv.contentL.text = [NSString stringWithFormat:@"修复车身下护板：%@",((UIButton *)view).titleLabel.text];
                } else if (view.tag == 35 || view.tag == 36) {
                    rcv.contentL.text = [NSString stringWithFormat:@"额外工作：%@",((UIButton *)view).titleLabel.text];
                } else {
                    rcv.contentL.text = ((UIButton *)view).titleLabel.text;
                }
            }else {
                NSString *key = [self getKey:view.tag];
                rcv.contentL.text = [NSString stringWithFormat:@"%@：%@",key,((UITextField *)view).text];
            }
            [contentView addSubview:rcv];
            [rcv mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(contentView.left);
                make.right.equalTo(contentView.right);
                make.height.mas_equalTo(CGRectGetHeight(rcv.frame));
            }];
            if (lastV) {
                [rcv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(lastV.bottom);
                }];
            }else {
                [rcv mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(contentView.top);
                }];
            }
            lastV = rcv;
        }
        lastV.bottomLineV.hidden = YES;
        orcv = lastV;
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.bottom.equalTo(lastV.bottom);
        }];
        NSLog(@"cc:   %f--%f",repairChangedHeight, CGRectGetHeight(lastV.frame) * repairContentArray.count);
        [repaiView updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(repairChangedHeight + CGRectGetHeight(lastV.frame) * repairContentArray.count);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    carCondition = [[NSMutableString alloc] init];
    imageArray = [[NSMutableArray alloc] init];
    imageViews = [[NSMutableArray alloc] init];
    serviceArray = [[NSMutableArray alloc] init];
    itemArray = [[NSMutableArray alloc] init];
    itemContentArray = [[NSMutableArray alloc] init];
    serviceContentArray = [[NSMutableArray alloc] init];
    resultArray = [[NSMutableArray alloc] init];
    pageSize = 20;
    [self getRepairPlist];
    // Do any additional setup after loading the view.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initViews];
    [self initTableView];
    UINib *nib = [UINib nibWithNibName:@"PickUpTableViewCell" bundle:nil];
    [pickTableView registerNib:nib forCellReuseIdentifier:pickCell];
    [self unRepairList];
    _scrollView = TPKeyboardAvoidingScrollView.new;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = UIColorFromRGB(0xF3F3F3);
    _scrollView.touchEvent = ^(void) {
        [UIView animateWithDuration:0.3 animations:^{
            userView.viewConstraintHeight.constant = 0;
            [userView.lincenView layoutIfNeeded];
        }completion:^(BOOL finished) {
            _scrollView.scrollEnabled = YES;
        }];
    };
    [self.view addSubview:_scrollView];
    UIEdgeInsets scrollviewPadding = UIEdgeInsetsMake(0, 0, 49, 0);
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
    
    for (int i = 0; i < viewArray.count; i++) {
        UIView *subv = [viewArray objectAtIndex:i];
        subv.layer.cornerRadius = 8;
        subv.layer.borderWidth = 1;
        subv.layer.borderColor = [UIColorFromRGB(0xD9D9D9) CGColor];
        switch (i) {
            case 2:
            {
                [self addEmptyView:((RepairView *)subv).contentV];
            }
                break;
            case 3:
            {
                [self addEmptyView:((ServiceView *)subv).contentV];
            }
                break;
            case 4:
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
    [bbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(noticeView.bottom).offset(topPadding);
        make.left.equalTo(contentV.left);
        make.right.equalTo(contentV.right);
        make.height.mas_equalTo(CGRectGetHeight(bbView.frame));
    }];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bbView.mas_bottom);
    }];
}

#pragma mark - private

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)backAction {
    if (pickTableView.hidden) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃订单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        alerView.delegate = self;
        [alerView show];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"服务维修";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)addGestureRecognizer:(UIView *)imageView {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    [gesture setNumberOfTapsRequired:1];
    gesture.numberOfTouchesRequired = 1;
    gesture.delegate = self;
    [imageView addGestureRecognizer:gesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = [touch view]; if ([view isKindOfClass:[UIButton class]]) { return NO; } return YES;
}

- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender {
    UIView *imageView = sender.view;
    WS(ws);
    NSInteger tag = imageView.tag - 1000;
    ShowPhotoViewController *sivc = [[ShowPhotoViewController alloc] init];
    sivc.index = ++tag;
    sivc.imageArray = imageArray;
    sivc.passImageArray = ^(NSMutableArray *images) {
        [imageArray removeAllObjects];
        [imageArray addObjectsFromArray:images];
        [ws refreshImageScrollView];
    };
    [self.navigationController pushViewController:sivc animated:YES];
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

- (void)refreshImageScrollView {
    if (imageArray.count > 0) {
        [self initImageScrollView];
    }else {
        if (repairContentArray.count == 0) {
            for (UIView *view in [repaiView.contentV subviews]) {
                [view removeFromSuperview];
            }
            [repaiView updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(repairHeight);
            }];
            [self addEmptyView:repaiView.contentV];
        }else {
            [self addRepairContent];
        }
    }
}

- (void)initImageScrollView {
    if (repairContentArray.count == 0) {
        for (UIView *view in [repaiView.contentV subviews]) {
            [view removeFromSuperview];
        }
    }else {
        for (UIView *view in [repaiView.contentV subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    float imageHeight = (CGRectGetWidth(repaiView.contentV.frame) - 10*2 - 3*6) /4;
    float imageScrollviewHeight = imageHeight + 2*17;
    imageScrollView = UIScrollView.new;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    [repaiView.contentV addSubview:imageScrollView];
    [imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(repaiView.contentV.top);
        make.left.equalTo(repaiView.contentV.left).offset(10);
        make.right.equalTo(repaiView.contentV.right).offset(-10);
        make.height.mas_equalTo(imageScrollviewHeight);
    }];
    [imageViews removeAllObjects];
    imageContentV = UIView.new;
    [imageScrollView addSubview:imageContentV];
    [imageContentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(imageScrollView);
        make.height.equalTo(imageScrollView);
    }];
    [self addImageView];
}

- (void)addImageView {
    float imageHeight = (CGRectGetWidth(repaiView.contentV.frame) - 10*2 - 3*6) /4;
    float imageScrollviewHeight = imageHeight + 2*17;
    
    for (int i = 0; i < imageArray.count; i++) {
        UIImage *image = [imageArray objectAtIndex:i];
        UIImageView *imgV = [[UIImageView alloc] initWithImage:image];
        imgV.userInteractionEnabled = YES;
        imgV.exclusiveTouch = YES;
//        imgV.multipleTouchEnabled = NO;
        [self addGestureRecognizer:imgV];
        [imageViews addObject:imgV];
    }
    UIView *lastV = nil;
    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *view = [imageViews objectAtIndex:i];
        view.tag = 1000 + i;
        [imageContentV addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageContentV).offset(17);
            make.width.mas_equalTo(imageHeight);
            make.height.mas_equalTo(imageHeight);
            if (lastV) {
                make.left.equalTo(lastV.right).offset(6);
            }else {
                make.left.equalTo(imageContentV.left);
            }
        }];
        lastV = view;
    }
    [imageContentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.greaterThanOrEqualTo(lastV.right);
    }];
    repairChangedHeight = imageScrollviewHeight + repaiView.contentV.frame.origin.y + 10;
    [repaiView updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(repairChangedHeight);
    }];
    [self addRepairContent];
}

- (NSString *)getKey:(NSInteger)tag {
    NSString *key = nil;
    switch (tag) {
        case 16:
            key = @"年检：";
            break;
        case 17:
            key = @"有效期：";
            break;
        case 38:
            key = @"备用轮胎：";
            break;
        case 39:
            key = @"千斤顶：";
            break;
        case 40:
            key = @"工具：";
            break;
        case 41:
            key = @"CD：";
            break;
        case 42:
            key = @"点烟器：";
            break;
        case 43:
            key = @"电话卡：";
            break;
        case 44:
            key = @"金额不超过：";
            break;
        default:
            break;
    }
    return key;
}

- (void)resetView {
    [userView resetView];
    [firstView resetView];
    [imageArray removeAllObjects];
    [imageViews removeAllObjects];
    [repairContentArray removeAllObjects];
    [self refreshImageScrollView];
    [serviceArray removeAllObjects];
    [self addServiceContent];
    [itemArray removeAllObjects];
    [self addItemContent];
    [self account];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WS(ws);
    PickUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pickCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *info = resultArray[indexPath.row];
    cell.linceNumL.text = info[@"CarNum"];
    cell.timeL.text = [NSString stringWithFormat:@"进厂时间：%@",info[@"PickupCarTime"]];
    int status = [info[@"OrderStatus"] intValue];
    NSString *stat = @"";
    cell.editBtn.hidden = YES;
    switch (status) {
        case 0:
            stat = @"派工";
            break;
        case 1:
//            cell.editBtn.hidden = NO;
            stat = @"提交";
            break;
        case 2:
            stat = @"施工";
            break;
        default:
            break;
    }
    
    [cell.commitBtn setTitle:stat forState:UIControlStateNormal];
    cell.commitClick = ^(void) {
        selectedTag = indexPath.row;
        if (status == 1) {
            [ws submitCarStatus];
        }else if (status == 0) {
            NSString *oid = @"";
            if (currentOrderId.length > 0) {
                oid = currentOrderId;
            }else {
                oid = info[@"ID"];
            }
            [self pushView:oid];
        }else if (status == 2) {
            ConstructionViewController *cvc = [[ConstructionViewController alloc] initWithNibName:@"ConstructionViewController" bundle:nil];
            cvc.conId = info[@"ID"];
            cvc.refreshData = ^(void) {
                [pickTableView.header beginRefreshing];
            };
            [self.navigationController pushViewController:cvc animated:YES];
        }
    };
    cell.editClick = ^(void) {
        NSDictionary *info = resultArray[selectedTag];
        NSString *iid = info[@"ID"];
        [self getOrderInfo:iid];
        //编辑界面
    };
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = resultArray[indexPath.row];
    DispatchingViewController *dvc = [[DispatchingViewController alloc] initWithNibName:@"DispatchingViewController" bundle:nil];
    dvc.orderId= info[@"ID"];
    dvc.type = DETAIL;
    [self.navigationController pushViewController:dvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imageArray addObject:image];
    [self initImageScrollView];
    
//    [self performSelector:@selector(saveImage:) withObject:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

//将照片保存到disk上
-(void)saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (!error) {
        NSLog(@"picture saved with no error.");
    }
    else
    {
        NSLog(@"error occured while saving the picture%@", error);
    }
}

#pragma mark - delegate of actionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger sourceType = 0;
    switch (buttonIndex) {
        case 1:
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            break;
        case 0:
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            break;
        default:
            break;
    }
    
    if (!sourceType) {
        return;
    }
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

#pragma mark - getData
- (void)getRepairPlist {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RepairList" ofType:@"plist"];
    plistDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

- (NSMutableArray *)getRepairData {
    NSString *key = nil;
    NSString *value = nil;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < repairContentArray.count; i++) {
        UIView *view = repairContentArray[i];
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)[repairContentArray objectAtIndex:i];
            NSString *content = btn.titleLabel.text;
            key = plistDict[content];
            if (btn.tag == 33 || btn.tag == 34 || btn.tag == 35 || btn.tag == 36 || btn.tag == 37) {
                value = content;
            } else if (btn.tag == 28 || btn.tag == 29 || btn.tag == 30 || btn.tag == 31) {
                BOOL bol = NO;
                for (int i = 0; i < array.count; i++) {
                    NSDictionary *d = array[i];
                    NSString *k = d[@"key"];
                    NSString *c = nil;
                    if ([k isEqualToString:key]) {
                        c = d[@"vlaue"];
                        value = [NSString stringWithFormat:@"%@,%@",c,content];
                        bol = YES;
                        [array removeObject:d];
                        break;
                    }
                }
                if (!bol) {
                    value = content;
                }
            } else {
                value = @"Y";
            }
        }else {
            UITextField *utf = (UITextField *)[repairContentArray objectAtIndex:i];
            key = [self getKey:utf.tag];
            value = utf.text;
        }
        NSDictionary *dict = @{@"key":key,@"vlaue":value};
        [array addObject:dict];
    }
    NSArray *addFirstArray = [firstView getData];//添加接车检查数据
    [array addObjectsFromArray:addFirstArray];
    NSLog(@"arr :   %@",array);
    return array;
}

- (void)getOrderInfo:(NSString *)iid {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"Id":iid,@"OrderName":@"维修单"};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetSaleInfo];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            infoDict = [[NSDictionary alloc] initWithDictionary:responseObject[@"Result"]];
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (NSMutableArray *)getServerData {
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

- (NSMutableArray *)getItemData {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < itemArray.count; i++) {
        NSDictionary *dict = itemArray[i];
        AddItemView *aiv = itemContentArray[i];
        NSString *num = aiv.numL.text;
        NSString *salePrice = aiv.priceTextField.text;
        NSDictionary *info = @{@"StockId":dict[@"Id"],@"SalePrice":salePrice,@"Amount":num};
        [array addObject:info];
    }
    return array;
}

- (void)pushView:(NSString *)oid {
    DispatchingViewController *dvc = [[DispatchingViewController alloc] initWithNibName:@"DispatchingViewController" bundle:nil];
    dvc.orderId = oid;
    dvc.type = REPAIRPERSON;
    dvc.repaireComplete = ^(void) {
        [pickTableView.header beginRefreshing];
    };
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - request
- (void)addNewMaintain {
    if (userView.checkValidata) {
        bbView.saveBtn.enabled = NO;
        [ZAActivityBar showWithStatus:LODING_MSG];
        NSDictionary *infoDict = userView.getData;
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *token = [userInfo  objectForKey:@"Token"];
        NSString *headerLicenNum = userView.stTextField.text;
        NSString *endLicenNum = userView.licenNumTextField.text;
        NSString *licenNum = @"";
        if (![headerLicenNum isEqualToString:@"军牌"]) {
            licenNum = [NSString stringWithFormat:@"%@-%@",headerLicenNum,endLicenNum];
        }else {
            licenNum = endLicenNum;
        }
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSString *companyId = [userInfo objectForKey:@"CompanyId"];
        NSString *storeId = userInfo[@"StoreId"];
        NSString *memberId = nil;
        if (carInfo) {
            NSString *carNum = carInfo[@"CarNumber"];
            NSString *lince = [carNum stringByReplacingOccurrencesOfString:@" " withString:@""];
            lince = [lince stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *_lince = licenNum = [NSString stringWithFormat:@"%@-%@",headerLicenNum,endLicenNum];
            if ([licenNum isEqualToString:_lince]) {
                memberId = carInfo[@"MemberId"];
            }
        }
        NSString *memberName = infoDict[@"TelPerson"];
        NSString *caryear = nil;
        NSDictionary *parameters = @{@"UserToken":userDict,@"UserID":userId,@"CompanyID":companyId,@"StoreID":storeId,@"taxTotalSum":@"0",@"LicenseNumber":licenNum,@"Projects":[self getServerData]};
        NSMutableDictionary *mutPar = [parameters mutableCopy];
        if (noticeView.textView.text.length > 0) {
            [mutPar setObject:noticeView.textView.text forKey:@"ConRemark"];
        }
        [mutPar addEntriesFromDictionary:infoDict];
        caryear = userView.carYearTextField.text;
        if (caryear) {
            [mutPar setObject:caryear forKey:@"CarYearNum"];
        }
        if (memberId) {
            [mutPar setObject:memberId forKey:@"memberId"];
        }
        if (memberName) {
            [mutPar setObject:memberName forKey:@"memberName"];
        }
        if (itemArray.count > 0) {
            [mutPar setObject:[self getItemData] forKey:@"Accesses"];
        }
        if (repairContentArray.count > 0) {
            [mutPar setObject:[self getRepairData] forKey:@"CarInfo"];
        }else {
            [mutPar setObject:[firstView getData] forKey:@"CarInfo"];
        }
        NSString *parStr = [mutPar DataTOjsonString];
        NSDictionary *_parameters = @{@"modelValue":parStr};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddNewMaintain];
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:_parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (int i = 0; i < imageArray.count; i++) {
                NSData *data = UIImageJPEGRepresentation(imageArray[i], 0.2);
                NSString *name = [NSString stringWithFormat:@"Image%d",(i + 1)];
                [formData appendPartWithFileData:data name:name fileName:name mimeType:@"image/png"];
            }
        } error:nil];
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSProgress *progress = nil;
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                bbView.saveBtn.enabled = YES;
                [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
            } else {
                NSString *msg = responseObject[@"Message"];
                NSLog(@"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:   %@",msg);
                if (msg.length > 0) {
                    [ZAActivityBar showSuccessWithStatus:msg];
                }
                int code = [[responseObject objectForKey:@"Code"] intValue];
                if (code == 0) {
                    [ZAActivityBar showSuccessWithStatus:@"开单成功"];
                    NSLog(@"result:   %@",responseObject);
                    [self resetView];
                    [self click:commitBtn];
                }else {
                    id result = [responseObject objectForKey:@"Result"];
                    if ([result isKindOfClass:[NSString class]]) {
                        [ZAActivityBar showErrorWithStatus:result];
                    }else {
                        [ZAActivityBar showErrorWithStatus:@"开单出错了，请咨询相关人员!"];
                    }
                }
            }
            bbView.saveBtn.enabled = YES;
        }];
        [uploadTask resume];
    }else {
        [ZAActivityBar showErrorWithStatus:@"信息请填写完整"];
    }
}

- (void)unRepairList {
    pageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *storeId = userInfo[@"StoreId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreId":storeId,@"pageIndex":[NSString stringWithFormat:@"%d",pageIndex],@"pageSize":[NSString stringWithFormat:@"%d",pageSize]};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,UnRepairList];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            id result = responseObject[@"Result"];
            if ([result isKindOfClass:[NSDictionary class]]) {
                if (pageIndex == 1) {
                    [resultArray removeAllObjects];
                }
                NSArray *array = ((NSDictionary *)result)[@"repairCarList"];
                if (array.count > 0) {
                    [resultArray addObjectsFromArray:array];
                    countResult = [result[@"PageCount"] intValue] * pageSize;
                }
            }
            if (resultArray.count == 0) {
                [pickTableView showEmpty];
                [ZAActivityBar showErrorWithStatus:@"查无数据"];
            }else {
                [pickTableView hiddenEmpty];
            }
            if (pageIndex == 1) {
                [pickTableView.header endRefreshing];
            }else {
                [pickTableView.footer endRefreshing];
            }
            [pickTableView reloadData];
            NSLog(@"JSON: %@", responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)submitCarStatus {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *info = resultArray[selectedTag];
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"ConId":info[@"ID"]};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,SubmitCarStatus];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            currentOrderId = responseObject[@"Result"];
            [ZAActivityBar showSuccessWithStatus:responseObject[@"Message"]];
            NSLog(@"JSON: %@", responseObject);
            UIAlertView *aertView = [[UIAlertView alloc] initWithTitle:@"" message:@"维修单已经提交，是否打印" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            aertView.tag = 1003;
            [aertView show];
        }else {
            [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag != 1003) {
//            [userView reset];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (alertView.tag == 1003) {
        NSDictionary *info = resultArray[selectedTag];
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = userInfo[@"UserId"];
        NSString *companyId = userInfo[@"CompanyId"];
        NSString *companyName = userInfo[@"CompanyName"];
        NSString *storeName = userInfo[@"StoreName"];
        NSString *userName = userInfo[@"UserName"];
        NSString *storeId = [userInfo objectForKey:@"StoreId"];
        NSDictionary *printData = @{@"TargetPrintName":@"接车单",@"TargetPrintCount":@"0",@"PrintSpecification":@"A4",@"PrintDocumentParameters":info[@"ID"],@"CompanyID":companyId,@"CompanyName":companyName,@"StoreID":storeId,@"StoreName":storeName,@"PrinterID":userId,@"PrinterName":userName};
        [[SocketKit shareSocketKitManager] socketWriteData:printData];
        NSString *oid = @"";
        if (currentOrderId.length > 0) {
            oid = currentOrderId;
        }else {
            oid = info[@"ID"];
        }
        [pickTableView.header beginRefreshing];
//        [self pushView:oid];
    }
}

@end