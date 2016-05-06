//
//  SearchSubViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/8/21.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "SearchSubViewController.h"
#import "ZAActivityBar.h"
#import "SearchOrderViewController.h"
#import "ScanningRecognizeViewController.h"

@interface SearchSubViewController () {
    NSDateFormatter *formatter;
    NSString *currentDate;
    NSDate *startDate;
    NSDate *endDate;
    NSString *endLince;
}

@end

@implementation SearchSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initHeader];
    [self initDatePicker];
    [self initToolBar];
    endLince = @"";
    _startTextField.delegate = self;
    _endTextField.delegate = self;
    _startTextField.inputAccessoryView = _accessoryView;
    _startTextField.inputView = _datePicker;
    _endTextField.inputAccessoryView = _accessoryView;
    _endTextField.inputView = _datePicker;
    formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    currentDate = [formatter stringFromDate:[NSDate date]];
    startDate = [NSDate date];
    endDate = [NSDate date];
    _startTextField.text = currentDate;
    _endTextField.text = currentDate;
}

- (IBAction)scanClick:(id)sender {
    ScanningRecognizeViewController *srvc = [[ScanningRecognizeViewController alloc] init];
    srvc.passCarLince = ^(NSString *lince) {
        endLince = [lince substringFromIndex:2];
        [_linceNumBtn setTitle:[NSString stringWithFormat:@"车牌尾数：%@",endLince] forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:srvc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)initToolBar {
    self.accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
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
    _datePicker.datePickerMode = UIDatePickerModeDate;
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
    NSString *dateString = [formatter stringFromDate:pickerDate];
    //打印显示日期时间
    NSLog(@"格式化显示时间：%@",dateString);
    if ([_startTextField isFirstResponder]) {
        _startTextField.text = [NSString stringWithFormat:@"%@", dateString];
        startDate = pickerDate;
    }
    if ([_endTextField isFirstResponder]) {
        _endTextField.text = [NSString stringWithFormat:@"%@", dateString];
        endDate = pickerDate;
    }
}

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
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitClick:(id)sender {
    [self closeKeybord];
    if (endLince.length > 0) {
        NSString *start = @"";
        NSString *end = @"";
        if ((!(_startTextField.text.length > 0) && _endTextField.text.length > 0) || (_startTextField.text.length > 0 && !(_endTextField.text.length > 0))) {
            [ZAActivityBar showErrorWithStatus:@"请选择开始与结束时间！"];
        }
        if (start.length == 0 && end.length == 0 && endLince.length == 0) {
            [ZAActivityBar showErrorWithStatus:@"请扫描要查询的车牌！"];
        }
        if (_startTextField.text.length > 0 && _endTextField.text.length > 0) {
            start = _startTextField.text;
            end = _endTextField.text;
        }
        NSDictionary *dict = @{@"key":endLince,@"start":start,@"end":end};
        SearchOrderViewController *sovc = [[SearchOrderViewController alloc] initWithNibName:@"SearchOrderViewController" bundle:nil];
//        sovc.info = dict;
        [self.navigationController pushViewController:sovc animated:YES];
    }else {
        [ZAActivityBar showErrorWithStatus:@"请扫描车牌"];
    }
}

- (void)closeKeybord {
    if ([_startTextField isFirstResponder]) {
        [_startTextField resignFirstResponder];
    }
    if ([_endTextField isFirstResponder]) {
        [_endTextField resignFirstResponder];
    }
}

- (void)OnTapCancel:(id) sender{
    [self closeKeybord];
}

-(void)OnTapDone:(id) sender{
    if ([_startTextField isFirstResponder]) {
        if (_startTextField.text.length == 0) {
            _startTextField.text = currentDate;
        }
        [_startTextField resignFirstResponder];
    }
    if ([_endTextField isFirstResponder]) {
        if (_endTextField.text.length == 0) {
            _endTextField.text = currentDate;
        }
        [_endTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _startTextField) {
        _datePicker.date = startDate;
    }else if (textField == _endTextField) {
        _datePicker.date = endDate;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
