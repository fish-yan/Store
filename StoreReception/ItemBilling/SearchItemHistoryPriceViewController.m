//
//  SearchItemHistoryPriceViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/23.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "SearchItemHistoryPriceViewController.h"
#import "ToolKit.h"
#import <AFNetworking/AFNetworking.h>
#import "ZAActivityBar.h"
#import "HistoryPriceCell.h"
#import "SearchHistoryPriceView.h"
#import "UIView+empty.h"
static NSString *priceCell = @"priceCell";
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface SearchItemHistoryPriceViewController () {
    NSMutableArray *resultArray;
    int totalRecordsItem;
    NSString *beginDate;
    NSString *endDate;
    NSDateFormatter *formatter;
    NSString *currentDate;
    UITextField *currentTextField;
    int pageIndex;
    int pageSize;
    SearchHistoryPriceView *sv;
}

@end

@implementation SearchItemHistoryPriceViewController

- (void)initData {
    resultArray = [[NSMutableArray alloc] init];
    pageIndex = 0;
    pageSize = 20;
    beginDate = @"";
    endDate = @"";
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    currentDate = [formatter stringFromDate:[NSDate date]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    WS(ws);
    [self initData];
    [self addGesture];
    [self initToolBar];
    [self initDatePicker];
    [self initHeader];
    UINib *nib = [UINib nibWithNibName:@"HistoryPriceCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:priceCell];
    sv = [[[NSBundle mainBundle] loadNibNamed:@"SearchHistoryPriceView" owner:self options:nil] lastObject];
    sv.frame = CGRectMake(0, -300, CGRectGetWidth([UIScreen mainScreen].bounds), 94);
    __block UIDatePicker *bPicker = _datePicker;
    __block NSDateFormatter *bFormatter = formatter;
    __weak SearchHistoryPriceView *weakSv = sv;
    sv.getCurrentTextField = ^(UITextField *textField) {
        currentTextField = textField;
        if (textField.text.length > 0) {
            if (weakSv.beginTextField == currentTextField) {
                beginDate = textField.text;
            }else {
                endDate = textField.text;
            }
            bPicker.date = [bFormatter dateFromString:textField.text];
        }
    };
    sv.searchClick = ^(void) {
        pageIndex = 0;
        beginDate = weakSv.beginTextField.text;
        endDate = weakSv.endTextField.text;
        [ws getHistoryPrice];
    };
    [self.view addSubview:sv];
    sv.beginTextField.inputAccessoryView = _accessoryView;
    sv.endTextField.inputAccessoryView = _accessoryView;
    sv.beginTextField.inputView = _datePicker;
    sv.endTextField.inputView = _datePicker;
    [self getHistoryPrice];
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
    if (sv.beginTextField == currentTextField) {
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
    if (sv.beginTextField == currentTextField || sv.endTextField == currentTextField) {
        self.datePicker.date = [NSDate date];
        currentTextField.text = @"";
    }
}

-(void)OnTapDone:(id) sender {
    [currentTextField resignFirstResponder];
    if (sv.beginTextField == currentTextField) {
        if (beginDate.length == 0) {
            beginDate = [formatter stringFromDate:[NSDate date]];
        }
        sv.beginTextField.text = beginDate;
    }else {
        if (endDate.length == 0) {
            endDate = [formatter stringFromDate:[NSDate date]];
        }
        sv.endTextField.text = endDate;
    }
}

- (void)otherClick {
    if (_maskView.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            _maskView.alpha = 0.5;
            sv.frame = CGRectMake(sv.frame.origin.x, 0, CGRectGetWidth([UIScreen mainScreen].bounds),  94);
        }completion:^(BOOL finished) {
            _maskView.hidden = NO;
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            _maskView.alpha = 0;
            sv.frame = CGRectMake(sv.frame.origin.x, -300, CGRectGetWidth([UIScreen mainScreen].bounds),  94);
        }completion:^(BOOL finished) {
            _maskView.hidden = YES;
        }];
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
        sv.frame = CGRectMake(sv.frame.origin.x, -300, CGRectGetWidth(sv.frame),  94);
    }completion:^(BOOL finished) {
        _maskView.hidden = YES;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"商品历史销售查询";
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
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryPriceCell *cell = [_tableView dequeueReusableCellWithIdentifier:priceCell];
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *info = resultArray[indexPath.row];
    cell.linceL.text = [ToolKit getStringVlaue:info[@"licennum"]];
    cell.timeL.text = [ToolKit getStringVlaue:info[@"setttime"]];
    cell.userNameL.text = [ToolKit getStringVlaue:info[@"membername"]];
    cell.itemNameL.text = [ToolKit getStringVlaue:info[@"productname"]];
    float acount = [[ToolKit getStringVlaue:info[@"salenum"]]floatValue];
    cell.saleNumL.text = [NSString stringWithFormat:@"%f",acount];
    cell.price.text = [ToolKit getStringVlaue:info[@"taxsaleprice"]];
    cell.salerL.text = [ToolKit getStringVlaue:info[@"shopname"]];
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147;
}


#pragma mark - request
- (void)getHistoryPrice {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
//    NSString *memberId = carInfo[@"MemberId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSString *storeId = userInfo[@"StoreId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"StockNo":_info[@"StockNo"],@"StoreId":storeId,@"CompanyId":companyId};
    NSMutableDictionary *mutDict = [parameters mutableCopy];
    if (beginDate > 0 && endDate > 0) {
        [mutDict setObject:beginDate forKeyedSubscript:@"StarDate"];
        [mutDict setObject:endDate forKeyedSubscript:@"EndDate"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetProSellList];
    [manager POST:url parameters:mutDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [resultArray removeAllObjects];
            NSLog(@"result:   %@",responseObject);
            id tmp = [responseObject objectForKey:@"Result"];
            if ([tmp isKindOfClass:[NSArray class]]) {
                [resultArray addObjectsFromArray:tmp];
            }
            if (!_maskView.hidden) {
                [self otherClick];
            }
            [_tableView reloadData];
            if (resultArray.count == 0) {
                [_tableView showEmpty];
            }else {
                [_tableView hiddenEmpty];
            }
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
