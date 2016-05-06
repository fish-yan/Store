//
//  PickUserView.m
//  StoreReception
//
//  Created by cjm-ios on 15/9/1.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "PickUserView.h"
#import "TSLocateView.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ToolKit.h"

@interface PickUserView () {
    NSMutableArray *brands;
    NSMutableArray *brandNames;
    NSMutableArray *serines;
    NSMutableArray *serineNames;
    NSMutableArray *cars;
    NSMutableArray *carNames;
    TSLocateView *bxCompView;
    TSLocateView *userTypeView;
    TSLocateView *serviceTypeView;
    TSLocateView *yearView;
    TSLocateView *linceView;
    TSLocateView *brandView;
    TSLocateView *serineView;
    TSLocateView *carView;
    NSDateFormatter* formatter;
    NSDateFormatter* formatterOut;
    NSString *currentDate;
    UITextField *currentTextField;
    NSString *dateString;
    NSArray *bxArray;
    NSArray *utArray;
    NSArray *snArray;
    NSMutableArray *bxNameArray;
    NSMutableArray *userTypeNameArray;
    NSMutableArray *serviceNameArray;
    NSMutableArray *yearArray;
    NSInteger bxRow;
    NSInteger typeRow;
    NSInteger serviceRow;
    NSInteger yearRow;
    NSInteger linceRow;
    NSInteger subLinceRow;
    NSDictionary *userInfo;
    NSDictionary *licensePlateDict;
    NSArray *provinceArray;
    NSString *brandName;
    NSString *serineName;
    NSString *serineId;
    NSString *carName;
    NSString *carId;
    NSString *brandId;
    NSInteger brandRow;
    NSInteger serineRow;
    NSInteger carRow;
    NSMutableArray *carArray;
}

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) NSArray *pickerData;


@end

@implementation PickUserView

- (void)addSelectImg:(UITextField *)textField {
    UIImageView *sjImgV = UIImageView.new;
    sjImgV.image = [UIImage imageNamed:@"三角"];
    [textField addSubview:sjImgV];
    [sjImgV makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(textField.right);
        make.top.equalTo(textField.top).offset(21);
        make.width.mas_equalTo(9);
        make.height.mas_equalTo(9);
    }];
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    if (textField.markedTextRange == nil) {
        NSLog(@"text:  %@",textField.text);
        [self getCarInfo:textField.text.uppercaseString];
    }
}

- (void)reset {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)awakeFromNib {
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *storeConfig = userInfo[@"StoreConfig"];
    NSString *carProvince = storeConfig[@"CarProvince"];
    NSString *carRegion = storeConfig[@"CarRegion"];
    if (storeConfig) {
        if (![storeConfig isKindOfClass:[NSNull class]]) {
            _stTextField.text = [NSString stringWithFormat:@"%@%@",carProvince,carRegion];
        }
    }
    [_licenNumTextField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    if (![userInfo[@"CompanyId"] isEqualToString:SZMJ_ID]) {
        _njMark.hidden = YES;
        _byMark.hidden = YES;
        _zcMark.hidden = YES;
        _jhjcMark.hidden = YES;
    }
    carArray = [[NSMutableArray alloc] init];
    _lincenView.layer.borderWidth = 0.5;
    _lincenView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    _lincenView.layer.cornerRadius = 6;
    _viewConstraintHeight.constant = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self addSelectImg:_stTextField];
//    [self addSelectImg:_clppTextField];
    [self addSelectImg:_brandSelectTextField];
    [self addSelectImg:_serialSelectTextField];
    [self addSelectImg:_carNameSelectTextField];
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    formatterOut = [[NSDateFormatter alloc]init];
    [formatterOut setDateFormat:@"YYYY/MM/dd HH:mm"];
    currentDate = [formatter stringFromDate:[NSDate date]];
    _inDateTextField.text = currentDate;
    bxNameArray = [[NSMutableArray alloc] init];
    userTypeNameArray = [[NSMutableArray alloc] init];
    serviceNameArray = [[NSMutableArray alloc] init];
    yearArray = [[NSMutableArray alloc] init];
    brands = [[NSMutableArray alloc] init];
    brandNames = [[NSMutableArray alloc] init];
    serines = [[NSMutableArray alloc] init];
    serineNames = [[NSMutableArray alloc] init];
    cars = [[NSMutableArray alloc] init];
    carNames = [[NSMutableArray alloc] init];
    brandId = @"";
    serineId = @"'";
    carId = @"";
    NSString *substring = [currentDate substringToIndex:4];
    int year = [substring intValue];
    for (int i = 0; i < 1000; i++) {
        if ((i + 1900) == year) {
            yearRow = i;
        }
        [yearArray addObject:[NSString stringWithFormat:@"%d",(1900 + i)]];
    }
    bxCompView = [[TSLocateView alloc] initWithTitle:@"保险公司" delegate:self];
    bxCompView.passValue = ^(NSInteger row) {
        if (bxRow != row) {
            bxRow = row;
        }
    };
    userTypeView = [[TSLocateView alloc] initWithTitle:@"客户类别" delegate:self];
    userTypeView.passValue = ^(NSInteger row) {
        if (typeRow != row) {
            typeRow = row;
        }
    };
    serviceTypeView = [[TSLocateView alloc] initWithTitle:@"服务类型" delegate:self];
    serviceTypeView.passValue = ^(NSInteger row) {
        if (serviceRow != row) {
            serviceRow = row;
        }
    };
    yearView = [[TSLocateView alloc] initWithTitle:@"车辆年款" delegate:self];
    yearView.passValue = ^(NSInteger row) {
        if (yearRow != row) {
            yearRow = row;
        }
    };
    [yearView initData:yearArray];
    yearView.curRow = yearRow;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"LicensePlate" ofType:@"plist"];
    licensePlateDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    linceView = [[TSLocateView alloc] initWithTitle:@"选择车牌" delegate:self];
    linceView.passAllValue = ^(NSInteger row,NSInteger subRow) {
        linceRow = row;
        subLinceRow = subRow;
    };
    [linceView initData:licensePlateDict];
    _bxComTextField.inputView = bxCompView;
    _userTypeTextField.inputView = userTypeView;
    _serviceTextField.inputView = serviceTypeView;
    _carYearTextField.inputView = yearView;
    _stTextField.inputView = linceView;
    _licenNumTextField.delegate = self;
    _ppTextField.delegate = self;
    _clppTextField.delegate = self;
    _clcxTextField.delegate = self;
    _vinTextField.delegate = self;
    _cxTextField.delegate = self;
    _licTextField.delegate = self;
    _userNameTextField.delegate = self;
    _userTelTextField.delegate = self;
    _carYearTextField.delegate = self;
    _repairTextField.delegate = self;
    _repairTelTextField.delegate = self;
    _serviceNameTextField.delegate = self;
    _serivceTelTextField.delegate = self;
    _bxDateTextField.delegate = self;
    _byDateTextField.delegate = self;
    _registerDateTextField.delegate = self;
    _yearCheckDateTextField.delegate = self;
    _inDateTextField.delegate = self;
    _outDateTextField.delegate = self;
    _serviceNameTextField.text = userInfo[@"UserName"];
    _serivceTelTextField.text = userInfo[@"Phone"];
    _serviceNameTextField.enabled = NO;
    [self getBrand];
    brandView = [[TSLocateView alloc] initWithTitle:@"车辆品牌" delegate:self];
    serineView = [[TSLocateView alloc] initWithTitle:@"车辆系列" delegate:self];
    carView = [[TSLocateView alloc] initWithTitle:@"车辆车型" delegate:self];
    _brandSelectTextField.inputView = brandView;
    _serialSelectTextField.inputView = serineView;
    _carNameSelectTextField.inputView = carView;
    __weak TSLocateView *weakSerineView = serineView;
    __weak TSLocateView *weakCarView = carView;
    brandView.passValue = ^(NSInteger row) {
        if (brandRow != row) {
            brandRow = row;
            weakSerineView.cell.titleTextField.text = @"";
            weakSerineView.cell.titleTextField.placeholder = @"请选择";
            weakCarView.cell.titleTextField.text = @"";
            weakCarView.cell.titleTextField.placeholder = @"请选择";
        }
    };
    serineView.passValue = ^(NSInteger row) {
        if (serineRow != row) {
            serineRow = row;
            weakCarView.cell.titleTextField.text = @"";
            weakCarView.cell.titleTextField.placeholder = @"请选择";
        }
    };
    carView.passValue = ^(NSInteger row) {
        if (carRow != row) {
            carRow = row;
        }
    };
    [self creatToolBar];
    [self initDatePicker];
    [self reapirInsurance];
    [self reapirLeaguerType];
    [self reapirServer];
}

- (IBAction) searchClick {
    _editLicen();
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_carYearTextField == textField) {
        [yearView.locatePicker selectRow:yearRow inComponent:0 animated:NO];
    }
    if (_outDateTextField == textField) {
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }else {
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }
    currentTextField = textField;
    _datePicker.date = [NSDate date];
    if (textField != _licenNumTextField) {
        [self hiddenKeybord];
    }
    return  YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _clppTextField) {
        _clcxTextField.text = @"";
        _cxTextField.text = @"";
        brandName = textField.text;
        brandId = @"";
    }else if (textField == _clcxTextField) {
        _cxTextField.text = @"";
        serineName = textField.text;
        serineId = @"";
    }else {
        carName = textField.text;
        carId = @"";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _vinTextField) {
        if (string.length == 0) return YES;
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 17) {
            return NO;
        }
    }
    if (textField == _userTelTextField || textField == _repairTelTextField || textField == _serivceTelTextField) {
        if (string.length == 0) return YES;
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 11) {
            return NO;
        }
    }
    if (textField == _licTextField) {
        if (string.length == 0) return YES;
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 6) {
            return NO;
        }
    }
    return YES;
}

- (void)hiddenKeybord {
    [UIView animateWithDuration:0.3 animations:^{
        _viewConstraintHeight.constant = 0;
        [_lincenView layoutIfNeeded];
    }];
    if (_endBegin) {
        _endBegin();
    }
}

- (void)showKeybord {
    [UIView animateWithDuration:0.3 animations:^{
        _viewConstraintHeight.constant = 90;
        [_lincenView layoutIfNeeded];
    }];
    if (_editBegin) {
        _editBegin();
    }
}

- (void)creatToolBar {
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    UIButton* cancelDone = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelDone.frame = CGRectMake(10, 5, 60, 20);
    [cancelDone setBackgroundColor:[UIColor clearColor]];
    [cancelDone setTitle:@"取消" forState:UIControlStateNormal];
    cancelDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:cancelDone];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(topView.frame.size.width-70, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"确定" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelDone addTarget:self action:@selector(OnTapCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_bxComTextField setInputAccessoryView:topView];
    [_userTypeTextField setInputAccessoryView:topView];
    [_serviceTextField setInputAccessoryView:topView];
    _bxDateTextField.inputAccessoryView = topView;
    _byDateTextField.inputAccessoryView = topView;
    _stTextField.inputAccessoryView = topView;
    _clcxTextField.inputAccessoryView = topView;
    _registerDateTextField.inputAccessoryView = topView;
    _yearCheckDateTextField.inputAccessoryView = topView;
    _inDateTextField.inputAccessoryView = topView;
    _userTelTextField.inputAccessoryView = topView;
    _repairTelTextField.inputAccessoryView = topView;
    _serivceTelTextField.inputAccessoryView = topView;
    _outDateTextField.inputAccessoryView = topView;
    _licTextField.inputAccessoryView = topView;
    _carYearTextField.inputAccessoryView = topView;
    _carNameSelectTextField.inputAccessoryView = topView;
    _brandSelectTextField.inputAccessoryView = topView;
    _serialSelectTextField.inputAccessoryView = topView;
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
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
    //默认根据手机本地设置显示为中文还是其他语言
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    self.datePicker.locale = locale;
    self.datePicker.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _bxDateTextField.inputView = _datePicker;
    _byDateTextField.inputView = _datePicker;
    _registerDateTextField.inputView = _datePicker;
    _yearCheckDateTextField.inputView = _datePicker;
    _inDateTextField.inputView = _datePicker;
    _outDateTextField.inputView = _datePicker;
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
//    UITextField *textField = [self getCurrentTextField];
//    textField.text = dateString;
}

- (UITextField *)getCurrentTextField {
    if ([_byDateTextField isFirstResponder]) {
        return _byDateTextField;
    }
    if ([_bxDateTextField isFirstResponder]) {
        return _bxDateTextField;
    }
    if ([_registerDateTextField isFirstResponder]) {
        return _registerDateTextField;
    }
    if ([_yearCheckDateTextField isFirstResponder]) {
        return _yearCheckDateTextField;
    }
    if ([_inDateTextField isFirstResponder]) {
        return _inDateTextField;
    }
    if ([_bxComTextField isFirstResponder]) {
        return _bxComTextField;
    }
    if ([_stTextField isFirstResponder]) {
        return _stTextField;
    }
    if ([_userTypeTextField isFirstResponder]) {
        return _userTypeTextField;
    }
    if ([_serviceTextField isFirstResponder]) {
        return _serviceTextField;
    }
    if ([_bxComTextField isFirstResponder]) {
        return _bxComTextField;
    }
    if ([_serviceTextField isFirstResponder]) {
        return _serviceTextField;
    }
    if ([_userTelTextField isFirstResponder]) {
        return _userTelTextField;
    }
    if ([_repairTelTextField isFirstResponder]) {
        return _repairTelTextField;
    }
    if ([_serivceTelTextField isFirstResponder]) {
        return _serivceTelTextField;
    }
    if ([_outDateTextField isFirstResponder]) {
        return _outDateTextField;
    }
    if ([_carYearTextField isFirstResponder]) {
        [yearView.locatePicker selectRow:yearRow inComponent:0 animated:NO];
        return _carYearTextField;
    }
    if ([_licTextField isFirstResponder]) {
        return _licTextField;
    }
    if ([_clppTextField isFirstResponder]) {
        return _clppTextField;
    }
    if ([_cxTextField isFirstResponder]) {
        return _cxTextField;
    }
    if ([_ppTextField isFirstResponder]) {
        return _ppTextField;
    }
    if ([_clcxTextField isFirstResponder]) {
        return _clcxTextField;
    }
    if ([_brandSelectTextField isFirstResponder]) {
        return _brandSelectTextField;
    }
    if ([_serialSelectTextField isFirstResponder]) {
        return _serialSelectTextField;
    }
    if ([_carNameSelectTextField isFirstResponder]) {
        return _carNameSelectTextField;
    }
    return nil;
}

- (void)OnTapCancel:(id) sender{
    UITextField *textField = [self getCurrentTextField];
    [textField resignFirstResponder];
}

-(void)OnTapDone:(id) sender{
    UITextField *textField = [self getCurrentTextField];
    if (dateString.length == 0) {
        dateString = [formatter stringFromDate:[NSDate date]];
    }
    if ([_byDateTextField isFirstResponder]) {
         _byDateTextField.text = dateString;
    }
    if ([_bxDateTextField isFirstResponder]) {
        _bxDateTextField.text = dateString;
    }
    if ([_registerDateTextField isFirstResponder]) {
        _registerDateTextField.text = dateString;
    }
    if ([_yearCheckDateTextField isFirstResponder]) {
        _yearCheckDateTextField.text = dateString;
    }
    if ([_inDateTextField isFirstResponder]) {
        _inDateTextField.text = dateString;
    }
    if ([_bxComTextField isFirstResponder]) {
        _bxComTextField.text = bxNameArray[bxRow];
    }
    if ([_stTextField isFirstResponder]) {
        NSArray *array = licensePlateDict.allKeys;
        NSString *key = array[linceRow];
        NSArray *subArray = licensePlateDict[key];
        NSString *subValue = @"";
        if (subArray.count != 0) {
            subValue = subArray[subLinceRow];
        }
        _stTextField.text = [NSString stringWithFormat:@"%@%@",key,subValue];
    }
    if ([_userTypeTextField isFirstResponder]) {
        if (userTypeNameArray.count > 0) {
           _userTypeTextField.text = userTypeNameArray[typeRow];
        }
    }
    if ([_serviceTextField isFirstResponder]) {
        if (serviceNameArray.count > 0) {
            _serviceTextField.text = serviceNameArray[serviceRow];
        }
    }
    if ([_outDateTextField isFirstResponder]) {
        _outDateTextField.text = [formatterOut stringFromDate:self.datePicker.date];;
    }
    if ([_carYearTextField isFirstResponder]) {
        _carYearTextField.text = yearArray[yearRow];
    }
    if ([_brandSelectTextField isFirstResponder]) {
        if (brands.count > 0) {
            NSDictionary *info = brands[brandRow];
            NSString *name = info[@"CARBRANDCHN"];
            NSString *bid =  info[@"ID"];
            _clppTextField.text = name;
            _clcxTextField.text = @"";
            _cxTextField.text = @"";
            brandName = name;
            brandId = bid;
            _clcxTextField.enabled = YES;
            [self getSerinesByBrand];
        }
    }
    if ([_serialSelectTextField isFirstResponder]) {
        if (serines.count > 0) {
            NSDictionary *info = serines[serineRow];
            NSString *name = info[@"CARSERIESNAME"];
            NSString *bid =  info[@"ID"];
            _clcxTextField.text = name;
            _cxTextField.text = @"";
            serineName = name;
            serineId = bid;
            _cxTextField.enabled = YES;
            [self getCarName];
        }
    }
    if ([_carNameSelectTextField isFirstResponder]) {
        if (cars.count > 0) {
            NSDictionary *info = cars[carRow];
            NSString *name = info[@"CARMODELNAME"];
            NSString *bid =  info[@"ID"];
            _cxTextField.text = name;
            carName = name;
            carId = bid;
        }
    }
    dateString = @"";
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)hidden {
    UITextField *textField = [self getCurrentTextField];
    [textField resignFirstResponder];
    [currentTextField resignFirstResponder];
}

- (NSMutableDictionary *)getData {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (_ppTextField.text.length > 0) {
        [dict setObject:_ppTextField.text forKey:@"CiSsb"];
    }
    if (_clppTextField.text.length > 0) {
        [dict setObject:_clppTextField.text forKey:@"CarBrand"];
        [dict setObject:brandId forKey:@"CarBrandId"];
    }
    if (_clcxTextField.text.length > 0) {
        [dict setObject:_clcxTextField.text forKey:@"MotoType"];
        [dict setObject:serineId forKey:@"MotoTypeId"];
    }
    if (_cxTextField.text.length > 0) {
        [dict setObject:_cxTextField.text forKey:@"CiCarName"];
        [dict setObject:carId forKey:@"CiCarId"];
    }
    if (_vinTextField.text.length > 0) {
        [dict setObject:_vinTextField.text forKey:@"FrameNum"];
    }
    if (_bxComTextField.text.length > 0) {
        [dict setObject:_bxComTextField.text forKey:@"InsuranceCompany"];
    }
    if (_bxDateTextField.text.length > 0) {
        [dict setObject:_bxDateTextField.text forKey:@"InsDueDate"];
    }
    if (_byDateTextField.text.length > 0) {
        [dict setObject:_byDateTextField.text forKey:@"CarMaintainTime"];
    }
    if (_registerDateTextField.text.length > 0) {
        [dict setObject:_registerDateTextField.text forKey:@"CarRegistrationDate"];
    }
    if (_yearCheckDateTextField.text.length > 0) {
        [dict setObject:_yearCheckDateTextField.text forKey:@"CarVehicleCheck"];
    }
    
    if (_carYearTextField.text.length > 0) {
        [dict setObject:_carYearTextField.text forKey:@"CarYearNum"];
    }
    if (_repairTextField.text.length > 0) {
        [dict setObject:_repairTextField.text forKey:@"ciLeaguerName"];
    }
    if (_serviceTextField.text.length > 0) {
        [dict setObject:_serviceTextField.text forKey:@"ServiceType"];
    }
    if (_licTextField.text.length > 0) {
        [dict setObject:_licTextField.text forKey:@"RoadHaul"];
    }
    if (_inDateTextField.text.length > 0) {
        [dict setObject:_inDateTextField.text forKey:@"InfoDate"];
    }
    if (_outDateTextField.text.length > 0) {
        [dict setObject:_outDateTextField.text forKey:@"ExpectedFinishDate"];
    }
    
    if (_userNameTextField.text.length > 0) {
        [dict setObject:_userNameTextField.text forKey:@"TelPerson"];
    }
    if (_userTelTextField.text.length > 0) {
        [dict setObject:_userTelTextField.text forKey:@"TelNumber"];
    }
    if (_serviceNameTextField.text.length > 0) {
        [dict setObject:_serviceNameTextField.text forKey:@"ServiceConsultant"];
    }
    if (_serivceTelTextField.text.length > 0) {
        [dict setObject:_serivceTelTextField.text forKey:@"ServiceConsultantTel"];
    }
    if (_repairTextField.text.length > 0) {
        [dict setObject:_repairTextField.text forKey:@"ciLeaguerName"];
    }
    if (_repairTelTextField.text.length > 0) {
        [dict setObject:_repairTelTextField.text forKey:@"ciLeaguerNameTel"];
    }
    if (_bxComTextField.text.length > 0) {
        NSDictionary *info = bxArray[bxRow];
        [dict setObject:info[@"ID"] forKey:@"InsuranceCompany"];
    }
    if (_userTypeTextField.text.length > 0) {
        NSDictionary *info = utArray[typeRow];
        [dict setObject:info[@"ID"] forKey:@"LeaguerTypeId"];
        [dict setObject:info[@"NAME"] forKey:@"LeaguerType"];
    }
    if (_serviceTextField.text.length > 0) {
        NSDictionary *info = snArray[serviceRow];
        [dict setObject:info[@"ID"] forKey:@"ServiceType"];
    }
    return dict;
}

- (NSString *)getValueFromKey:(NSArray *)array tid:(NSString *)tid {
    NSString *value = @"";
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = array[i];
        NSString *_tid = dict[@"ID"];
        if ([tid isEqualToString:_tid]) {
            value = dict[@"NAME"];
            break;
        }
    }
    return value;
}

- (void)reapirInsurance {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyID":companyId,@"type":@"保险公司"};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,ReapirInsurance];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            bxArray = [responseObject objectForKey:@"Result"];
            for (int i = 0; i < bxArray.count; i++) {
                NSDictionary *dict = bxArray[i];
                NSString *name = dict[@"NAME"];
                [bxNameArray addObject:name];
            }
            [bxCompView initData:bxNameArray];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}


- (void)reapirLeaguerType {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyID":companyId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,ReapirLeaguerType];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            utArray = [responseObject objectForKey:@"Result"];
            for (int i = 0; i < utArray.count; i++) {
                NSDictionary *dict = utArray[i];
                NSString *name = dict[@"NAME"];
                [userTypeNameArray addObject:name];
                if (i == 0) {
                    _userTypeTextField.text = name;
                    typeRow = 0;
                }
            }
            
            [userTypeView initData:userTypeNameArray];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)reapirServer {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyID":companyId,@"type":@"施工服务类别"};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,ReapirServer];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            snArray = [responseObject objectForKey:@"Result"];
            for (int i = 0; i < snArray.count; i++) {
                NSDictionary *dict = snArray[i];
                NSString *name = dict[@"NAME"];
                [serviceNameArray addObject:name];
            }
            [serviceTypeView initData:serviceNameArray];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (BOOL)checkValidata {
    if (_stTextField.text.length == 0) {
        return false;
    }
    if (_licenNumTextField.text.length == 0) {
        return false;
    }
    if (_bxComTextField.text.length == 0) {
        return false;
    }
    if (_userTypeTextField.text.length == 0) {
        return false;
    }
    if (_serviceTextField.text.length == 0) {
        return false;
    }
    if (_bxDateTextField.text.length == 0) {
        return false;
    }
    if (_inDateTextField.text.length == 0) {
        return false;
    }
    if (_ppTextField.text.length == 0) {
        return false;
    }
    if (_clppTextField.text.length == 0) {
        return false;
    }
    if (_vinTextField.text.length == 0) {
        return false;
    }
    if (_clcxTextField.text.length == 0) {
        return false;
    }
    if (_cxTextField.text.length == 0) {
        return false;
    }
    if (_userNameTextField.text.length == 0) {
        return false;
    }
    if (_userTelTextField.text.length == 0) {
        return false;
    }
    if (_repairTextField.text.length == 0) {
        return false;
    }
    if (_repairTelTextField.text.length == 0) {
        return false;
    }
    if (_serviceNameTextField.text.length == 0) {
        return false;
    }
    if (_serivceTelTextField.text.length == 0) {
        return false;
    }
    if ([userInfo[@"CompanyId"] isEqualToString:SZMJ_ID]) {
        if (_outDateTextField.text.length == 0) {
            return false;
        }
    }
    if ([userInfo[@"CompanyId"] isEqualToString:SZMJ_ID]) {
        if (_byDateTextField.text.length == 0) {
            return false;
        }
    }
    if ([userInfo[@"CompanyId"] isEqualToString:SZMJ_ID]) {
        if (_registerDateTextField.text.length == 0) {
            return false;
        }
    }
    if ([userInfo[@"CompanyId"] isEqualToString:SZMJ_ID]) {
        if (_yearCheckDateTextField.text.length == 0) {
            return false;
        }
    }
    if (_licTextField.text.length == 0) {
        return false;
    }
    return true;
}

- (void)resetView {
    _licenNumTextField.text = @"";
    _serivceTelTextField.text = @"";
    _serivceTelTextField.text = @"";
    _serviceTextField.text = @"";
    _inDateTextField.text = @"";
    _repairTelTextField.text = @"";
    _carYearTextField.text = @"";
    _userTypeTextField.text = @"";
    _userNameTextField.text = @"";
    _userTelTextField.text = @"";
    _yearCheckDateTextField.text = @"";
    _bxDateTextField.text = @"";
    _licTextField.text = @"";
    _repairTextField.text = @"";
    _byDateTextField.text = @"";
    _registerDateTextField.text = @"";
    _ppTextField.text = @"";
    _clppTextField.text = @"";
    _cxTextField.text = @"";
    _vinTextField.text = @"";
    _bxComTextField.text = @"";
    _stTextField.text = @"";
    _clcxTextField.text = @"";
    _outDateTextField.text = @"";
}

- (void)getSerineId {
    for (int i = 0; i < serines.count; i++) {
        NSDictionary *dict = serines[i];
        NSString *serID = dict[@"ID"];
        if ([serID isEqualToString:serineId]) {
            break;
        }
    }
}

- (void)getBrandId {
    for (int i = 0; i < brands.count; i++) {
        NSDictionary *dict = brands[i];
        NSString *bid = dict[@"ID"];
        if ([bid isEqualToString:brandId]) {
            break;
        }
    }
}

- (void)getCarId {
    for (int i = 0; i < cars.count; i++) {
        NSDictionary *dict = cars[i];
        NSString *cid = dict[@"ID"];
        if ([cid isEqualToString:carId]) {
            break;
        }
    }
}

- (void)repairInfobyCarNum {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSString *carNumber = [_info objectForKey:@"CarNumber"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyID":companyId,@"CarNum":carNumber};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,RepairInfobyCarNum];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            NSDictionary *dict = responseObject[@"Result"];
            if ([dict isKindOfClass:[NSDictionary class]]) {
                [ZAActivityBar dismiss];
                _repairTelTextField.text = [ToolKit getStringVlaue:dict[@"DRIVECONTACT"]];
//                _carYearTextField.text = [ToolKit getStringVlaue:dict[@"LEAGUERNUM"]];
                NSString *ln = [ToolKit getStringVlaue:dict[@"LEAGUERTYPE"]];
                if (ln.length > 0) {
                    _userTypeTextField.text = ln;
                }
//                _userTypeTextField.text = [self getValueFromKey:utArray tid:lid];
                _userNameTextField.text = [ToolKit getStringVlaue:dict[@"LeaguerName"]];
                _userTelTextField.text = [ToolKit getStringVlaue:dict[@"PHONE"]];
                _yearCheckDateTextField.text = [ToolKit getStringVlaue:dict[@"VehicleCheck"]];
                _bxDateTextField.text = [ToolKit getStringVlaue:dict[@"ciCarInsuranceDate"]];
//                _licTextField.text = [ToolKit getStringVlaue:dict[@"ciEvenNumber"]];
                _carYearTextField.text = [ToolKit getStringVlaue:dict[@"CarYearNum"]];
                _repairTextField.text = [ToolKit getStringVlaue:dict[@"ciLeaguerName"]];
                _byDateTextField.text = [ToolKit getStringVlaue:dict[@"ciMaintainTime"]];
                _registerDateTextField.text = [ToolKit getStringVlaue:dict[@"ciRegistrationDate"]];
                _ppTextField.text = [ToolKit getStringVlaue:dict[@"ciSsb"]];
                _clppTextField.text = [ToolKit getStringVlaue:dict[@"cibrand"]];
                _clcxTextField.text = [ToolKit getStringVlaue:dict[@"ciseries"]];
                _vinTextField.text = [ToolKit getStringVlaue:dict[@"downnumber"]];
                _bxComTextField.text = [ToolKit getStringVlaue:dict[@"insuranceName"]];
                _cxTextField.text = [ToolKit getStringVlaue:dict[@"cicarname"]];
                brandId = dict[@"cibrandid"];
                serineId = dict[@"ciseriesid"];
                carId = dict[@"cicarid"];
                if (brandId.length > 0) {
                    [self getBrandId];
                    [self getSerinesByBrand];
                }
            }else {
                [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
            }
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
                    if (serineId.length > 0) {
                        [self getCarName];
                    }
                }
            }else {
                [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
                
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
            if (carId.length > 0) {
                [self getCarId];
            }
            NSLog(@"carNames:   %@",carNames);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)getCarInfo:(NSString *)linceStr {
    if (linceStr.length > 0) {
        [ZAActivityBar showWithStatus:LODING_MSG];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSString *userId = userInfo[@"UserId"];
        NSString *token = userInfo[@"Token"];
        NSString *companyId = userInfo[@"CompanyId"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"Key":linceStr,@"PageIndex":@"0",@"PageSize":@"50"};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetCar];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [responseObject[@"Code"] intValue];
            if (code == 0) {
                [ZAActivityBar dismiss];
                [carArray removeAllObjects];
                [carArray addObjectsFromArray:responseObject[@"Result"][@"Cars"]];
                if (carArray.count > 0) {
                    [self showKeybord];
                }else {
                    [self hiddenKeybord];
                }
                if (carArray.count > 0) {
                    [_tableView reloadData];
                }
                NSLog(@"JSON: %@", responseObject);
            }else {
                NSLog(@"msg:  %@",responseObject[@"Message"]);
                [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        }];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return carArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *itemCell = @"itemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (carArray.count > 0 && carArray.count > indexPath.row) {
        NSDictionary *dict = carArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",dict[@"CarNumber"],dict[@"MemberName"]];
        cell.textLabel.textColor = UIColorFromRGB(0x5D5D5D);
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(cell.frame), 1)];
        lineV.backgroundColor = UIColorFromRGB(0xD9D9D9);
        [cell.contentView addSubview:lineV];
        __weak __typeof(UITableViewCell *)weakCell = cell;
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakCell).with.insets(UIEdgeInsetsMake(43, 0, 0, 0));
        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_licenNumTextField resignFirstResponder];
    _info = [carArray[indexPath.row] copy];
    _userTelTextField.text = _info[@"TelNumber"];
    _userNameTextField.text = _info[@"MemberName"];
    _repairTextField.text = _info[@"MemberName"];
    _repairTelTextField.text = _info[@"TelNumber"];
    [self repairInfobyCarNum];
    if (_passValue) {
        _passValue(_info);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end