//
//  CarDetailViewController.m
//  CarInfo
//
//  Created by 薛焱 on 16/4/8.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CarDetailViewController.h"
#import "CarInfoDetailCell.h"
#import "PickerView.h"
#import "DatePicker.h"
#import <AFNetworking.h>
#import "JDStatusBarNotification.h"
#import "CarNumCell.h"
#import "MBProgressHUD.h"

@interface CarDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DatePicker *datePicker;
@property (nonatomic, strong) PickerView *pickerView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *keyArray;
@property (nonatomic, strong) NSMutableArray *blowsArray;
@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, assign) BOOL canEditing;
@property (nonatomic, copy) NSString *currentStoreId;
@property (nonatomic, strong) NSMutableArray *brands;
@property (nonatomic, strong) NSMutableArray *serines;
@property (nonatomic, strong) NSMutableArray *cars;
@property (nonatomic, strong) NSMutableArray *bxNameArray;
@property (nonatomic, strong) UITextField *currentTF;
@end

@implementation CarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _canEditing = YES;
    _blowsArray = [NSMutableArray array];
    [self loadPicker];
    [self readDataFromeLocal];
    
    [self reapirInsurance];
    // Do any additional setup after loading the view.
}

- (void)readDataFromeLocal{
    NSDictionary *userInfo =
    [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    _currentStoreId = userInfo[@"StoreId"];
    if (_isFromAddNewCarBtn) {
        [_carInfo setObject:_currentStoreId forKey:@"StoreId"];
        [_carInfo setObject:userInfo[@"StoreName"] forKey:@"StoreName"];
        [_carInfo setObject:userInfo[@"CompanyName"] forKey:@"CompanyName"];
    }
    _titleArray = @[@"关联客户",@"车牌号码",@"联系方式",@"车辆品牌",@"车辆车系",@"车辆车型",@"车辆所有人",@"车辆颜色",@"车辆排量",@"品牌型号",@"车架号码",@"发动机号",@"注册日期",@"发证日期",@"保养时间",@"行驶证号",@"车检到期",@"公里数",@"保险公司",@"保险签单",@"保险到期",];
    _keyArray = @[@"LeaguName", @"CICARNUMBER", @"DRIVECONTACT", @"CIBRAND", @"CISERIES", @"CICARNAME", @"OWNER", @"CICOLOUR", @"CIBLOWDOWN", @"CISSB", @"DOWNNUMBER", @"CISFDJH", @"CIREGISTRATIONDATE", @"DJRQ", @"CIMAINTAINTIME", @"CIDRIVINGNUMBER", @"VEHICLECHECK", @"CIEVENNUMBER", @"INSURANCENAME", @"INSURANCESTARTDATE", @"CICARINSURANCEDATE"];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"blows" ofType:@"plist"];
    NSArray *blowsData = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *blowDict in blowsData) {
        [_blowsArray addObject:blowDict[@"name"]];
    }
    [self getBrand];
    if ([_carInfo[@"CIBRANDID"] length] != 0) {
        [self getSerinesByBrand:_carInfo[@"CIBRANDID"]];
    }
    if ([_carInfo[@"CISERIESID"] length] != 0) {
        [self getCarNameWith:_carInfo[@"CISERIESID"]];
    }
}

- (void)loadPicker{
    _datePicker = [[NSBundle mainBundle]loadNibNamed:@"DatePicker" owner:self options:nil].lastObject;
    _datePicker.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [_datePicker.cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_datePicker.commitBtn addTarget:self action:@selector(commiteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _pickerView = [[NSBundle mainBundle]loadNibNamed:@"PickerView" owner:self options:nil].lastObject;
    _pickerView.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [_pickerView.cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [_pickerView.commitBtn addTarget:self action:@selector(pickerCommiteBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (IBAction)backItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unwindToCarDetailVCFromSearchUserNameVC:(UIStoryboardSegue *)segue{
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//提交车辆信息(包括更新和新增)
- (IBAction)commitCarInfoBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
    
    if ([_carInfo[@"LeaguName"] length] == 0) {
        [JDStatusBarNotification showWithStatus:@"请填写关联客户" dismissAfter:2];
        return;
    }
    
    NSString *carNum = _carInfo[@"CICARNUMBER"];
    if ([carNum containsString:@"-"]) {
        NSString *perfix = [carNum componentsSeparatedByString:@"-"][0];
        NSString *suffix = [carNum componentsSeparatedByString:@"-"][1];
        if (perfix.length == 0 || suffix.length == 0) {
            [JDStatusBarNotification showWithStatus:@"请填写车牌号码" dismissAfter:2];
            return;
        }
    }else{
        [JDStatusBarNotification showWithStatus:@"请填写正确的车牌号码" dismissAfter:2];
        return;
    }
    
    if ([_carInfo[@"DRIVECONTACT"] length] == 0) {
        [JDStatusBarNotification showWithStatus:@"请填写联系方式" dismissAfter:2];
        return;
    }
    
    NSDictionary *userInfo =
    [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = userInfo[@"UserId"];
    NSString *token = userInfo[@"Token"];
    NSDictionary *userToken = @{ @"UserId" : userId, @"Token" : token };
    
    NSMutableDictionary *parameters = [_carInfo mutableCopy];
    [parameters setObject:userToken forKey:@"UserToken"];
    [parameters setObject:userInfo[@"CompanyId"] forKey:@"CompanyId"];
    NSString *url = [NSString stringWithFormat:@"%@%@", URL_HEADER, SubmitCarInfo];
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];   //请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; //响应
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"JSON: %@", responseObject);
        int code = [responseObject[@"Code"] intValue];
        if (code == 0) {
            
            [JDStatusBarNotification showWithStatus:@"提交成功" dismissAfter:2];
            [self performSegueWithIdentifier:@"unwindFromCarInfoDetail" sender:nil];
            
        } else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"] dismissAfter:2];
            NSLog(@"%@", responseObject[@"Result"]);
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}


#pragma mark - Picker View

- (void)commiteBtnAction:(UIButton *)sender {
    CarInfoDetailCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectRow inSection:0]];
    NSDate *date = _datePicker.datePic.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY/MM/dd";
    cell.infoTF.text = [formatter stringFromDate:date];
    [self.view endEditing:YES];
}

- (void)pickerCommiteBtnAction:(UIButton *)sender {
    if ([_pickerView.pickerData isKindOfClass:[NSDictionary class]]) {
        CarNumCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        NSString *carNum1 = ((NSDictionary *)_pickerView.pickerData).allKeys[_pickerView.row];
        NSString *carNum2 = ((NSDictionary *)_pickerView.pickerData)[carNum1][_pickerView.subRow];
        cell.perfixNumTF.text = [NSString stringWithFormat:@"%@%@", carNum1,carNum2];
    }else{
        CarInfoDetailCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectRow inSection:0]];
        cell.infoTF.text = _pickerView.pickerData[_pickerView.row];
    }
    
    [self.view endEditing:YES];
}

- (void)cancelBtnAction:(UIButton *)sender {
    [self.view endEditing:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 21;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        CarNumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarNumCell" forIndexPath:indexPath];
        cell.titleLabel.text = _titleArray[indexPath.row];
        NSString *carNum = _carInfo[_keyArray[indexPath.row]];
        if ([carNum containsString:@"-"]) {
            cell.perfixNumTF.text = [carNum componentsSeparatedByString:@"-"][0];
            cell.suffixNumTF.text = [carNum componentsSeparatedByString:@"-"][1];
        }
        cell.perfixNumTF.tag = indexPath.row;
        cell.suffixNumTF.tag = indexPath.row;
        //如果是当前门店则可以编辑否则不能编辑
        if ([_carInfo[@"StoreId"] isEqualToString:_currentStoreId]) {
            cell.perfixNumTF.userInteractionEnabled = YES;
            cell.perfixNumTF.backgroundColor = [UIColor whiteColor];
            cell.suffixNumTF.userInteractionEnabled = YES;
            cell.suffixNumTF.backgroundColor = [UIColor whiteColor];
            cell.perfixNumTF.inputView = _pickerView;
        }else{
            cell.perfixNumTF.userInteractionEnabled = NO;
            cell.perfixNumTF.backgroundColor = UIColorFromRGB(0xF3F3F3);
            cell.suffixNumTF.userInteractionEnabled = NO;
            cell.suffixNumTF.backgroundColor = UIColorFromRGB(0xF3F3F3);
        }
        
        return cell;
    }
    CarInfoDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarInfoDetailCell" forIndexPath:indexPath];
    cell.titleLab.text = _titleArray[indexPath.row];
    cell.infoTF.text = _carInfo[_keyArray[indexPath.row]];
    cell.infoTF.tag = indexPath.row;
    cell.infoTF.inputView = nil;
    cell.xingLab.hidden = YES;
    cell.selectTF.hidden = YES;
    if (indexPath.row == 0 || indexPath.row == 2) {
        cell.xingLab.hidden = NO;
    }
    //如果是新增车辆信息则可以编辑,修改车辆信息不能编辑
    if ((indexPath.row == 0 || indexPath.row == 2) && ![_carInfo[@"StoreId"] isEqualToString:_currentStoreId]) {
        cell.infoTF.userInteractionEnabled = NO;
        cell.infoTF.backgroundColor = UIColorFromRGB(0xF3F3F3);
    }else{
        cell.infoTF.userInteractionEnabled = YES;
        cell.infoTF.backgroundColor = [UIColor whiteColor];
    }
    //将键盘替换成datePicker
    if ((indexPath.row >= 12 && indexPath.row <= 14) || indexPath.row == 16 || indexPath.row == 19 || indexPath.row == 20) {
        NSString *date = [_carInfo[_keyArray[indexPath.row]] componentsSeparatedByString:@" "][0];
        cell.infoTF.text = date;
        cell.infoTF.inputView = _datePicker;
        cell.selectImage.hidden = NO;
        cell.infoTF.placeholder = @"请选择";
    }else if(indexPath.row >= 3 && indexPath.row <= 5){
        //3,4,5为车辆品牌,车辆车系,车辆车型,存在依赖关系,如果前一个没有编辑则后一个也不能够编辑
        if (indexPath.row == 4) {
            if (_serines.count == 0) {
                cell.selectTF.userInteractionEnabled = NO;
            } else {
                cell.selectTF.userInteractionEnabled = YES;
            }
        }
        if (indexPath.row == 5) {
            if (_cars.count == 0) {
                cell.selectTF.userInteractionEnabled = NO;
            } else {
                cell.selectTF.userInteractionEnabled = YES;
            }
        }
        cell.selectTF.inputView = _pickerView;
        cell.selectTF.hidden = NO;
        cell.selectImage.hidden = NO;
        cell.infoTF.placeholder = @"请输入";
        
        cell.selectTF.tag = indexPath.row;
        
    }else if (indexPath.row == 8 || indexPath.row == 18){
        //将键盘替换为pickerView
        cell.infoTF.inputView = _pickerView;
        cell.selectImage.hidden = NO;
        cell.infoTF.placeholder = @"请选择";
        
    }else{
        cell.infoTF.placeholder = @"请输入";
        cell.selectImage.hidden = YES;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - UITextFieldDelegate
//在弹出pickerView是加载pickerView的数据源
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    _currentTF = textField;
    _selectRow = textField.tag;
    
    [_pickerView.picker selectRow:0 inComponent:0 animated:YES];
    _pickerView.pickerData = nil;
    _datePicker.datePic.date = [NSDate date];
    if (textField.tag == 0) {
        [self performSegueWithIdentifier:@"searchUserName" sender:nil];
        [textField resignFirstResponder];
    }
    if (textField.tag == 1) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"LicensePlate" ofType:@"plist"];
        NSDictionary *carNumDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        _pickerView.pickerData = carNumDict;
        //车牌号
    }else if(textField.tag == 3){
        
        NSMutableArray *brandNames = [NSMutableArray array];
        for (NSDictionary *brandDict in _brands) {
            [brandNames addObject:brandDict[@"CARBRANDCHN"]];
        }
        _pickerView.pickerData = brandNames;
        
        //车辆品牌
    }else if(textField.tag == 4){
        
        NSMutableArray *serineNames = [NSMutableArray array];
        for (NSDictionary *serineDict in _serines) {
            [serineNames addObject:serineDict[@"CARSERIESNAME"]];
        }
        _pickerView.pickerData = serineNames;
        
        //车辆车系
    }else if(textField.tag == 5){
        
        NSMutableArray *carNames = [NSMutableArray array];
        for (NSDictionary *carDict in _cars) {
            [carNames addObject:carDict[@"CARMODELNAME"]];
        }
        _pickerView.pickerData = carNames;
        
        //车辆车型
    }else if (textField.tag == 8){
        _pickerView.pickerData = _blowsArray;
        //车辆排量
    }else if (textField.tag == 18){
        _pickerView.pickerData = _bxNameArray;
        //保险公司
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeMargin:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [_pickerView.picker reloadAllComponents];
}
//通过弹出键盘改变tableView的inset,避免键盘遮挡textfield
- (void)changeMargin:(NSNotification *)sender{
    CGRect rect = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (rect.origin.y < [UIScreen mainScreen].bounds.size.height) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height, 0);
    }else{
        _tableView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)textfieldChange:(NSNotification *)sender{
    if (_currentTF.tag == 1) {
        return;
    }
    CarInfoDetailCell *cell = (CarInfoDetailCell *)_currentTF.superview.superview;

    if (cell.infoTF.tag == 3 && ![cell.infoTF.text isEqualToString:_carInfo[@"CIBRAND"]]) {
        [_carInfo removeObjectForKey:@"CIBRAND"];
        [_carInfo removeObjectForKey:@"CIBRANDID"];
        [_serines removeAllObjects];
        [_cars removeAllObjects];
        [_carInfo removeObjectForKey:@"CISERIESID"];
        [_carInfo removeObjectForKey:@"CICARID"];
        [_carInfo removeObjectForKey:@"CISERIES"];
        [_carInfo removeObjectForKey:@"CICARNAME"];
        NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:4 inSection:0];
        NSIndexPath *secIndex = [NSIndexPath indexPathForRow:5 inSection:0];
        [_tableView reloadRowsAtIndexPaths:@[nextIndex, secIndex] withRowAnimation:(UITableViewRowAnimationNone)];
    }
    if (cell.infoTF.tag == 4 && ![cell.infoTF.text isEqualToString:_carInfo[@"CISERIES"]]) {

        [_carInfo removeObjectForKey:@"CISERIES"];
        [_carInfo removeObjectForKey:@"CISERIESID"];
        [_cars removeAllObjects];
        [_carInfo removeObjectForKey:@"CICARID"];
        [_carInfo removeObjectForKey:@"CICARNAME"];
        NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:5 inSection:0];
        [_tableView reloadRowsAtIndexPaths:@[nextIndex] withRowAnimation:(UITableViewRowAnimationNone)];
    }
    
}

//在结束编辑时将textfield的文本内容加入数据源,做修改和新增
- (void)textFieldDidEndEditing:(UITextField *)textField{
    CarInfoDetailCell *cell = (CarInfoDetailCell *)textField.superview.superview;
    [self textfieldChange:nil];
    //3,4,5前一项做出修改就要移除右面的数据,需要重新填写
    if (textField.tag == 3) {
        NSString *brandId = @"";
        for (NSDictionary *brandDict in _brands) {
            if ([brandDict[@"CARBRANDCHN"] isEqualToString:cell.infoTF.text]) {
                brandId = brandDict[@"ID"];
            }
        }
        //根据textField.text获取车辆车系
        if (![brandId isEqualToString:_carInfo[@"CIBRANDID"]] && brandId.length != 0) {
            [self getSerinesByBrand:brandId];
        }
        
        [_carInfo setObject:brandId forKey:@"CIBRANDID"];
        
    }
    if (textField.tag == 4) {
        NSString *serinesId = @"";
        for (NSDictionary *serinesDict in _serines) {
            if ([serinesDict[@"CARSERIESNAME"] isEqualToString:cell.infoTF.text]) {
                serinesId = serinesDict[@"ID"];
            }
        }
        
        //根据textField.text获取车辆车型
        if (![serinesId isEqualToString:_carInfo[@"CISERIESID"]] && serinesId.length != 0) {
            [self getCarNameWith:serinesId];
        }
        
        [_carInfo setObject:serinesId forKey:@"CISERIESID"];
    }
    if (textField.tag == 5) {
        NSString *carId = @"";
        for (NSDictionary *carDict in _cars) {
            if ([carDict[@"CARMODELNAME"] isEqualToString:cell.infoTF.text]) {
                carId = carDict[@"ID"];
            }
        }
        [_carInfo setObject:carId forKey:@"CICARID"];
    }
    //将车牌拼接成一个字符串存入数据源
    if (_selectRow == 1) {
        CarNumCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectRow inSection:0]];
        NSString *carNum = [NSString stringWithFormat:@"%@-%@", cell.perfixNumTF.text, cell.suffixNumTF.text];
        [_carInfo setObject:carNum forKey:_keyArray[_selectRow]];
    }else{
        [_carInfo setObject:cell.infoTF.text forKey:_keyArray[_selectRow]];
    }
   
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - 获取车辆品牌车系车型
- (void)getBrand {
    _brands = [NSMutableArray array];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetBrand];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [_brands addObjectsFromArray:[responseObject objectForKey:@"Result"]];
            NSLog(@"brands:   %@",_brands);
            
        }else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
    
}

- (void)getSerinesByBrand:(NSString *)brandId {
    
    _serines = [NSMutableArray array];
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
            [_serines addObjectsFromArray:[responseObject objectForKey:@"Result"]];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
            NSLog(@"serines:   %@",_serines);
        }else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
    
}

- (void)getCarNameWith:(NSString *)serineId {
    _cars = [NSMutableArray array];
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
        NSLog(@"%@",responseObject);
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [_cars addObjectsFromArray:[responseObject objectForKey:@"Result"]];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:(UITableViewRowAnimationNone)];
        }else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}
//保险公司
- (void)reapirInsurance {
    _bxNameArray = [NSMutableArray array];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSString *companyId = [userInfo objectForKey:@"CompanyId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyID":companyId,@"type":@"保险公司"};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,ReapirInsurance];
 
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            NSArray *bxArray = responseObject[@"Result"];
            for (int i = 0; i < bxArray.count; i++) {
                NSDictionary *dict = bxArray[i];
                NSString *name = dict[@"NAME"];
                [_bxNameArray addObject:name];
            }
            NSLog(@"%@",_bxNameArray);
        }else {
            [JDStatusBarNotification showWithStatus:responseObject[@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
