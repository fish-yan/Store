//
//  SearchOrderViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/29.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SearchOrderViewController.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "OrderTableViewCell.h"
#import "OrderDetailViewController.h"
#import "UIView+empty.h"
#import "SearchSubViewController.h"
#import "SearchView.h"
#import "ScanningRecognizeViewController.h"
#import <MJRefresh/MJRefresh.h>
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
static NSString *itemCell = @"itemCell";

@interface SearchOrderViewController () {
    int click;
    NSMutableArray *myOrderArray;
    NSMutableArray *otherOrderArray;
    int myOrderPageIndex;
    int otherOrderPageIndex;
    int pageSize;
    int totalRecordsMyOrder;
    int totalRecordsOtherOrder;
    NSMutableArray *records;
    NSIndexPath *myOrderIndex;
    NSIndexPath *otherOrderIndex;
    NSString *text;
    NSString *beginDate;
    NSString *endDate;
    NSString *carNum;
    SearchView *sv;
    NSDateFormatter *formatter;
    NSString *currentDate;
    UITextField *currentTextField;
    NSDictionary *orderTypeInfo;
}

@end

@implementation SearchOrderViewController

- (void)initData {
    myOrderArray = [[NSMutableArray alloc] init];
    otherOrderArray = [[NSMutableArray alloc] init];
    myOrderPageIndex = 0;
    otherOrderPageIndex = 0;
    click = 0;
    pageSize = 20;
    beginDate = @"";
    endDate = @"";
    carNum = @"";
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    currentDate = [formatter stringFromDate:[NSDate date]];
    UINib *nib = [UINib nibWithNibName:@"OrderTableViewCell" bundle:nil];
    [_orderTable registerNib:nib forCellReuseIdentifier:itemCell];
    _orderTable.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        myOrderPageIndex = 0;
        [self getOrderList];
    }];
    _orderTable.footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
        otherOrderPageIndex++;
        [self getOrderList];
    }];
}

- (void)initToolBar {
    self.accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    UIButton* cancelDone = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelDone.frame = CGRectMake(10, 5, 60, 20);
    [cancelDone setBackgroundColor:[UIColor clearColor]];
    [cancelDone setTitle:@"取消" forState:UIControlStateNormal];
    cancelDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.accessoryView addSubview:cancelDone];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(self.accessoryView.frame.size.width-70, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"确定" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.accessoryView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelDone addTarget:self action:@selector(OnTapCancel:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initDatePicker {
    //添加一个时间选择器
    self.datePicker = [[UIDatePicker alloc] init];
    /** 设置只显示中文 */
    [_datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"zh-CN"]];
    /**  设置只显示日期 */
    _datePicker.datePickerMode=UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];//重点：UIControlEventValueChanged
    //默认根据手机本地设置显示为中文还是其他语言
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    self.datePicker.locale = locale;
    self.datePicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

-(void)dateChanged:(id)sender{
    UIDatePicker *control = (UIDatePicker*)sender;
    NSDate* date = control.date;
    //添加你自己响应代码
    NSLog(@"dateChanged响应事件：%@",date);
    //NSDate格式转换为NSString格式
    NSDate *pickerDate = [self.datePicker date];// 获取用户通过UIDatePicker设置的日期和时间
    if (sv.begainTextField == currentTextField) {
        beginDate = [formatter stringFromDate:pickerDate];
    }else {
        endDate = [formatter stringFromDate:pickerDate];
    }
    NSString *dateString = [formatter stringFromDate:pickerDate];
    //打印显示日期时间
    NSLog(@"格式化显示时间：%@",dateString);
    currentTextField.text = [NSString stringWithFormat:@"%@", dateString];
}

- (void)OnTapCancel:(id) sender{
    [currentTextField resignFirstResponder];
    if (sv.begainTextField == currentTextField || sv.endTextField == currentTextField) {
        self.datePicker.date = [NSDate date];
        currentTextField.text = @"";
    }
}

-(void)OnTapDone:(id) sender {
    [currentTextField resignFirstResponder];
    if (sv.begainTextField == currentTextField) {
        if (beginDate.length == 0) {
            beginDate = [formatter stringFromDate:[NSDate date]];
        }
        sv.begainTextField.text = beginDate;
    }else {
        if (endDate.length == 0) {
            endDate = [formatter stringFromDate:[NSDate date]];
        }
        sv.endTextField.text = endDate;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)addGesture {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [_maskView addGestureRecognizer:recognizer];
}

- (void)click {
    [UIView animateWithDuration:0.4 animations:^{
        _maskView.alpha = 0;
        sv.frame = CGRectMake(sv.frame.origin.x, -310, CGRectGetWidth(sv.frame),  170);
    }completion:^(BOOL finished) {
        _maskView.hidden = YES;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WS(ws);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initData];
    [self addGesture];
    [self initToolBar];
    [self initDatePicker];
    [self initHeader];
    [self getOrderList];
    
    sv = [[[NSBundle mainBundle] loadNibNamed:@"SearchView" owner:self options:nil] lastObject];
    sv.frame = CGRectMake(0, -310, CGRectGetWidth([UIScreen mainScreen].bounds), 170);
    __block UIDatePicker *bPicker = _datePicker;
    __block NSDateFormatter *bFormatter = formatter;
    __weak SearchView *weakSv = sv;
    sv.getCurrentTextField = ^(UITextField *textField) {
        currentTextField = textField;
        if (textField.text.length > 0) {
            if (weakSv.begainTextField == currentTextField) {
                beginDate = textField.text;
            }else {
                endDate = textField.text;
            }
            bPicker.date = [bFormatter dateFromString:textField.text];
        }
    };
    sv.searchClick = ^(NSMutableDictionary *dict) {
        if (dict.allKeys.count == 0) {
            [ZAActivityBar showErrorWithStatus:@"必须选择一个订单类型"];
        }else {
            myOrderPageIndex = 0;
            beginDate = weakSv.begainTextField.text;
            endDate = weakSv.endTextField.text;
            orderTypeInfo = dict;
            [ws getOrderList];
        }
    };
    [self.view addSubview:sv];
    sv.begainTextField.inputAccessoryView = _accessoryView;
    sv.endTextField.inputAccessoryView = _accessoryView;
    sv.begainTextField.inputView = _datePicker;
    sv.endTextField.inputView = _datePicker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"查询";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self addRightBtn];
}

- (void)addRightBtn {
    UIButton *rightBtn = nil;
    if (click == 0) {
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 18.5, 18.5);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"筛选"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(otherClick) forControlEvents:UIControlEventTouchUpInside];
    }else {
        rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 18.5, 18.5);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"order_扫一扫-普通"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    }    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = barBtn;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)myOrderClick:(id)sender {
    click = 0;
    [self addRightBtn];
    if (myOrderArray.count == 0) {
        myOrderPageIndex = 0;
        [self getOrderList];
    }else {
        [_orderTable hiddenEmpty];
        records = myOrderArray;
        [_orderTable selectRowAtIndexPath:myOrderIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        [_orderTable reloadData];
    }
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    _lineV.frame = CGRectMake(_myOrderBtn.frame.origin.x, _lineV.frame.origin.y, _lineV.frame.size.width, _lineV.frame.size.height);
    [UIView commitAnimations];
    [_myOrderBtn setTitleColor:UIColorFromRGB(0x2878d2) forState:UIControlStateNormal];
    [_otherOrderBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
}

- (IBAction)otherOrderClick:(id)sender {
    click = 1;
    [self addRightBtn];
    if (otherOrderArray.count == 0) {
        otherOrderPageIndex = 0;
        [self getOrderList];
    }else {
        [_orderTable hiddenEmpty];
        records = otherOrderArray;
        [_orderTable selectRowAtIndexPath:otherOrderIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
        [_orderTable reloadData];
    }
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.3];
    //    _lineConstraint.constant = _ncompleteBtn.frame.origin.x;
    _lineV.frame = CGRectMake(_otherOrderBtn.frame.origin.x, _lineV.frame.origin.y, _lineV.frame.size.width, _lineV.frame.size.height);
    [UIView commitAnimations];
    [_myOrderBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateNormal];
    [_otherOrderBtn setTitleColor:UIColorFromRGB(0x2878d2) forState:UIControlStateNormal];
}

- (void)scanClick {
    ScanningRecognizeViewController *srvc = [[ScanningRecognizeViewController alloc] init];
    srvc.passCarLince = ^(NSString *lince) {
        carNum = [lince substringFromIndex:2];
        otherOrderPageIndex = 0;
        [self getOrderList];
    };
    [self.navigationController pushViewController:srvc animated:YES];
}

- (void)otherClick {
    if (_maskView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            _maskView.alpha = 0.5;
            sv.frame = CGRectMake(sv.frame.origin.x, 0, CGRectGetWidth([UIScreen mainScreen].bounds),  170);
        }completion:^(BOOL finished) {
            _maskView.hidden = NO;
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            _maskView.alpha = 0;
            sv.frame = CGRectMake(sv.frame.origin.x, -310, CGRectGetWidth([UIScreen mainScreen].bounds),  170);
        }completion:^(BOOL finished) {
            _maskView.hidden = YES;
        }];
    }
}

#pragma mark - request

- (void)getOrderList{
    int pageIndex;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
//    NSString *storeId = userInfo[@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"PageSize":[NSString stringWithFormat:@"%d",pageSize],@"ServiceConsultantID":userId};
    NSMutableDictionary *mutPar = [parameters mutableCopy];
    if (beginDate.length > 0 && endDate.length > 0) {
        [mutPar setObject:beginDate forKey:@"StarDate"];
        [mutPar setObject:endDate forKey:@"EndDate"];
    }
//    carNum = @"台Y-36915";
    if (click == 0) {
        [ZAActivityBar showWithStatus:LODING_MSG];
        myOrderPageIndex++;
        pageIndex = myOrderPageIndex;
    }else {
        if (carNum.length > 0) {
            [ZAActivityBar showWithStatus:LODING_MSG];
            [mutPar setObject:carNum forKey:@"Key"];
            otherOrderPageIndex++;
            pageIndex = otherOrderPageIndex;
        }else {
            [records removeAllObjects];
            [_orderTable reloadData];
            [_orderTable showEmpty];
            return;
        }
    }
    [mutPar setObject:[NSString stringWithFormat:@"%d",pageIndex] forKey:@"PageIndex"];
    if (orderTypeInfo) {
        NSMutableString *mustr = [[NSMutableString alloc] init];
        NSArray *array = orderTypeInfo.allKeys;
        for (int i = 0; i < array.count; i++) {
            NSString *key = array[i];
            NSString *value = orderTypeInfo[key];
            [mustr appendString:value];
            if ((i + 1) < array.count) {
                [mustr appendString:@","];
            }
        }
        [mutPar setObject:mustr forKey:@"TypeList"];
    }else {
        [mutPar setObject:@"\'项目结算单\',\'商品零售单\',\'维修单\',\'洗车单\',\'增项单\'" forKey:@"TypeList"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetSaleList];
    [manager POST:url parameters:mutPar success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            NSDictionary *dict = [responseObject objectForKey:@"Result"];
            if (pageIndex == 1) {
                if (click == 0) {
                    [myOrderArray removeAllObjects];
                }else {
                    [otherOrderArray removeAllObjects];
                }
            }
            if (click == 0) {
                if (dict.allKeys.count > 0) {
                    totalRecordsMyOrder = [responseObject[@"Result"][@"TotalRecords"] intValue];
                    [myOrderArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Sales"]];
                }
                records = myOrderArray;
            }else {
                if (dict.allKeys.count > 0) {
                    totalRecordsOtherOrder = [responseObject[@"Result"][@"TotalRecords"] intValue];
                    [otherOrderArray addObjectsFromArray:[[responseObject objectForKey:@"Result"] objectForKey:@"Sales"]];
                }
                records = otherOrderArray;
            }
            if (!_maskView.hidden) {
                [self otherClick];
            }
            if (records.count == 0) {
                [_orderTable showEmpty];
                [ZAActivityBar showErrorWithStatus:@"查无数据"];
            }else {
                [_orderTable hiddenEmpty];
                [ZAActivityBar dismiss];
            }
            if (myOrderPageIndex == 1) {
                [_orderTable.header endRefreshing];
            }else {
                [_orderTable.footer endRefreshing];
            }
            [_orderTable reloadData];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return records.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = records[indexPath.row];
    cell.orderType.text = [NSString stringWithFormat:@"订单类型：%@",dict[@"OrderName"]];
    cell.cpnL.text = [NSString stringWithFormat:@"客户车辆：%@",dict[@"LicenNum"]];
    cell.ordernL.text = dict[@"MentNo"];
    float pricef = [dict[@"TotalPay"] floatValue];
    NSString *price = [NSString stringWithFormat:@"总计：￥%.2f",floorf(pricef * 100)/100];
    cell.priceL.text = price;
    cell.ordertL.text = [dict[@"BillingDate"] substringWithRange:NSMakeRange(0, 10)];
    cell.ifCompleteL.text = dict[@"Status"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderDetailViewController *odvc = [[OrderDetailViewController alloc] initWithNibName:@"OrderDetailViewController" bundle:nil];
    NSDictionary *dict = nil;
    dict = records[indexPath.row];
    odvc.orderName = dict[@"OrderName"];
    odvc.orderId = dict[@"Id"];
    [self.navigationController pushViewController:odvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 93;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (click == 1) {
        myOrderIndex = indexPath;
        if (indexPath.row == (myOrderArray.count - 1) && myOrderArray.count != totalRecordsMyOrder) {
            [self getOrderList];
        }
        if (indexPath.row == (myOrderArray.count - 1) && myOrderArray.count == totalRecordsMyOrder) {
            [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
        }
    }else {
        otherOrderIndex = indexPath;
        if (indexPath.row == (otherOrderArray.count - 1)  && otherOrderArray.count != totalRecordsOtherOrder) {
            [self getOrderList];
        }
        if (indexPath.row == (otherOrderArray.count - 1) && otherOrderArray.count == totalRecordsOtherOrder) {
            [ZAActivityBar showErrorWithStatus:@"已经到达最后一页!"];
        }
    }
}

@end
