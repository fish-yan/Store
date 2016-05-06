//
//  InputMsgViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/8/11.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "InputMsgViewController.h"
#import "InputMsgTableViewCell.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ToolKit.h"
#import "NoticeTableViewCell.h"
#import "TSLocateView.h"
#import "LinceNumTableViewCell.h"
#import "SearchUserViewController.h"

static NSString *inputCellID = @"inputCellID";
static NSString *noticeCellID = @"noticeCellID";
static NSString *linceCellID = @"linceCellID";
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface InputMsgViewController () {
    BOOL hiddenBol;
    NSMutableDictionary *baseInfos;
    NSMutableDictionary *carInfos;
    NSMutableDictionary *insurtanceInfos;
    NSMutableDictionary *menberInfos;
    NSMutableDictionary *serviceInfos;
    float keyboardHeight;
    BOOL keyboardIsShowing;
    NSDictionary *result;
    InputMsgTableViewCell *currentCell;
    NSMutableArray *brands;
    NSMutableArray *brandNames;
    NSMutableArray *serines;
    NSMutableArray *serineNames;
    NSMutableArray *cars;
    NSMutableArray *carNames;
    TSLocateView *brandView;
    TSLocateView *serineView;
    TSLocateView *carView;
    TSLocateView *carTypeView;
    TSLocateView *memberView;
    TSLocateView *memberMethodView;
    TSLocateView *certificateTypeView;
    TSLocateView *blowsView;
    NSArray *array_carType;
    NSMutableArray *carTypes;
    NSArray *array_member;
    NSMutableArray *members;
    NSArray *array_memberMethod;
    NSMutableArray *memberMethods;
    NSArray *array_certificateType;
    NSMutableArray *certificateTypes;
    NSArray *array_blow;
    NSMutableArray *blows;
    NSString *currentDate;
    NSDateFormatter* formatter;
    NSString *dateString;
    NSString *memberId;
    NSArray *carInfoParmaterArray;
    NSArray *baseInfoParmaterArray;
    NSArray *insurtanceInfoParmaterArray;
    NSArray *menberInfoParmaterArray;
    NSArray *serviceInfoParmaterArray;
    BOOL ifInfoBol;
}


@end

@implementation InputMsgViewController

- (void)initData {
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    currentDate = [formatter stringFromDate:[NSDate date]];
    carTypes = [[NSMutableArray alloc] init];
    members = [[NSMutableArray alloc] init];
    memberMethods = [[NSMutableArray alloc] init];
    certificateTypes = [[NSMutableArray alloc] init];
    blows = [[NSMutableArray alloc] init];
    baseInfos = [[NSMutableDictionary alloc] init];
    carInfos = [[NSMutableDictionary alloc] init];
    insurtanceInfos = [[NSMutableDictionary alloc] init];
    menberInfos = [[NSMutableDictionary alloc] init];
    serviceInfos = [[NSMutableDictionary alloc] init];
    [self getBrand];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath_carType = [bundle pathForResource:@"carType" ofType:@"plist"];
    array_carType = [[NSArray alloc] initWithContentsOfFile:plistPath_carType];
    NSString *plistPath_member = [bundle pathForResource:@"member" ofType:@"plist"];
    array_member = [[NSArray alloc] initWithContentsOfFile:plistPath_member];
    NSString *plistPath_memberMethod = [bundle pathForResource:@"memberMethod" ofType:@"plist"];
    array_memberMethod = [[NSArray alloc] initWithContentsOfFile:plistPath_memberMethod];
    NSString *plistPath_certificateType = [bundle pathForResource:@"certificateType" ofType:@"plist"];
    array_certificateType = [[NSArray alloc] initWithContentsOfFile:plistPath_certificateType];
    NSString *plistPath_blows = [bundle pathForResource:@"blows" ofType:@"plist"];
    array_blow = [[NSArray alloc] initWithContentsOfFile:plistPath_blows];
    for (NSDictionary *info in array_carType) {
        NSString *name = info[@"name"];
        [carTypes addObject:name];
    }
    for (NSDictionary *info in array_member) {
        NSString *name = info[@"name"];
        [members addObject:name];
    }
    for (NSDictionary *info in array_memberMethod) {
        NSString *name = info[@"name"];
        [memberMethods addObject:name];
    }
    for (NSDictionary *info in array_certificateType) {
        NSString *name = info[@"name"];
        [certificateTypes addObject:name];
    }
    for (NSDictionary *info in array_blow) {
        NSString *name = info[@"name"];
        [blows addObject:name];
    }
    brands = [[NSMutableArray alloc] init];
    brandNames = [[NSMutableArray alloc] init];
    brandView = [[TSLocateView alloc] initWithTitle:@"品牌" delegate:self];
    serineView = [[TSLocateView alloc] initWithTitle:@"系列" delegate:self];
    carView = [[TSLocateView alloc] initWithTitle:@"车型" delegate:self];
    carTypeView = [[TSLocateView alloc] initWithTitle:@"会员卡类型" delegate:self];
    [carTypeView initData:carTypes];
    memberView = [[TSLocateView alloc] initWithTitle:@"会员类型" delegate:self];
    [memberView initData:members];
    memberMethodView = [[TSLocateView alloc] initWithTitle:@"入会方式" delegate:self];
    [memberMethodView initData:memberMethods];
    certificateTypeView = [[TSLocateView alloc] initWithTitle:@"证件类型" delegate:self];
    [certificateTypeView initData:certificateTypes];
    blowsView = [[TSLocateView alloc] initWithTitle:@"证件类型" delegate:self];
    [blowsView initData:blows];
    __weak TSLocateView *weakSerineView = serineView;
    __weak TSLocateView *weakCarView = carView;
    brandView.passValue = ^(NSInteger row) {
        if (brandRow != row) {
            brandRow = row;
            weakSerineView.cell.titleTextField.text = @"";
            weakSerineView.cell.titleTextField.placeholder = @"请输入";
            weakCarView.cell.titleTextField.text = @"";
            weakCarView.cell.titleTextField.placeholder = @"请输入";
        }
    };
    serineView.passValue = ^(NSInteger row) {
        if (serineRow != row) {
            serineRow = row;
            weakCarView.cell.titleTextField.text = @"";
            weakCarView.cell.titleTextField.placeholder = @"请输入";
        }
    };
    carView.passValue = ^(NSInteger row) {
        if (carRow != row) {
            carRow = row;
        }
    };
    carTypeView.passValue = ^(NSInteger row) {
        if (carTypeRow != row) {
            carTypeRow = row;
        }
    };
    memberView.passValue = ^(NSInteger row) {
        if (memberRow != row) {
            memberRow = row;
        }
    };
    memberMethodView.passValue = ^(NSInteger row) {
        if (memberMethodRow != row) {
            memberMethodRow = row;
        }
    };
    certificateTypeView.passValue = ^(NSInteger row) {
        if (certificateTypeRow != row) {
            certificateTypeRow = row;
        }
    };
    blowsView.passValue = ^(NSInteger row) {
        if (blowRow != row) {
            blowRow = row;
        }
    };
    serines = [[NSMutableArray alloc] init];
    serineNames = [[NSMutableArray alloc] init];
    cars = [[NSMutableArray alloc] init];
    carNames = [[NSMutableArray alloc] init];
}

- (void)initParmaters:(NSMutableDictionary *)infos parmaterArray:(NSArray *)parmaterArray {
    for (int i = 0; i < parmaterArray.count; i++) {
        NSString *key = parmaterArray[i];
        [infos setObject:@"" forKey:key];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initData];
    if (_info) {
        ifInfoBol = YES;
        [self getAdopter];
    }else {
        ifInfoBol = NO;
        _info = [[NSMutableDictionary alloc] init];
        baseInfoParmaterArray = [[NSArray alloc] initWithObjects:@"ADDRESS",@"DRIVERANNUALDATE",@"LEAGUERNAME",@"MOBILE",@"MemberId",@"ZJNUM",@"ZJTYPE", nil];
        carInfoParmaterArray = [[NSArray alloc] initWithObjects:@"CIBLOWDOWN",@"CIBRAND",@"CIBRANDID",@"CISSB",@"CICARID",@"CICARNAME",@"CIMAINTAINTIME",@"CISERIES",@"CISERIESID",@"CISFDJH",@"DOWNNUMBER",@"ISSUEDATE",@"OWNER",@"VEHICLECHECK",@"ZCRQ", nil];
        insurtanceInfoParmaterArray = [[NSArray alloc] initWithObjects:@"BUSINESSRISKSTIME",@"INSURANCENAME",@"STRONGRISKTIME", nil];
        menberInfoParmaterArray = [[NSArray alloc] initWithObjects:@"BAKEIGHT",@"BAKFOUR",@"BAKSEVEN",@"CARNUMBER",@"JOINMODE",@"LOGOUTTIME",@"REGTIME", nil];
        serviceInfoParmaterArray = [[NSArray alloc] initWithObjects:@"CLIENTMANAGERID",@"CLIENTMANAGER",@"ISSMS",@"LEAGUERLINKER",@"STORESID",@"STORESNAME", nil];
        [self initParmaters:baseInfos parmaterArray:baseInfoParmaterArray];
        [self initParmaters:carInfos parmaterArray:carInfoParmaterArray];
        [self initParmaters:menberInfos parmaterArray:menberInfoParmaterArray];
        [self initParmaters:serviceInfos parmaterArray:serviceInfoParmaterArray];
        [self initParmaters:insurtanceInfos parmaterArray:insurtanceInfoParmaterArray];
    }
    
    [self initToolBar];
    [self initDatePicker];
//    _tableView.tableHeaderView = _headerView;
    _tableView.tableFooterView = _footerView;
//    UINib *inputNib = [UINib nibWithNibName:@"InputMsgTableViewCell" bundle:nil];
//    [_tableView registerNib:inputNib forCellReuseIdentifier:inputCellID];
    UINib *linceNib = [UINib nibWithNibName:@"LinceNumTableViewCell" bundle:nil];
    [_tableView registerNib:linceNib forCellReuseIdentifier:linceCellID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextClick:(id)sender {
    if ([self checkMustData]) {
        if ([self checkValidata:carInfos] && [self checkValidata:baseInfos] && [self checkValidata:insurtanceInfos] && [self checkValidata:menberInfos] && [self checkValidata:serviceInfos]) {
            NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
            NSString *userId = [userInfo objectForKey:@"UserId"];
            NSString *_userId = [ToolKit getStringVlaue:serviceInfos[@"CLIENTMANAGERID"]];
            if (_userId.length == 0) {
                [serviceInfos setObject:userId forKey:@"CLIENTMANAGERID"];
            }
            [self addAdopter];
        }else {
            [serviceInfos setObject:@"" forKey:@"CLIENTMANAGERID"];
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"会员信息填写不完整，该客户不能领养，是否继续保存" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存", nil];
            [alerView show];
        }
    }
}

- (IBAction)hiddenClick:(id)sender {
    hiddenBol = !hiddenBol;
    UIButton *btn = (UIButton *)sender;
    if (hiddenBol) {
        [btn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [btn setBackgroundImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
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
    dateString = [formatter stringFromDate:pickerDate];
    //打印显示日期时间
    NSLog(@"格式化显示时间：%@",dateString);
    currentCell.titleTextField.text = [NSString stringWithFormat:@"%@", dateString];
}

- (void)OnTapCancel:(id) sender{
    if (currentTag == 1001 || currentTag == 1002 || currentTag == 1003) {
        [currentCell.selectedTextField resignFirstResponder];
    }
    [currentCell.titleTextField resignFirstResponder];
    switch (currentTag) {
        case 100:
        {
            NSString *value = menberInfos[@"BAKEIGHT"];
            currentCell.titleTextField.text = [self getKeyValue:value array:array_carType];
        }
            break;
        case 101:
        {
            NSString *value = menberInfos[@"BAKSEVEN"];
            currentCell.titleTextField.text = [self getKeyValue:value array:array_member];
        }
            break;
        case 102:
        {
            NSString *value = menberInfos[@"JOINMODE"];
            currentCell.titleTextField.text = [self getKeyValue:value array:array_memberMethod];
        }
            break;
            break;
        default:
            break;
    }
}

-(void)OnTapDone:(id) sender {
    if (currentTag == 1001 || currentTag == 1002 || currentTag == 1003) {
        [currentCell.selectedTextField resignFirstResponder];
    }
    [currentCell.titleTextField resignFirstResponder];
    _datePicker.date = [NSDate date];
    if (dateString.length == 0) {
        dateString = [formatter stringFromDate:[NSDate date]];
    }
    switch (currentTag) {
        case 100:
        {
            NSDictionary *info = array_carType[carTypeRow];
            NSString *name = info[@"name"];
            NSString *bid =  info[@"id"];
            carTypeView.cell.titleTextField.text = name;
            [menberInfos setObject:bid forKey:@"BAKEIGHT"];
        }
            break;
        case 101:
        {
            NSDictionary *info = array_member[memberRow];
            NSString *name = info[@"name"];
            NSString *bid =  info[@"id"];
            memberView.cell.titleTextField.text = name;
            [menberInfos setObject:bid forKey:@"BAKSEVEN"];
        }
            break;
        case 102:
        {
            NSDictionary *info = array_memberMethod[memberMethodRow];
            NSString *name = info[@"name"];
            NSString *bid =  info[@"id"];
            memberMethodView.cell.titleTextField.text = name;
            [menberInfos setObject:bid forKey:@"JOINMODE"];
        }
            break;
        case 103:
        {
            currentCell.titleTextField.text = dateString;
            [menberInfos setObject:dateString forKey:@"REGTIME"];
        }
            break;
        case 104:
        {
            currentCell.titleTextField.text = dateString;
            [menberInfos setObject:dateString forKey:@"LOGOUTTIME"];
        }
            break;
        case 201:
        {
            NSDictionary *info = array_certificateType[certificateTypeRow];
            NSString *name = info[@"name"];
            NSString *bid =  info[@"id"];
            certificateTypeView.cell.titleTextField.text = name;
            [baseInfos setObject:bid forKey:@"ZJTYPE"];
        }
            break;
        case 202:
        {
            currentCell.titleTextField.text = dateString;
            [baseInfos setObject:dateString forKey:@"DRIVERANNUALDATE"];
        }
            break;
        case 1001:
        {
            if (brands.count > 0) {
                NSDictionary *info = brands[brandRow];
                NSString *name = info[@"CARBRANDCHN"];
                NSString *bid =  info[@"ID"];
                brandView.cell.titleTextField.text = name;
                brandName = name;
                brandId = bid;
                serineView.cell.selectedTextField.enabled = YES;
                [carInfos setObject:bid forKey:@"CIBRANDID"];
                [carInfos setObject:name forKey:@"CIBRAND"];
                [self getSerinesByBrand];
            }
        }
            break;
        case 1002:
        {
            if (serines.count > 0) {
                NSDictionary *info = serines[serineRow];
                NSString *name = info[@"CARSERIESNAME"];
                NSString *bid =  info[@"ID"];
                serineView.cell.titleTextField.text = name;
                serineName = name;
                serineId = bid;
                carView.cell.selectedTextField.enabled = YES;
                [carInfos setObject:bid forKey:@"CISERIESID"];
                [carInfos setObject:name forKey:@"CISERIES"];
                [self getCarName];
            }
        }
            break;
        case 1003:
        {
            if (cars.count > 0) {
                NSDictionary *info = cars[carRow];
                NSString *name = info[@"CARMODELNAME"];
                NSString *bid =  info[@"ID"];
                carView.cell.titleTextField.text = name;
                carName = name;
                carId = bid;
                [carInfos setObject:bid forKey:@"CICARID"];
                [carInfos setObject:name forKey:@"CICARNAME"];
                [self getCarName];
            }
        }
            break;
        case 1004:
        {
            NSDictionary *info = array_blow[blowRow];
            NSString *name = info[@"name"];
            NSString *bid =  info[@"id"];
            blowsView.cell.titleTextField.text = name;
            [carInfos setObject:bid forKey:@"CIBLOWDOWN"];
        }
            break;
        case 1005:
        {
            currentCell.titleTextField.text = dateString;
            [carInfos setObject:dateString forKey:@"ZCRQ"];
        }
            break;
        case 1006:
        {
            currentCell.titleTextField.text = dateString;
            [carInfos setObject:dateString forKey:@"ISSUEDATE"];
        }
            break;
        case 1007:
        {
            currentCell.titleTextField.text = dateString;
            [carInfos setObject:dateString forKey:@"VEHICLECHECK"];
        }
            break;
        case 1008:
        {
            currentCell.titleTextField.text = dateString;
            [carInfos setObject:dateString forKey:@"CIMAINTAINTIME"];
        }
            break;
        case 2001:
        {
            currentCell.titleTextField.text = dateString;
            [insurtanceInfos setObject:dateString forKey:@"BUSINESSRISKSTIME"];
        }
            break;
        case 2002:
        {
            currentCell.titleTextField.text = dateString;
            [insurtanceInfos setObject:dateString forKey:@"STRONGRISKTIME"];
        }
            break;
        default:
            break;
    }
    dateString = @"";
}

- (NSString *)getKeyValue:(NSString *)value array:(NSArray *)array{
    NSString *name = @"";
    for (NSDictionary *info in array) {
        NSString *bid = info[@"id"];
        if ([value isEqualToString:bid]) {
            name = info[@"name"];
        }
    }
    return name;
}

//初始化PickerView使用的数据源
-(void)initPicker{
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), 216)];
    //    指定Delegate
    _pickerView.delegate=self;
    //    显示选中框
    _pickerView.showsSelectionIndicator=YES;
    [self.view addSubview:_pickerView];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"添加领养人";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) keyboardWillShow:(NSNotification *)note {
    if (!keyboardIsShowing) {
        keyboardIsShowing = YES;
        NSDictionary *userInfo = [note userInfo];
        NSTimeInterval animationDuration = [[userInfo
                                             
                                             objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        keyboardHeight = keyboardRect.size.height;
        CGRect frame = _tableView.frame;
        frame.size.height -= (keyboardHeight + 52);
        [UIView animateWithDuration:animationDuration animations:^{
            CGRect keyboardBounds = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, 0, keyboardBounds.size.height, 0);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if (!keyboardIsShowing) {
        return;
    }
    keyboardIsShowing = NO;
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, 0, 0, 0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getBrandId {
    for (int i = 0; i < brands.count; i++) {
        NSDictionary *dict = brands[i];
        NSString *bid = dict[@"CIBRANDID"];
        if ([bid isEqualToString:brandId]) {
            break;
        }
    }
}

- (void)getSerineId {
    for (int i = 0; i < serines.count; i++) {
        NSDictionary *dict = serines[i];
        NSString *sid = dict[@"CISERIESID"];
        if ([sid isEqualToString:serineId]) {
            break;
        }
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 7;
    }else if (section == 1) {
        return 6;
    }else if (section == 2) {
        return 12;//多传了三个参数，分别为品牌，系列和车型的名称，方便数据展示
    }else if (section == 3) {
        return 3;
    }else {
        return 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        LinceNumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:linceCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        __weak LinceNumTableViewCell *weakCell = cell;
        if (!ifInfoBol) {
            cell.subStTextField.enabled = YES;
            cell.stTextField.enabled = YES;
        }else {
            cell.subStTextField.enabled = NO;
            cell.stTextField.enabled = NO;
            NSString *lince = menberInfos[@"CARNUMBER"];
            NSString *headerLince = [lince substringToIndex:2];
            NSString *endLince = [lince substringFromIndex:3];
            cell.subStTextField.text = endLince;
            cell.stTextField.text = headerLince;
        }
        cell.noticeText = ^(void) {
            NSString *subText = weakCell.subStTextField.text.uppercaseString;
            NSString *text = weakCell.stTextField.text.uppercaseString;
            if (subText.length > 0 && text.length > 0) {
                NSString *licenNum = @"";
                if (![text isEqualToString:@"军牌"]) {
                    licenNum = [NSString stringWithFormat:@"%@-%@",text,subText];
                }else {
                    licenNum = subText;
                }
                [menberInfos setObject:licenNum forKey:@"CARNUMBER"];
            }
        };
        return cell;
    }else {
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        InputMsgTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"InputMsgTableViewCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        __weak InputMsgTableViewCell *weakCell = cell;
        cell.titleTextField.enabled = YES;
        cell.selectedTextField.hidden = YES;
        cell.titleTextField.inputAccessoryView = nil;
        cell.titleTextField.inputView = nil;
        cell.noticeEdit = ^(void) {
            currentCell = weakCell;
        };
        cell.markL.hidden = YES;
        NSString *value = @"";
        if (indexPath.section == 0) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                cell.iconImgV.hidden = YES;
                cell.titleTextField.placeholder = @"请输入";
            }else {
                cell.iconImgV.hidden = NO;
                cell.titleTextField.placeholder = @"请选择";
                cell.titleTextField.inputAccessoryView = _accessoryView;
                if (indexPath.row != 2 && indexPath.row != 3 && indexPath.row != 4) {
                    cell.titleTextField.inputView = _datePicker;
                }else if (indexPath.row == 2) {
                    carTypeView.cell = cell;
                    cell.titleTextField.inputView = carTypeView;
                }else if (indexPath.row == 3) {
                    memberView.cell = cell;
                    cell.titleTextField.inputView = memberView;
                }else {
                    memberMethodView.cell = cell;
                    cell.titleTextField.inputView = memberMethodView;
                }
            }
            if (indexPath.row == 0) {
                value = menberInfos[@"CARNUMBER"];
                cell.titleL.text = @"协议车辆";
                if (ifInfoBol) {
                    cell.titleTextField.enabled = NO;
                }
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text.uppercaseString;
                    [menberInfos setObject:text forKey:@"CARNUMBER"];
                };
            }else if (indexPath.row == 1) {
                value = menberInfos[@"BAKFOUR"];
                cell.titleL.text = @"会员卡号";
                cell.iconImgV.hidden = YES;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [menberInfos setObject:text forKey:@"BAKFOUR"];
                };
            }else if (indexPath.row == 2) {
                value = menberInfos[@"BAKEIGHT"];
                value = [self getKeyValue:value array:array_carType];
                cell.titleL.text = @"会员卡类型";
                cell.noticeEdit = ^(void) {
                    currentTag = 100;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 3) {
                value = menberInfos[@"BAKSEVEN"];
                value = [self getKeyValue:value array:array_member];
                cell.titleL.text = @"会员类型";
                cell.noticeEdit = ^(void) {
                    currentTag = 101;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 4) {
                value = menberInfos[@"JOINMODE"];
                value = [self getKeyValue:value array:array_memberMethod];
                cell.titleL.text = @"入会方式";
                cell.noticeEdit = ^(void) {
                    currentTag = 102;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 5) {
                value = [menberInfos[@"REGTIME"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"入会日期";
                cell.noticeEdit = ^(void) {
                    currentTag = 103;
                    currentCell = weakCell;
                };
            }else {
                value = [menberInfos[@"LOGOUTTIME"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"到会日期";
                cell.noticeEdit = ^(void) {
                    currentTag = 104;
                    currentCell = weakCell;
                };
            }
            cell.titleTextField.text = value;
            return cell;
        }else if (indexPath.section == 1) {
            if (indexPath.row == 1 || indexPath.row == 3) {
                cell.iconImgV.hidden = NO;
                cell.titleTextField.placeholder = @"请选择";
                cell.titleTextField.inputAccessoryView = _accessoryView;
                if (indexPath.row == 3) {
                    cell.titleTextField.inputView = _datePicker;
                }else {
                    certificateTypeView.cell = cell;
                    cell.titleTextField.inputView = certificateTypeView;
                }
            }else {
                cell.iconImgV.hidden = YES;
                cell.titleTextField.placeholder = @"请输入";
            }
            if (indexPath.row == 0) {
                value = baseInfos[@"LEAGUERNAME"];
                cell.titleL.text = @"会员姓名";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [baseInfos setObject:text forKey:@"LEAGUERNAME"];
                };
            }else if (indexPath.row == 1) {
                value = baseInfos[@"ZJTYPE"];
                value = [self getKeyValue:value array:array_certificateType];
                cell.titleL.text = @"证件类型";
                cell.noticeEdit = ^(void) {
                    currentTag = 201;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 2) {
                value = baseInfos[@"ZJNUM"];
                cell.titleL.text = @"证件号码";
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [baseInfos setObject:text forKey:@"ZJNUM"];
                };
            }else if (indexPath.row == 3) {
                value = [baseInfos[@"DRIVERANNUALDATE"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"驾驶证到期日";
                cell.noticeEdit = ^(void) {
                    currentTag = 202;
                    currentCell = weakCell;
                };
            }else  if (indexPath.row == 4) {
                value = baseInfos[@"MOBILE"];
                cell.titleL.text = @"联系方式";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [baseInfos setObject:text forKey:@"MOBILE"];
                };
            }else  {
                value = baseInfos[@"ADDRESS"];
                cell.titleL.text = @"家庭地址";
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [baseInfos setObject:text forKey:@"ADDRESS"];
                };
            }
            cell.titleTextField.text = value;
            return cell;
        }else if (indexPath.section == 2) {
            if (indexPath.row == 0 || indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7) {
                cell.iconImgV.hidden = YES;
                cell.titleTextField.placeholder = @"请输入";
            }else {
                cell.iconImgV.hidden = NO;
                cell.titleTextField.placeholder = @"请选择";
                if (indexPath.row == 1) {
                    brandView.cell = cell;
                    cell.selectedTextField.inputView = brandView;
                    cell.selectedTextField.inputAccessoryView = _accessoryView;
                    cell.titleTextField.placeholder = @"请输入";
                }else if (indexPath.row == 2) {
                    cell.selectedTextField.enabled = NO;
                    serineView.cell = cell;
                    cell.selectedTextField.inputView = serineView;
                    cell.selectedTextField.inputAccessoryView = _accessoryView;
                    cell.titleTextField.placeholder = @"请输入";
                }else if (indexPath.row == 3) {
                    carView.cell = cell;
                    cell.selectedTextField.inputView = carView;
                    cell.selectedTextField.inputAccessoryView = _accessoryView;
                    cell.titleTextField.placeholder = @"请输入";
                }else if (indexPath.row == 4) {
                    blowsView.cell = cell;
                    cell.titleTextField.inputView = blowsView;
                    cell.titleTextField.inputAccessoryView = _accessoryView;
                }else {
                    cell.titleTextField.inputView = _datePicker;
                    cell.titleTextField.inputAccessoryView = _accessoryView;
                }
            }
            if (indexPath.row == 0) {
                value = carInfos[@"OWNER"];
                cell.titleL.text = @"车辆所有人";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [carInfos setObject:text forKey:@"OWNER"];
                };
            }else if (indexPath.row == 1) {
                cell.selectedTextField.hidden = NO;
                value = carInfos[@"CIBRAND"];
                cell.titleL.text = @"品牌";
                cell.noticeEdit = ^(void) {
                    currentTag = 1001;
                    currentCell = weakCell;
                };
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    if ([text isEqualToString:brandName]) {
                        [carInfos setObject:brandId forKey:@"CIBRANDID"];
                    }else {
                        brandId = @"";
                        serineView.cell.titleTextField.text = @"";
                        serineView.cell.titleTextField.placeholder = @"请输入";
                        serineView.cell.selectedTextField.enabled = NO;
                        carView.cell.titleTextField.text = @"";
                        carView.cell.titleTextField.placeholder = @"请输入";
                        carView.cell.selectedTextField.enabled = NO;
                        [carInfos setObject:brandId forKey:@"CIBRANDID"];
                        
                    }
                    [carInfos setObject:text forKey:@"CIBRAND"];
                };
            }else if (indexPath.row == 2) {
                cell.selectedTextField.hidden = NO;
                value = carInfos[@"CISERIES"];
                if (brandId.length > 0) {
                    cell.selectedTextField.enabled = YES;
                }else {
                    cell.selectedTextField.enabled = NO;
                }
                cell.titleL.text = @"系列";
                cell.noticeEdit = ^(void) {
                    currentTag = 1002;
                    currentCell = weakCell;
                };
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    if ([text isEqualToString:serineName]) {
                        [carInfos setObject:serineId forKey:@"CISERIESID"];
                    }else {
                        serineId = @"";
                        carView.cell.titleTextField.text = @"";
                        carView.cell.titleTextField.placeholder = @"请输入";
                        carView.cell.selectedTextField.enabled = NO;
                        [carInfos setObject:serineId forKey:@"CISERIESID"];
                    }
                    [carInfos setObject:text forKey:@"CISERIES"];
                };
            }else if (indexPath.row == 3) {
                cell.selectedTextField.hidden = NO;
                value = carInfos[@"CICARNAME"];
                if (serineId.length > 0) {
                    cell.selectedTextField.enabled = YES;
                }else {
                    cell.selectedTextField.enabled = NO;
                }
                cell.titleL.text = @"车型";
                cell.noticeEdit = ^(void) {
                    currentTag = 1003;
                    currentCell = weakCell;
                };
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    if ([text isEqualToString:serineName]) {
                        [carInfos setObject:carId forKey:@"CICARID"];
                    }else {
                        carId = @"";
                        [carInfos setObject:carId forKey:@"CICARID"];
                    }
                    [carInfos setObject:text forKey:@"CICARNAME"];
                };
            }else if (indexPath.row == 4) {
                value = carInfos[@"CIBLOWDOWN"];
                value = [self getKeyValue:value array:array_blow];
                cell.titleL.text = @"排气量";
                cell.noticeEdit = ^(void) {
                    currentTag = 1004;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 5) {
                value = carInfos[@"CISSB"];
                cell.titleL.text = @"品牌型号";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [carInfos setObject:text forKey:@"CISSB"];
                };
            }else if (indexPath.row == 6) {
                value = carInfos[@"DOWNNUMBER"];
                cell.titleL.text = @"车驾号";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [carInfos setObject:text forKey:@"DOWNNUMBER"];
                };
            }else if (indexPath.row == 7) {
                value = carInfos[@"CISFDJH"];
                cell.titleL.text = @"发动机号码";
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [carInfos setObject:text forKey:@"CISFDJH"];
                };
            }else if (indexPath.row == 8) {
                value = [carInfos[@"ZCRQ"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"注册日期";
                cell.noticeEdit = ^(void) {
                    currentTag = 1005;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 9) {
                value = [carInfos[@"ISSUEDATE"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"发证日期";
                cell.noticeEdit = ^(void) {
                    currentTag = 1006;
                    currentCell = weakCell;
                };
            }else if (indexPath.row == 10) {
                value = [carInfos[@"VEHICLECHECK"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"车辆车检到期日";
                cell.noticeEdit = ^(void) {
                    currentTag = 1007;
                    currentCell = weakCell;
                };
            }else {
                value = [carInfos[@"CIMAINTAINTIME"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"保养到期日";
                cell.noticeEdit = ^(void) {
                    currentTag = 1008;
                    currentCell = weakCell;
                };
            }
            cell.titleTextField.text = value;
            return cell;
        }else if (indexPath.section == 3) {
            if (indexPath.row == 0) {
                cell.iconImgV.hidden = YES;
                cell.titleTextField.placeholder = @"请输入";
            }else {
                cell.iconImgV.hidden = NO;
                cell.titleTextField.placeholder = @"请选择";
                cell.titleTextField.inputAccessoryView = _accessoryView;
                cell.titleTextField.inputView = _datePicker;
            }
            if (indexPath.row == 0) {
                value = insurtanceInfos[@"INSURANCENAME"];
                cell.titleL.text = @"保险公司";
                cell.markL.hidden = NO;
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [insurtanceInfos setObject:text forKey:@"INSURANCENAME"];
                };
            }else if (indexPath.row == 1) {
                value = [insurtanceInfos[@"BUSINESSRISKSTIME"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"商业险到期日";
                NSString *companyId = userInfo[@"CompanyId"];
                if ([companyId isEqualToString:GH_ID]) {
                    cell.markL.hidden = NO;
                }
                cell.noticeEdit = ^(void) {
                    currentTag = 2001;
                    currentCell = weakCell;
                };
            }else {
                value = [insurtanceInfos[@"STRONGRISKTIME"] componentsSeparatedByString:@" "][0];
                cell.titleL.text = @"交强险到期日";
                cell.markL.hidden = NO;
                cell.noticeEdit = ^(void) {
                    currentTag = 2002;
                    currentCell = weakCell;
                };
            }
            cell.titleTextField.text = value;
            return cell;
        }else {
            if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
                cell.iconImgV.hidden = YES;
                cell.titleTextField.placeholder = @"请输入";
            }else {
                cell.iconImgV.hidden = NO;
                cell.titleTextField.placeholder = @"请选择";
            }
            if (indexPath.row == 0) {
                NSString *_val = serviceInfos[@"CLIENTMANAGER"];
                if (_val.length > 0) {
                    value = _val;
                }else {
                    value = [userInfo objectForKey:@"UserName"];
                }
                [serviceInfos setObject:value forKey:@"CLIENTMANAGER"];
                cell.titleTextField.enabled = NO;
                //            value = serviceInfos[@"CLIENTMANAGERID"];
                cell.titleL.text = @"客户专员";
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [serviceInfos setObject:text forKey:@"CLIENTMANAGERID"];
                };
            }else if (indexPath.row == 1) {
                value = serviceInfos[@"LEAGUERLINKER"];
                cell.titleL.text = @"办理人员";
                cell.noticeText = ^(void) {
                    NSString *text = weakCell.titleTextField.text;
                    [serviceInfos setObject:text forKey:@"LEAGUERLINKER"];
                };
            }else {
                value = serviceInfos[@"STORESNAME"];
                if (value.length == 0) {
                    value = [userInfo objectForKey:@"StoreName"];
                    [serviceInfos setObject:[userInfo objectForKey:@"StoreId"] forKey:@"STORESID"];
                    [serviceInfos setObject:value forKey:@"STORESNAME"];
                }
                cell.titleTextField.enabled = NO;
                cell.titleL.text = @"所属门店";
            }
            cell.titleTextField.text = value;
            return cell;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 28)];
    view.backgroundColor = [UIColor whiteColor];
    if (section != 0) {
        UIImageView *lineV = [[UIImageView alloc] initWithFrame:CGRectMake(11, 0, CGRectGetWidth(_tableView.frame) - 11 *2, 1.5)];
        lineV.image = [UIImage imageNamed:@"虚线"];
        [view addSubview:lineV];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11, 16, CGRectGetWidth(_tableView.frame) - 11 *2, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = UIColorFromRGB(0x414141);
    if (section == 0) {
        label.text = @"会籍信息";
    }else if (section == 1) {
        label.text = @"基本信息";
    }else if (section == 2) {
        label.text = @"车辆详细信息";
    }else if (section == 3) {
        label.text = @"保险详细信息";
    }else {
        label.text = @"服务信息";
    }
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (BOOL)checkValidata:(NSMutableDictionary *)info {
    for (int i = 0; i < info.allKeys.count; i++) {
        NSString *key = info.allKeys[i];
        NSString *name = info[key];
        if ([key isEqualToString:@"CLIENTMANAGERID"] || [key isEqualToString:@"ISSMS"] || [key isEqualToString:@"STORESID"] || [key isEqualToString:@"MemberId"] || [key isEqualToString:@"CIBRANDID"] || [key isEqualToString:@"CISERIESID"] || [key isEqualToString:@"CICARID"]) {
            continue;
        }
        if (name.length == 0) {
            return false;
        }
    }
    return YES;
}

- (BOOL)checkMustData {
    NSString *carNumber = menberInfos[@"CARNUMBER"];
    NSString *owner = carInfos[@"OWNER"];
    NSString *downNumber = carInfos[@"DOWNNUMBER"];
    NSString *cicaBsignal = carInfos[@"CISSB"];
    NSString *insuranCename = insurtanceInfos[@"INSURANCENAME"];
    NSString *strongriskTime = insurtanceInfos[@"STRONGRISKTIME"];
    NSString *leaguerName =  baseInfos[@"LEAGUERNAME"];
    NSString *mobile = baseInfos[@"MOBILE"];
    if (carNumber.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写车牌号"];
        return false;
    }else if (owner.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写车辆所有人"];
        return false;
    }else if (downNumber.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写车驾号"];
        return false;
    }else if (cicaBsignal.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写品牌型号"];
        return false;
    }else if (insuranCename.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请选择保险公司"];
        return false;
    }else if (strongriskTime.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请选择交强险到期日"];
        return false;
    }else if (leaguerName.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写会员姓名"];
        return false;
    }else if (mobile.length == 0) {
        [ZAActivityBar showErrorWithStatus:@"请填写联系方式"];
        return false;
    }
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (keyboardIsShowing) {
//        [currentCell.titleTextField resignFirstResponder];
    }
}


#pragma mark - request
- (void)getAdopter {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *storeName = [userInfo objectForKey:@"StoreName"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSString *carNumberId = [ToolKit getStringVlaue:_info[@"CarNumber"]];
    NSDictionary *parameters = @{@"carNumberId":carNumberId,@"CompanyId":companyId,@"UserToken":userDict};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetAdopter];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            result = [responseObject objectForKey:@"Result"];
            [baseInfos addEntriesFromDictionary:result[@"BaseInfos"][0]];
            [carInfos addEntriesFromDictionary:result[@"CarInfos"][0]];
            [insurtanceInfos addEntriesFromDictionary:result[@"InsurtanceInfos"][0]];
            [menberInfos addEntriesFromDictionary:result[@"MenberInfos"][0]];
            [serviceInfos addEntriesFromDictionary:result[@"ServiceInfos"][0]];
            brandId = carInfos[@"CIBRANDID"];
            serineId = carInfos[@"CISERIESID"];
            carId = carInfos[@"CICARID"];
            if (brandId.length > 0) {
                [self getBrandId];
                [self getSerinesByBrand];
            }
            NSString *_storeId = [ToolKit getStringVlaue:serviceInfos[@"STORESID"]];
            if (_storeId.length == 0) {
                [serviceInfos setObject:storeId forKey:@"STORESID"];
                [serviceInfos setObject:storeName forKey:@"STORESNAME"];
            }
            [_tableView reloadData];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)addAdopter {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    memberId = [ToolKit getStringVlaue:_info[@"MemberId"]];
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"MemberId":memberId,@"CompanyId":companyId,@"MenberInfos":menberInfos,@"BaseInfos":baseInfos,@"CarInfos":carInfos,@"InsurtanceInfos":insurtanceInfos,@"ServiceInfos":serviceInfos};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,AddAdopter];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar showSuccessWithStatus:[responseObject objectForKey:@"Message"]];
            if (!_isAddNew) {
                _refresh();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getBrand {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetBrand];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [brands addObjectsFromArray:[responseObject objectForKey:@"Result"]];
            for (int i = 0; i < brands.count; i++) {
                NSDictionary *dict = brands[i];
                NSString *name = dict[@"CARBRANDCHN"];
                [brandNames addObject:name];
            }
            NSLog(@"brands:   %@",brands);
            [brandView initData:brandNames];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getSerinesByBrand {
    if (brandId.length > 0) {
        [serines removeAllObjects];
        [serineNames removeAllObjects];
        [ZAActivityBar showWithStatus:LODING_MSG];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *token = [userInfo objectForKey:@"Token"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSDictionary *parameters = @{@"UserToken":userDict,@"CarBrandId":brandId};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetSerinesByBrand];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [[responseObject objectForKey:@"Code"] intValue];
            if (code == 0) {
                [ZAActivityBar dismiss];
                [serines addObjectsFromArray:[responseObject objectForKey:@"Result"]];
                for (int i = 0; i < serines.count; i++) {
                    NSDictionary *dict = serines[i];
                    NSString *name = dict[@"CARSERIESNAME"];
                    [serineNames addObject:name];
                }
                [serineView initData:serineNames];
                if (serineId.length > 0) {
                    [self getSerineId];
                    [self getCarName];
                }
                NSLog(@"serines:   %@",serines);
            }else {
                [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        }];
    }
}

- (void)getCarName {
    [cars removeAllObjects];
    [carNames removeAllObjects];
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"CarSeriesId":serineId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetCarName];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [cars addObjectsFromArray:[responseObject objectForKey:@"Result"]];
            for (int i = 0; i < cars.count; i++) {
                NSDictionary *dict = cars[i];
                NSString *name = dict[@"CARMODELNAME"];
                [carNames addObject:name];
            }
            [carView initData:carNames];
            NSLog(@"carNames:   %@",carNames);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self addAdopter];
    }
}


@end