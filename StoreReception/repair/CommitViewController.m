//
//  CommitViewController.m
//  StoreReception
//
//  Created by 薛焱 on 16/4/14.
//  Copyright © 2016年 cjm-ios. All rights reserved.
//

#import "CommitViewController.h"
#import "ServiceCell.h"
#import "RepairOrderInfo.h"
#import "MBProgressHUD.h"
#import "JDStatusBarNotification.h"
#import "HttpClient.h"
#import "Utils.h"
#import "CarInfoCell.h"
#import "SectionView.h"

@interface CommitViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSDictionary *userInfo;
    NSString *userId;
    NSString *token;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@property (strong, nonatomic) NSDictionary *detail;
@property (strong, nonatomic) NSMutableArray *serviceArray;
@end

@implementation CommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([_status isEqualToString:PREORDER]) {
        [_commitBtn setTitle:@"提交竣工" forState:(UIControlStateNormal)];
    }else if([_status isEqualToString:FINISH]){
        [_commitBtn setTitle:@"撤销结算" forState:(UIControlStateNormal)];
    }
    
    [self readDataSource];
    

    // Do any additional setup after loading the view.
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
    [[HttpClient sharedHttpClient] getDetailWithType:_status option:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
            _detail = [(NSDictionary *)responseObject objectForKey:@"Result"];
            _serviceArray = [NSMutableArray array];
            for (NSDictionary *project in [_detail objectForKey:@"ConPros"]) {
                if (![[project objectForKey:@"Status"] isEqualToString:@"9"]) {
                    [_serviceArray addObject:project];
                }
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
- (IBAction)commitBtnAction:(UIButton *)sender {
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    [option setObject:_carID forKey:@"ConId"];
    NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
    [userToken setObject:userId forKey:@"UserId"];
    [userToken setObject:token forKey:@"Token"];
    [option setObject:userToken forKey:@"UserToken"];
    [option setObject:[userInfo objectForKey:@"UserId"] forKey:@"UserId"];
    if ([_status isEqualToString:PREORDER]) {
        [option setObject:[userInfo objectForKey:@"UserName"] forKey:@"UserName"];
        [[HttpClient sharedHttpClient] finishLast:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
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

    }else{
        [[HttpClient sharedHttpClient] repairReturn:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([[(NSDictionary *)responseObject objectForKey:@"Code"] integerValue] == 0) {
                _sender.shouldRefresh = YES;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Result"] dismissAfter:2];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [JDStatusBarNotification showWithStatus:ERROR_CONNECTION dismissAfter:2];
        }];

    }
}

- (IBAction)backItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return _serviceArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    }else{
        ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
        cell.serviceLabel.text = [_serviceArray[indexPath.row] objectForKey:@"ProjectName"];
        cell.receiveButton.hidden = YES;
        cell.selectBtn.hidden = YES;
        return cell;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SectionView *sectionView = [[NSBundle mainBundle]loadNibNamed:@"SectionView" owner:self options:nil].lastObject;
    NSArray *titleArray = @[@"基本信息", @"服务项目"];
    sectionView.sectionLabel.text = titleArray[section];
    return sectionView;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 236;
    }else{
        return 48;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}



@end
