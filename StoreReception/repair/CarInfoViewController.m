//
//  CarInfoViewController.m
//  Repair
//
//  Created by Kassol on 15/9/7.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "CarInfoViewController.h"
#import "CarInfoCell.h"
#import "ServiceCell.h"
#import "Utils.h"
#import "HttpClient.h"
#import "MBProgressHUD.h"
#import "AddWorkerViewController.h"
#import "RepairOrderInfo.h"
#import "WorkerCell.h"
#import "JDStatusBarNotification.h"
#import "SectionView.h"


@interface CarInfoViewController () {
    NSDictionary *userInfo;
    NSString *userId;
    NSString *token;
    BOOL isSelect;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDictionary *detail;
@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (assign, nonatomic) BOOL isAllFinished;

@end

@implementation CarInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    _detail = [[RepairOrderInfo sharedRepairOrderInfo] getRepairOrderWithID:_carID];
    
    if ([[RepairOrderInfo sharedRepairOrderInfo].isSelectDict.allKeys containsObject:_carID]) {
        isSelect = [[RepairOrderInfo sharedRepairOrderInfo].isSelectDict[_carID] boolValue];
    }else{
        [[RepairOrderInfo sharedRepairOrderInfo].isSelectDict setObject:[NSString stringWithFormat:@"%d",isSelect] forKey:_carID];
    }
    
    if ( _detail != nil) {
        _serviceArray = [NSMutableArray array];
        for (NSDictionary *project in [_detail objectForKey:@"ConPros"]) {
            if (![[project objectForKey:@"Status"] isEqualToString:@"9"]) {
                [_serviceArray addObject:project];
            }
        }
        [_tableView reloadData];
    } else {
        [self readDataSource];
    }
}

- (void)readDataSource{
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    userId = [userInfo objectForKey:@"UserId"];
    token = [userInfo objectForKey:@"Token"];
    NSMutableDictionary *option    = [NSMutableDictionary dictionary];
    NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
    [userToken setObject:userId forKey:@"UserId"];
    [userToken setObject:token forKey:@"Token"];
    [option setObject:userToken forKey:@"UserToken"];
    [option setObject:_carID forKey:@"ConId"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpClient sharedHttpClient] getDetailWithType:_carInfoType option:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            
            [[RepairOrderInfo sharedRepairOrderInfo] setRepairOrderWithResponse:responseObject fromRework:_isRework];
            
            _detail = [(NSDictionary *)responseObject objectForKey:@"Result"];
            _serviceArray = [NSMutableArray array];
            NSInteger finishedCount = 0;
            for (NSDictionary *project in [_detail objectForKey:@"ConPros"]) {
                if (![[project objectForKey:@"Status"] isEqualToString:@"9"]) {
                    if ([[project objectForKey:@"Status"] isEqualToString:@"2"] && _isRework) {
                        ++finishedCount;
                    }
                    [_serviceArray addObject:project];
                }
            }
            if (finishedCount == _serviceArray.count) {
                _isAllFinished = YES;
            }
            if (_isRework&&_isAllFinished) {
                
                [self.finishButton setBackgroundColor:UIColorFromRGB(0x999999)];
                _finishButton.userInteractionEnabled = NO;
            }
            [_tableView reloadData];
        } else {
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
    }];
    
}

- (void)refreshView {
    _detail = [[RepairOrderInfo sharedRepairOrderInfo] getRepairOrderWithID:_carID];
    _serviceArray = [NSMutableArray array];
    for (NSDictionary *project in [_detail objectForKey:@"ConPros"]) {
        if (![[project objectForKey:@"Status"] isEqualToString:@"9"]) {
            [_serviceArray addObject:project];
        }
    }
    [_tableView reloadData];
}
- (IBAction)selectBtnAction:(UIButton *)sender {
    ServiceCell *cell = (ServiceCell *)sender.superview.superview;
    isSelect = !isSelect;
    if (isSelect) {
        [cell.selectBtn setImage:[UIImage imageNamed:@"selected"] forState:(UIControlStateNormal)];
    }else{
        [cell.selectBtn setImage:[UIImage imageNamed:@"noselected"] forState:(UIControlStateNormal)];
    }
    [[RepairOrderInfo sharedRepairOrderInfo].isSelectDict setObject:[NSString stringWithFormat:@"%d",isSelect] forKey:_carID];
}

- (IBAction)backButtonDidTouch:(id)sender {
    if (_isRework) {
        [[RepairOrderInfo sharedRepairOrderInfo] removeObjectWithCarID:_carID];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)receiveButtonDidTouch:(id)sender {
    [self performSegueWithIdentifier:@"Assign" sender:sender];
}

- (IBAction)finishButtonDidTouch:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *dict = [[RepairOrderInfo sharedRepairOrderInfo] getRepairPersonOptionWithCarID:_carID];
    if (dict == nil) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    NSMutableDictionary *option= [NSMutableDictionary dictionaryWithDictionary:dict];
    if (!_isRework) {
        [option setObject:[RepairOrderInfo sharedRepairOrderInfo].isSelectDict[_carID] forKey:@"IsCheck"];
    }
    
    [[HttpClient sharedHttpClient] repairPerson:option isRework:_isRework success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@", responseObject);
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            [[RepairOrderInfo sharedRepairOrderInfo] removeObjectWithCarID:_carID];
            _sender.shouldRefresh = YES;
            if (_isRework) {
                [self performSegueWithIdentifier:@"toRepairVCFromCarInfo" sender:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@", error);
        [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Assign"]) {
        AddWorkerViewController *toView = segue.destinationViewController;
        toView.sender = sender;
        toView.carID = _carID;
        toView.sectionCount = [_serviceArray count] - 1;
        toView.sourceViewController = self;
        toView.serviceArray = _serviceArray;
        if (((UIButton *)sender).tag == 100) {
        }
        if ([((UIButton *)sender).titleLabel.text isEqualToString:@"变更"]) {
            toView.workerStatus = [[RepairOrderInfo sharedRepairOrderInfo] getWorkersWithIndex:((UIButton *)sender).tag inCarID:_carID];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.navigationController.viewControllers count] > 1) {
        return YES;
    }
    return NO;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_detail) {
        if (_isRework){
            return [_serviceArray count]+1;
        } else if (_isExtended) {
            return [_serviceArray count]+2;
        }
        return [_serviceArray count]+3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_detail) {
        if (_isRework){
            if (section == 0) {
                return 1;
            } else {
                return [[_serviceArray[section-1] objectForKey:@"Workers"] count]+1;
            }
            
        }else if (_isExtended) {
            if (section <= 1) {
                return 1;
            } else {
                return [[_serviceArray[section-2] objectForKey:@"Workers"] count]+1;
            }
        }else {
            if (section <= 2) {
                return 1;
            } else {
                return [[_serviceArray[section-3] objectForKey:@"Workers"] count]+1;
            }
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isRework) {
        return 48;
    }else{
        if (indexPath.section == 0) {
            return 236;
        } else {
            return 48;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isRework) {
        if (section == 1) {
            return 30;
        }else if (section > 1){
            return 0;
        }else{
            return 10;
        }
    }else if (_isExtended) {
        if (section == 0 || section == 2) {
            return 30;
        }else if (section > 2){
            return 0;
        }else{
            return 10;
        }
    } else {
        if (section == 0 || section == 3) {
            return 30;
        }else if (section > 3){
            return 0;
        }else{
            return 10;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *newIndexPath = indexPath;
    if (!_isRework) {
        if (newIndexPath.section == 0) {
            CarInfoCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"CarInfoCell"];
            if (!cell) {
                cell = [[CarInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CarInfoCell"];
            }
            cell.carLabel.text = [_detail objectForKey:@"LicenNum"];
            cell.carCatalogLabel.text = [_detail objectForKey:@"CarBrand"];
            cell.carTypeLabel.text = [_detail objectForKey:@"MotoType"];
            cell.buildFactoryLabel.text = [_detail objectForKey:@"CarBrand"];
            cell.carType2Label.text = [_detail objectForKey:@"MotoType"];
            cell.idLabel.text = [_detail objectForKey:@"ConNo"];
            cell.frontLabel.text = [_detail objectForKey:@"ServerConsultant"];
            cell.upTimeLabel.text = [_detail objectForKey:@"PickupCarTime"];
            if ([_carInfoType isEqualToString:FINISH] || [_carInfoType isEqualToString:MYFINISH]) {
                cell.handoffTimeLabel.text = [_detail objectForKey:@"FinishTime"];
            } else {
                cell.handoffTimeLabel.text = [_detail objectForKey:@"PlanLeaveFacDate"];
                
            }
            return cell;
        }
        newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
        
        if (!_isExtended) {
            if (newIndexPath.section == 0) {
                ServiceCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
                cell.serviceLabel.text = @"车辆检测";
                cell.selectBtn.hidden = NO;
                if ([[RepairOrderInfo sharedRepairOrderInfo].isSelectDict[_carID] boolValue]) {
                    [cell.selectBtn setImage:[UIImage imageNamed:@"selected"] forState:(UIControlStateNormal)];
                }else{
                    [cell.selectBtn setImage:[UIImage imageNamed:@"noselected"] forState:(UIControlStateNormal)];
                }
                cell.receiveButton.hidden = YES;
                return cell;
            }
            newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section - 1];
        }
    }
    if (newIndexPath.row == 0) {
        if (newIndexPath.section == 0) {
            ServiceCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
            cell.serviceLabel.text = @"默认派工";
            cell.receiveButton.tag = 100;
            cell.selectBtn.hidden = YES;
            cell.receiveButton.hidden = NO;
            if (_isAllFinished) {
                [cell.receiveButton setEnabled:NO];
                [cell.receiveButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            } else {
                [cell.receiveButton setEnabled:YES];
                [cell.receiveButton setTitleColor:UIColorFromRGB(0x194F95) forState:UIControlStateNormal];
            }
            return cell;
        } else {
            ServiceCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
            cell.serviceLabel.text = [_serviceArray[newIndexPath.section-1] objectForKey:@"ProjectName"];
            cell.selectBtn.hidden = YES;
            cell.receiveButton.hidden = NO;
            if ([[_serviceArray[newIndexPath.section-1] objectForKey:@"Status"] isEqualToString:@"2"]) {
                [cell.receiveButton setEnabled:NO];
                [cell.receiveButton setTitle:@"已完工" forState:UIControlStateNormal];
                [cell.receiveButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            } else {
                [cell.receiveButton setEnabled:YES];
                if ([[_serviceArray[newIndexPath.section-1] objectForKey:@"ProjectStatus"] isEqualToString:@"1"]) {
                    [cell.receiveButton setTitle:@"变更" forState:UIControlStateNormal];
                } else {
                    [cell.receiveButton setTitle:@"指派" forState:UIControlStateNormal];
                }
                [cell.receiveButton setTitleColor:UIColorFromRGB(0x194F95) forState:UIControlStateNormal];
            }
            cell.receiveButton.tag = newIndexPath.section - 1;
            return cell;
        }
    } else {
        WorkerCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"WorkerCell"];
        if (!cell) {
            cell = [[WorkerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WorkerCell"];
        }
        cell.carID = _carID;
        cell.section = newIndexPath.section;
        cell.workerLabel.text = [[_serviceArray[newIndexPath.section-1] objectForKey:@"Workers"][newIndexPath.row-1] objectForKey:@"Name"];
        cell.workTimeTextField.text = [[_serviceArray[newIndexPath.section-1] objectForKey:@"Workers"][newIndexPath.row-1] objectForKey:@"WorkTime"];
        cell.workTimeTextField.tag = newIndexPath.row;
        cell.workTimeTextField.delegate = cell;
        cell.moneyTextField.text = [[_serviceArray[newIndexPath.section-1] objectForKey:@"Workers"][newIndexPath.row-1] objectForKey:@"Price"];
        cell.moneyTextField.tag = newIndexPath.row;
        cell.moneyTextField.delegate = cell;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SectionView *sectionView = [[NSBundle mainBundle]loadNibNamed:@"SectionView" owner:self options:nil].lastObject;
    NSArray *titleArray;
    if (_isRework) {
        titleArray = @[@"", @"服务项目"];
    }else if (_isExtended){
        titleArray = @[@"基本信息", @"", @"服务项目"];
    }else{
        titleArray = @[@"基本信息", @"", @"", @"服务项目"];
    }
    sectionView.sectionLabel.text = titleArray[section];
    return sectionView;
}


@end
