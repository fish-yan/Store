//
//  RepairContentViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/18.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "RepairContentViewController.h"
#import "InternalinsTableViewCell.h"
#import "EngineCheckTableViewCell.h"
#import "CarCheckTableViewCell.h"
#import "CarCheckAllTableViewCell.h"
#import "OtherStateTableViewCell.h"
static NSString *ilCellStr = @"ilCell";
static NSString *ecCellStr = @"ecCell";
static NSString *ccCellStr = @"ccCell";
static NSString *ccaCellStr = @"ccaCell";
static NSString *osCellStr = @"osCell";
#define ILTCELL @"ILTCELL"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


@interface RepairContentViewController () {
    NSMutableArray *titles;
    NSInteger currentSection;
    NSInteger tagIndex;
    CarCheckTableViewCell *ccCell;
    InternalinsTableViewCell *ilCell;
    EngineCheckTableViewCell *ecCell;
    CarCheckAllTableViewCell *ccaCell;
    OtherStateTableViewCell *osCell;
    NSString *yearText;
    NSString *valiText;
}

@end

@implementation RepairContentViewController

- (void)initData {
    currentSection = 0;
    titles = [[NSMutableArray alloc] initWithObjects:@"内部检测",@"发动机检查",@"车辆检查（半举升）",@"车辆检查（全举升）",@"其他状况", nil];
}

- (void)initToolBar {
    self.accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(self.accessoryView.frame.size.width-10, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"完成" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.accessoryView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
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
    NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];// 创建一个日期格式器
    [pickerFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [pickerFormatter stringFromDate:pickerDate];
    //打印显示日期时间
    NSLog(@"格式化显示时间：%@",dateString);
    if ( [ccCell.yearTextField isFirstResponder] ) {
        ccCell.yearTextField.text = [NSString stringWithFormat:@"%@", dateString];
    } else if ( [ccCell.validTextField isFirstResponder] ) {
        ccCell.validTextField.text = [NSString stringWithFormat:@"%@", dateString];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    [self initData];
    [self initToolBar];
    [self initDatePicker];
    [self initNib];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark click event
-(void)OnTapDone:(id) sender{
    if ( [ccCell.yearTextField isFirstResponder] ) {
        [ccCell.yearTextField resignFirstResponder];
    } else if ( [ccCell.validTextField isFirstResponder] ) {
        [ccCell.validTextField resignFirstResponder];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObjectsFromArray:ilCell.addArray];
    [array addObjectsFromArray:ecCell.addArray];
    [ccCell checkValue];
    [array addObjectsFromArray:ccCell.addArray];
    [array addObjectsFromArray:ccaCell.addArray];
    [osCell checkValue];
    [array addObjectsFromArray:osCell.addArray];
    _passContent(array);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"维修内容";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(250, 0, 44, 44)];
    [rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)initNib {
    WS(ws);
    UINib *ilNib = [UINib nibWithNibName:@"InternalinsTableViewCell" bundle:nil];
    [_tableView registerNib:ilNib forCellReuseIdentifier:ilCellStr];
    ilCell = (InternalinsTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:ilCellStr];
    [ilCell initData:_addArray];
    UINib *ecNib = [UINib nibWithNibName:@"EngineCheckTableViewCell" bundle:nil];
    [_tableView registerNib:ecNib forCellReuseIdentifier:ecCellStr];
    ecCell = (EngineCheckTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:ecCellStr];
    [ecCell initData:_addArray];
    UINib *ccNib = [UINib nibWithNibName:@"CarCheckTableViewCell" bundle:nil];
    [_tableView registerNib:ccNib forCellReuseIdentifier:ccCellStr];
    ccCell = (CarCheckTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:ccCellStr];
    ccCell.yearTextField.inputAccessoryView = _accessoryView;
    ccCell.yearTextField.inputView = _datePicker;
    ccCell.validTextField.inputAccessoryView = _accessoryView;
    ccCell.validTextField.inputView = _datePicker;
    [ccCell initData:_addArray];
    UINib *ccaNib = [UINib nibWithNibName:@"CarCheckAllTableViewCell" bundle:nil];
    [_tableView registerNib:ccaNib forCellReuseIdentifier:ccaCellStr];
    ccaCell = (CarCheckAllTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:ccaCellStr];
    [ccaCell initData:_addArray];
    UINib *osNib = [UINib nibWithNibName:@"OtherStateTableViewCell" bundle:nil];
    [_tableView registerNib:osNib forCellReuseIdentifier:osCellStr];
    osCell = (OtherStateTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:osCellStr];
    osCell.setOffset = ^(int indexTag) {
        [ws tableViewSet:indexTag];
    };
    osCell.backOffset = ^(void) {
        [ws tableViewBack];
    };
    [osCell initData:_addArray];
}

- (void)hdAction:(id)send {
    UIButton *btn = (UIButton *)send;
    if (currentSection == btn.tag) {
        currentSection = -1;
    }else {
        currentSection = btn.tag;
    }
    //    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:btn.tag];
    //    [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == currentSection) {
        return 1;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = ilCell;
    }else if (indexPath.section == 1) {
        cell = ecCell;
    }else if (indexPath.section == 2) {
        cell = ccCell;
    }else if (indexPath.section == 3) {
        cell = ccaCell;
    }else  {
        cell = osCell;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return titles.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.tag = section;
    [view addTarget:self action:@selector(hdAction:) forControlEvents:UIControlEventTouchUpInside];
    view.frame = CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 38);
    [view setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleL = UILabel.new;
    titleL.text = [titles objectAtIndex:section];
    titleL.textColor = UIColorFromRGB(0x414141);
    titleL.font = [UIFont systemFontOfSize:16];
    [view addSubview:titleL];
    UIView *lineV = UIView.new;
    lineV.backgroundColor = UIColorFromRGB(0xd9d9d9);
    [view addSubview:lineV];
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头"]];
    [UIView animateWithDuration:0.6 animations:^ {
        if (section != currentSection) {
            arrow.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
        }else {
            arrow.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
        }
    }];
    [view addSubview:arrow];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.left).offset(22);
        make.right.equalTo(view.right).offset(-43);
        make.top.equalTo(view.top);
        make.bottom.equalTo(lineV.top);
    }];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.left).offset(CGRectGetWidth(_tableView.frame) - 33);
        make.right.equalTo(view.right).offset(-23);
        make.center.equalTo(titleL.center);
        make.width.mas_equalTo(10);
        make.height.mas_equalTo(16);
    }];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.left);
        make.right.equalTo(view.right);
        make.bottom.equalTo(view.bottom);
        make.height.mas_equalTo(1);
    }];
    return view;
}

#pragma mark - 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 364;
    }else if (indexPath.section == 1) {
        return 416;
    }else if (indexPath.section == 2) {
        return 209;
    }else if (indexPath.section == 3) {
        return 416;
    }else {
        return 628;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (void)tableViewSet:(int)indexTag {
    [self.tableView setContentOffset:CGPointMake(0, indexTag * 70) animated:YES];
}

- (void)tableViewBack {
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
