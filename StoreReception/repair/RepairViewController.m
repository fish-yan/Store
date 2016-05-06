//
//  RepairViewController.m
//  Repair
//
//  Created by Kassol on 15/9/8.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "RepairViewController.h"
#import "RepairCell.h"
#import "MJRefresh.h"
#import "HttpClient.h"
#import "JDStatusBarNotification.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "CarInfoCell.h"
#import "SectionView.h"
#import "ServiceCell.h"
#import "CheckListViewController.h"
#import "CarInfoViewController.h"

@interface RepairViewController (){
    NSDictionary *userInfo;
    NSString *userId;
    NSString *token;
    BOOL finishLoad;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) NSMutableArray *serviceArray;
@property (strong, nonatomic) NSMutableDictionary *serviceStatus;
@property (strong, nonatomic) NSDictionary *detail;

@end

@implementation RepairViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    userId = [userInfo objectForKey:@"UserId"];
    token = [userInfo objectForKey:@"Token"];
    _serviceStatus = [NSMutableDictionary dictionary];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSMutableDictionary *option = [NSMutableDictionary dictionary];
        NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
        [userToken setObject:userId forKey:@"UserId"];
        [userToken setObject:token forKey:@"Token"];
        [option setObject:_conId forKey:@"ConId"];
        [option setObject:userToken forKey:@"UserToken"];
        NSLog(@"%@",option);
        
        [self getCarInfoDetailWithOption:option];
        [self getServiceListWithOption:option];
        
    }];
    [_tableView.header beginRefreshing];
}

- (void)getCarInfoDetailWithOption:(NSMutableDictionary *)option{
    [[HttpClient sharedHttpClient] getDetailWithType:_status option:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            _detail = [(NSDictionary *)responseObject objectForKey:@"Result"];
            if (_detail && _serviceArray) {
                finishLoad = YES;
            }else{
                finishLoad = NO;
            }
            if (finishLoad) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
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

- (void)getServiceListWithOption:(NSMutableDictionary *)option{
    [[HttpClient sharedHttpClient] getServiceItem:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [_tableView.header endRefreshing];
        _serviceArray = [NSMutableArray array];
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            [_finishButton setHidden:NO];
            for (NSDictionary *service in [(NSDictionary *)responseObject objectForKey:@"Result"]) {
                if (![[service objectForKey:@"Status"] isEqualToString:@"9"]) {
                    [_serviceArray addObject:service];
                }
            }
            BOOL isAllFinished = YES;
            for (NSInteger i = 0; i < _serviceArray.count; ++i) {
                if ([[_serviceArray[i] objectForKey:@"Status"] isEqualToString:@"2"]) {
                    [_serviceStatus setObject:@"2" forKey:[_serviceArray[i] objectForKey:@"ID"]];
                } else {
                    isAllFinished = NO;
                    [_serviceStatus setObject:@"0" forKey:[_serviceArray[i] objectForKey:@"ID"]];
                }
            }
            if (isAllFinished) {
                [_finishButton setTitle:@"提交质检" forState:UIControlStateNormal];
            } else {
                [_finishButton setTitle:@"提交项目" forState:UIControlStateNormal];
            }
            if (_detail && _serviceArray) {
                finishLoad = YES;
            }else{
                finishLoad = NO;
            }
            if (finishLoad) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            [_tableView reloadData];
        } else {
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_tableView.header endRefreshing];
        NSLog(@"%@", error);
        [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backButtonDidTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)unwindToRepairVC:(UIStoryboardSegue *)segue{
    _isChecked = @"2";
    _sender.shouldRefresh = YES;
    [_tableView reloadData];
}

- (IBAction)unwindToRePairVCFromCarInfoVC:(UIStoryboardSegue *)sender{
    [_tableView.header beginRefreshing];
}

- (IBAction)finishButtonDidTouch:(id)sender {
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    [option setObject:_conId forKey:@"ConId"];
    NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
    [userToken setObject:userId forKey:@"UserId"];
    [userToken setObject:token forKey:@"Token"];
    [option setObject:userToken forKey:@"UserToken"];
    
    if ([_finishButton.titleLabel.text isEqualToString:@"提交项目"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"确定完成所选项目？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else if ([_finishButton.titleLabel.text isEqualToString:@"提交质检"]){
        [option setObject:@"3" forKey:@"CheckId"];
        NSLog(@"%@",option);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpClient sharedHttpClient] subimtCheck:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"%@",responseObject);
            if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
                _sender.shouldRefresh = YES;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
        }];
    }
    
}

- (IBAction)selectButtonDidTouch:(id)sender {
    if ([[_serviceStatus objectForKey:[_serviceArray[((UIButton *)sender).tag] objectForKey:@"ID"]]  isEqualToString: @"2"]) {
        return;
    } else if ([[_serviceStatus objectForKey:[_serviceArray[((UIButton *)sender).tag] objectForKey:@"ID"]]  isEqualToString: @"1"]) {
        [_serviceStatus setObject:@"0" forKey:[_serviceArray[((UIButton *)sender).tag] objectForKey:@"ID"]];
        [_tableView reloadData];
    } else {
        [_serviceStatus setObject:@"1" forKey:[_serviceArray[((UIButton *)sender).tag] objectForKey:@"ID"]];
        [_tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    CarInfoViewController *carInfoVC = segue.destinationViewController;
    carInfoVC.isRework = YES;
    carInfoVC.carID = [_detail objectForKey:@"ID"];
    carInfoVC.carInfoType = _status;
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
    if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
        return 4;
    }else{
        return 3;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (finishLoad) {
        if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
            if (section <= 2) {
                return 1;
            }else{
                return [_serviceArray count];
            }
        }else{
            if (section <= 1) {
                return 1;
            }else{
                return [_serviceArray count];
            }
        }

    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (finishLoad) {
        if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
            if (indexPath.section == 0) {
                return 236;
            } else if(indexPath.section == 3) {
                return 74;
            } else {
                return 48;
            }
        }else{
            if (indexPath.section == 0) {
                return 236;
            } else if(indexPath.section == 2) {
                return 74;
            } else {
                return 48;
            }
        }
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (finishLoad) {
        if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
            if (section == 1 || section == 2) {
                return 10;
            }
            return 30;
        }else{
            if (section == 1) {
                return 10;
            }
            return 30;
        }
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"Rework" sender:nil];
    }else if (indexPath.section == 2 && ([_isChecked isEqualToString:@"1"])){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CarCheck" bundle:nil];
        CheckListViewController *checkList = [storyboard instantiateViewControllerWithIdentifier:@"CheckList"];
        checkList.carNum = [_detail objectForKey:@"LicenNum"];
        checkList.pickupCarTime = [_detail objectForKey:@"PickupCarTime"];
        checkList.carId = [_detail objectForKey:@"ID"];
        [self.navigationController pushViewController:checkList animated:YES];
    }
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
        if ([_status isEqualToString:FINISH] || [_status isEqualToString:MYFINISH]) {
            cell.handoffTimeLabel.text = [_detail objectForKey:@"FinishTime"];
        } else {
            cell.handoffTimeLabel.text = [_detail objectForKey:@"PlanLeaveFacDate"];
            
        }
        return cell;
    }else if (indexPath.section == 1){
        ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
        cell.serviceLabel.text = @"重新派工";
        cell.selectBtn.hidden = NO;
        cell.receiveButton.hidden = YES;
        [cell.selectBtn setImage:[UIImage imageNamed:@"next"] forState:(UIControlStateNormal)];
        cell.selectBtn.userInteractionEnabled = NO;
        return cell;
    }
    if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
        if (indexPath.section == 2) {
            ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
            cell.serviceLabel.text = @"车辆检测";
            cell.selectBtn.hidden = NO;
            cell.receiveButton.hidden = YES;
            if ([_isChecked isEqualToString:@"1"]) {
                [cell.selectBtn setImage:[UIImage imageNamed:@"next"] forState:(UIControlStateNormal)];
                [cell.selectBtn setTitle:nil forState:(UIControlStateNormal)];
            }else{
                [cell.selectBtn setImage:nil forState:(UIControlStateNormal)];
                [cell.selectBtn setTitle:@"已车检" forState:(UIControlStateNormal)];
            }
            cell.selectBtn.userInteractionEnabled = NO;
            return cell;
        }
        
    }
    
    RepairCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"RepairCell"];
    if (!cell) {
        cell = [[RepairCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RepairCell"];
    }
    cell.serviceLabel.text = [_serviceArray[indexPath.row] objectForKey:@"ProjectName"];
    cell.personLabel.text = [_serviceArray[indexPath.row] objectForKey:@"RepairPersons"];
    cell.selectButton.tag = indexPath.row;
    NSLog(@"%@",[_serviceStatus objectForKey:[_serviceArray[indexPath.row] objectForKey:@"ID"]]);
    if ([[_serviceStatus objectForKey:[_serviceArray[indexPath.row] objectForKey:@"ID"]] isEqualToString:@"2"]) {
        [cell.selectButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    } else if ([[_serviceStatus objectForKey:[_serviceArray[indexPath.row] objectForKey:@"ID"]] isEqualToString:@"1"]) {
        [cell.selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    } else {
        [cell.selectButton setImage:[UIImage imageNamed:@"noselected"] forState:UIControlStateNormal];
    }
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SectionView *sectionView = [[NSBundle mainBundle]loadNibNamed:@"SectionView" owner:self options:nil].lastObject;
    NSArray *titleArray;
    if ([_isChecked isEqualToString:@"1"] || [_isChecked isEqualToString:@"2"]) {
        titleArray = @[@"基本信息",@"",@"",@"服务项目"];
    }else{
        titleArray = @[@"基本信息",@"",@"服务项目"];
    }
    sectionView.sectionLabel.text = titleArray[section];
    return sectionView;
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        NSMutableDictionary *option = [NSMutableDictionary dictionary];
        NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
        NSString *userName = userInfo[@"UserName"];
        [userToken setObject:userId forKey:@"UserId"];
        [userToken setObject:token forKey:@"Token"];
        [option setObject:userName forKey:@"UserName"];
        [option setObject:userId forKey:@"UserId"];
        [option setObject:userToken forKey:@"UserToken"];
        NSMutableArray *finishRepairs = [NSMutableArray array];
        for (NSString *key in _serviceStatus.keyEnumerator) {
            if ([[_serviceStatus objectForKey:key] isEqualToString:@"1"]) {
                NSMutableDictionary *finishRepair = [NSMutableDictionary dictionary];
                [finishRepair setObject:key forKey:@"conProjectId"];
                [finishRepair setObject:@"2" forKey:@"Status"];
                [finishRepairs addObject:finishRepair];
            }
        }
        if (finishRepairs.count == 0) {
            return;
        }
        [option setObject:[NSNumber numberWithUnsignedInteger:finishRepairs.count] forKey:@"TotalCount"];
        [option setObject:finishRepairs forKey:@"finishRepairs"];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpClient sharedHttpClient] finishRepair:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
                [_serviceStatus removeAllObjects];
                [_tableView.header beginRefreshing];
            } else {
                [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
        }];
    }
}

@end
