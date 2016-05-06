//
//  SearchPickUpViewController.m
//  StoreReception
//
//  Created by cjm-ios on 16/3/7.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "SearchPickUpViewController.h"
#import "SearchPickUpView.h"
#import "SearchPickUpTableViewCell.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+empty.h"
#import <MJRefresh/MJRefresh.h>
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
static NSString *cellId = @"sptcellId";
static int pageSize = 20;

@interface SearchPickUpViewController () {
    NSMutableArray *records;
    SearchPickUpView *spuv;
    NSString *beginDate;
    NSString *endDate;
    NSDateFormatter *formatter;
    NSString *currentDate;
    UITextField *currentTextField;
    int pageIndex;
}

@end

@implementation SearchPickUpViewController

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"选择单据";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 18.5, 18.5);
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"筛选"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(otherClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)addGesture {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [_maskView addGestureRecognizer:recognizer];
}

- (void)click {
    [UIView animateWithDuration:0.4 animations:^{
        _maskView.alpha = 0;
        spuv.frame = CGRectMake(spuv.frame.origin.x, -288, CGRectGetWidth(spuv.frame),  144);
    }completion:^(BOOL finished) {
        _maskView.hidden = YES;
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
    /**
    *  设置只显示中文*/
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
    if (spuv.startField == currentTextField) {
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
    if (spuv.startField == currentTextField || spuv.endField == currentTextField) {
        self.datePicker.date = [NSDate date];
        currentTextField.text = @"";
    }
}

-(void)OnTapDone:(id) sender {
    [currentTextField resignFirstResponder];
    if (spuv.startField == currentTextField) {
        if (beginDate.length == 0) {
            beginDate = [formatter stringFromDate:[NSDate date]];
        }
        spuv.startField.text = beginDate;
    }else {
        if (endDate.length == 0) {
            endDate = [formatter stringFromDate:[NSDate date]];
        }
        spuv.endField.text = endDate;
    }
}

- (void)initData {
    beginDate = @"";
    endDate = @"";
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    currentDate = [formatter stringFromDate:[NSDate date]];
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
    records = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"SearchPickUpTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:cellId];
    [self initHeader];
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [records removeAllObjects];
        pageIndex = 0;
        [ws repairItemDesc];
    }];
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [ws repairItemDesc];
    }];
    spuv = [[[NSBundle mainBundle] loadNibNamed:@"SearchPickUpView" owner:self options:nil] lastObject];
    spuv.frame = CGRectMake(0, -288, CGRectGetWidth([UIScreen mainScreen].bounds), 144);
    spuv.startField.inputAccessoryView = _accessoryView;
    spuv.endField.inputAccessoryView = _accessoryView;
    spuv.startField.inputView = _datePicker;
    spuv.endField.inputView = _datePicker;
    [self.view addSubview:spuv];
    __block UIDatePicker *bPicker = _datePicker;
    __block NSDateFormatter *bFormatter = formatter;
    __weak SearchPickUpView *weakSpuv = spuv;
    spuv.getCurrentTextField = ^(UITextField *textField) {
        currentTextField = textField;
        if (textField.text.length > 0) {
            if (weakSpuv.startField == currentTextField) {
                beginDate = textField.text;
            }else {
                endDate = textField.text;
            }
            bPicker.date = [bFormatter dateFromString:textField.text];
        }
    };
    spuv.searchClick = ^(void) {
        beginDate = weakSpuv.startField.text;
        endDate = weakSpuv.endField.text;
        [weakSpuv.userNameField resignFirstResponder];
        [weakSpuv.startField resignFirstResponder];
        [weakSpuv.endField resignFirstResponder];
        pageIndex = 0;
        [ws repairItemDesc];
    };
    [self repairItemDesc];
}


- (void)otherClick {
    if (_maskView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            spuv.userNameField.text = @"";
            _maskView.alpha = 0.5;
            spuv.frame = CGRectMake(spuv.frame.origin.x, 0, CGRectGetWidth([UIScreen mainScreen].bounds),  144);
        }completion:^(BOOL finished) {
            _maskView.hidden = NO;
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            _maskView.alpha = 0;
            spuv.frame = CGRectMake(spuv.frame.origin.x, -288, CGRectGetWidth([UIScreen mainScreen].bounds),  144);
        }completion:^(BOOL finished) {
            _maskView.hidden = YES;
        }];
    }
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return records.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchPickUpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (records.count > 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dict = records[indexPath.row];
        cell.carNumL.text = [NSString stringWithFormat:@"车牌号码：%@",dict[@"LicenNum"]];
        cell.userNameL.text = [NSString stringWithFormat:@"客户名称：%@",dict[@"MemberName"]];
        cell.orderStateL.text = @"施工中";
        cell.serviceL.text = dict[@"ServerConsultant"];
        cell.orderIdL.text = dict[@"ConNo"];
        cell.orderTimeL.text = dict[@"PickupCarTime"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = records[indexPath.row];
    if (_passValue) {
        _passValue(info);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

#pragma mark - request
- (void)repairItemDesc {
    pageIndex++;
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreId":storeId,@"pageIndex":[NSString stringWithFormat:@"%d",pageIndex],@"pageSize":[NSString stringWithFormat:@"%d",pageSize],@"StarDate":spuv.startField.text,@"EndDate":spuv.endField.text,@"ServiceConsultantID":userId};
    NSMutableDictionary *muPar = [parameters mutableCopy];
    if (spuv.userNameField.text.length > 0) {
        [muPar setObject:spuv.userNameField.text forKey:@"Key"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,RepairingList];
    [manager POST:url parameters:muPar success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            id info = responseObject[@"Result"][@"repairCarList"];
            if ([info isKindOfClass:[NSArray class]]) {
                if (pageIndex == 1) {
                    [records removeAllObjects];
                }
                NSArray *infoT = info;
                if (infoT.count > 0) {
                    [records addObjectsFromArray:info];
                    [_tableView reloadData];
                }
                if (!_maskView.hidden) {
                    [self otherClick];
                }
                if (records.count == 0) {
                    [_tableView showEmpty];
                    [ZAActivityBar showErrorWithStatus:@"查无数据"];
                }else {
                    [_tableView hiddenEmpty];
                    [ZAActivityBar dismiss];
                }
            }
            [_tableView.header endRefreshing];
            [_tableView.footer endRefreshing];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
