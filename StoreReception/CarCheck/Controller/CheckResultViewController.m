//
//  CheckResultViewController.m
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/1.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CheckResultViewController.h"
#import "HeaderView.h"
#import "CheckResultCell.h"
#import "CheckModel.h"
#import "HttpClient.h"
#import "JDStatusBarNotification.h"
#import "MBProgressHUD.h"
#import "NIncreaseViewController.h"
#import "HomeViewController.h"
#import "MJRefresh.h"

@interface CheckResultViewController ()<UITableViewDataSource, UITableViewDelegate>{
    BOOL allSelected;
}
@property (weak, nonatomic) IBOutlet UILabel *carNumLab;
@property (weak, nonatomic) IBOutlet UILabel *checkTimeLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *handleViewBottomMargin;

@property (nonatomic, strong) NSMutableDictionary *passDict;
@property (nonatomic, retain) UIImage *selectImage;
@property (nonatomic, assign) NSInteger scores;
@property (nonatomic, strong) HeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *scoresArray;
@property (nonatomic, strong) NSMutableArray *selectArray;
//@property (nonatomic, strong) NSMutableArray *nameArray;
@property (nonatomic, strong) NSMutableArray *serviceArray;
@property (copy, nonatomic) void (^passServiceArray)(NSMutableArray *);
@property (nonatomic, assign) BOOL isWorking;
@end

@implementation CheckResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scoresArray = [NSMutableArray array];
    self.serviceArray = [NSMutableArray array];
//    self.nameArray = [NSMutableArray array];
    self.selectArray = [NSMutableArray array];
    [self addHeaderView];
    _handleViewBottomMargin.constant = -50;
    [self isSelectAll];
    if (_isFromeCheckList) {
        [self readDataSourceFromeList];
        NSLog(@"%@",self.dataArray);
        UIBarButtonItem *commitItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:(UIBarButtonItemStylePlain) target:self action:@selector(commitItemAction:)];
        commitItem.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = commitItem;
    }else{
        self.dataArray = [NSMutableArray array];
        [self readDataSouceFromNet];
        
    }
    // Do any additional setup after loading the view.
}
- (void)addHeaderView {
    CGFloat height = (kScreenWidth - 40) / 3 * 2 + 60;
    self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    self.headerView = [[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:self options:nil].lastObject;
    self.headerView.frame = CGRectMake(0, -height-1, kScreenWidth, height);
    [self.tableView addSubview:self.headerView];
}

- (void)readDataSourceFromeList{
    NSInteger FDJ = 0, BSX = 0, LQ = 0, DP = 0, ZD = 0, KT = 0;
    for (CheckModel *model in self.dataArray) {
        
        if ([model.type isEqualToString:@"发动机"]) {
            FDJ += model.scores;
        }else if ([model.type isEqualToString:@"变速箱"]) {
            BSX += model.scores;
        }else if ([model.type isEqualToString:@"冷却"]) {
            LQ += model.scores;
        }else if ([model.type isEqualToString:@"底盘"]) {
            DP += model.scores;
        }else if ([model.type isEqualToString:@"制动"]) {
            ZD += model.scores;
        }else if ([model.type isEqualToString:@"空调"]) {
            KT += model.scores;
        }
        self.scores += model.scores;
    }
    self.scores +=100;
    self.scoresArray = @[[NSNumber numberWithInteger:FDJ], [NSNumber numberWithInteger:BSX],[NSNumber numberWithInteger:LQ],[NSNumber numberWithInteger:DP],[NSNumber numberWithInteger:ZD],[NSNumber numberWithInteger:KT]].mutableCopy;
    [self loadScores];
    NSString *timeStr = [NSString stringWithFormat:@"检测日期: %@",self.pickupCarTime];
    self.checkTimeLab.text = [timeStr substringToIndex:timeStr.length - 3];
}

- (void)loadScores{
    for (int i = 0; i < self.headerView.imageViews.count; i++) {
        if ([self.scoresArray[i] integerValue] == 0) {
            [self.headerView.imageViews[i] setImage:[UIImage imageNamed:@"blue"]];
        }else if ([self.scoresArray[i] integerValue] >= -4){
            [self.headerView.imageViews[i] setImage:[UIImage imageNamed:@"yellow"]];
        }else{
            [self.headerView.imageViews[i] setImage:[UIImage imageNamed:@"red"]];
        }
    }
    self.carNumLab.text = [NSString stringWithFormat:@"车牌号码: %@", self.carNum];
    self.headerView.scoresLab.text = [NSString stringWithFormat:@"%ld",self.scores];
}

- (void)readDataSouceFromNet {
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *userToken = @{@"UserId":[userInfo objectForKey:@"UserId"],@"Token":[userInfo objectForKey:@"Token"]};
    NSDictionary *option = @{@"Id":_carId,@"UserToken":userToken};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpClient sharedHttpClient]getCarCheckDesc:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([responseObject[@"Code"] integerValue] == 0) {
            NSDictionary *resultDict = responseObject[@"Result"];
            
            NSString *str = resultDict[@"Remark"];
            NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e;
            NSArray *remarkArray = [NSJSONSerialization JSONObjectWithData:data options:nil error:&e];
            if ([resultDict[@"consuDesc"][@"OrderStatus"] isEqualToString:@"施工中"] && remarkArray.count != 0) {
                _isWorking = YES;
                _handleViewBottomMargin.constant = 0;
            }else{
                _isWorking = NO;
                _handleViewBottomMargin.constant = -50;;
            }
            
            NSArray *array = @[@"EngineScore",@"SpeedScore",@"CoolScore",@"ChassisScore",@"BreakScore",@"AirScore"];
            self.scoresArray = [NSMutableArray array];
            for (NSString *key in array) {
                [self.scoresArray addObject:resultDict[key]];
            }
            self.scores = [resultDict[@"TotalScore"] integerValue];
            [self loadScores];
            NSString *timeStr = [NSString stringWithFormat:@"检测日期: %@",resultDict[@"CheckDate"]];
            self.checkTimeLab.text = [timeStr substringToIndex:timeStr.length - 3];
            
            for (NSDictionary *dict in remarkArray) {
                CheckModel *model = [[CheckModel alloc]init];
                model.allTitle = dict[@"Title"];
                model.badCount = [dict[@"BadLevel"] integerValue];
                model.problem = dict[@"Content"];
                model.isSelected = YES;
                model.name = dict[@"ProjectName"];
//                NSString *str = dict[@"name"];
//                if (str.length > 0) {
//                    [_nameArray addObject:str];
//                }
                [self.dataArray addObject:model];
            }
            self.passDict = [resultDict[@"consuDesc"] mutableCopy];
            [self.passDict setObject:resultDict[@"ConId"] forKey:@"ID"];
            self.selectArray = [self.dataArray mutableCopy];
            [self.tableView reloadData];
        }else{
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}

- (void)commitItemAction:(UIBarButtonItem *)sender {
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *userToken = @{@"UserId":[userInfo objectForKey:@"UserId"],@"Token":[userInfo objectForKey:@"Token"]};
    NSMutableDictionary *option = [NSMutableDictionary dictionary];
    option = @{@"TotalScore":self.headerView.scoresLab.text,
               @"CompanyId":[userInfo objectForKey:@"CompanyId"],
               @"StoreId":[userInfo objectForKey:@"StoreId"],
               @"CarNum":self.carNum,
               @"ConId":self.carId,
               @"CheckId":@"2",
               @"ServiceConsultant":[userInfo objectForKey:@"UserName"],
               @"ServiceConsultantID":[userInfo objectForKey:@"UserId"],
               @"UserToken":userToken }.mutableCopy;
    NSArray *array = @[@"EngineScore",@"SpeedScore",@"CoolScore",@"ChassisScore",@"BreakScore",@"AirScore"];
    for (int i  = 0; i < array.count; i++) {
        [option setObject:self.scoresArray[i] forKey:array[i]];
    }
    NSMutableArray *remarkArray = [NSMutableArray array];
    for (CheckModel *model in _dataArray) {
        NSDictionary *dict = @{@"Title":model.allTitle, @"Content":model.problem, @"BadLevel":[NSString stringWithFormat:@"%ld",model.badCount],@"ProjectName":model.name};
        [remarkArray addObject:dict];
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:remarkArray options:(NSJSONWritingPrettyPrinted) error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [option setObject:jsonString forKey:@"Remark"];
    NSLog(@"%@",option);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpClient sharedHttpClient]addCarCheck:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([responseObject[@"Code"] integerValue] == 0) {
            [self performSegueWithIdentifier:@"ToRepair" sender:nil];
        }else{
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}

- (IBAction)checkNowBtnAction:(UIButton *)sender {
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *userToken = @{@"UserId":[userInfo objectForKey:@"UserId"],@"Token":[userInfo objectForKey:@"Token"]};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block int i = 0;
    if (_selectArray.count == 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [JDStatusBarNotification showWithStatus:@"没有选择服务项" dismissAfter:2];
    }
    for (CheckModel *model in _selectArray) {
        NSDictionary *option = @{@"CompanyId":[userInfo objectForKey:@"CompanyId"],@"UserToken":userToken,@"Key":model.name};
        NSLog(@"%@",option);
        [[HttpClient sharedHttpClient]getProjects:option success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            i++;
            NSArray *array = responseObject[@"Result"][@"Projects"];
            if (array.count != 0 && model.name.length > 0) {
                [self.serviceArray addObject:array.firstObject];
            }
            if (i == self.selectArray.count) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NIncreaseViewController *invc = [[NIncreaseViewController alloc] init];
                invc.DataDict = _passDict;
                invc.isFromCarCheck = YES;
                invc.serArray = self.serviceArray;
                [self.navigationController pushViewController:invc animated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
        }];
    }
}

- (IBAction)selectAllBtnAction:(UIButton *)sender {
    for (CheckModel *model in self.dataArray) {

        if (allSelected) {
            [sender setImage:[UIImage imageNamed:@"checked"] forState:(UIControlStateNormal)];
            self.selectArray = [NSMutableArray arrayWithArray:self.dataArray];
            model.isSelected = YES;
        }else{
            [sender setImage:[UIImage imageNamed:@"uncheck"] forState:(UIControlStateNormal)];
            self.selectArray = [NSMutableArray array];
            model.isSelected = NO;
        }
    }
    
    allSelected = !allSelected;
    
    [self.tableView reloadData];
}

- (void)selectBtnAction:(UIButton *)sender{
    
    CheckResultCell *cell = (CheckResultCell *)((UIButton *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CheckModel *model = self.dataArray[indexPath.row];
    model.isSelected = !model.isSelected;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    if (model.isSelected) {
        [self.selectArray addObject:model];
    }else{
        [self.selectArray removeObject:model];
    }
    [self isSelectAll];
}

- (void)isSelectAll{
    BOOL isAll = YES;
    allSelected = YES;
    for (CheckModel *model in self.dataArray) {
        if (model.isSelected == NO) {
            isAll = NO;
        }
    }
    if (isAll) {
        [self selectAllBtnAction:self.selectAllBtn];
        allSelected = NO;
    }else{
        [self.selectAllBtn setImage:[UIImage imageNamed:@"uncheck"] forState:(UIControlStateNormal)];
    }
    
}
- (IBAction)backBtnItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckResultCell" forIndexPath:indexPath];
    CheckModel *model = self.dataArray[indexPath.row];
    cell.badCount = model.badCount;
    cell.problemLab.text = model.problem;
    cell.checkTitleLab.text = [NSString stringWithFormat:@"%ld、%@",indexPath.row + 1, model.allTitle] ;
    if (_isFromeCheckList || !_isWorking) {
        cell.selectBtn.hidden = YES;
        cell.problemLabRightMargin.constant = -27;
    }else{
        cell.selectBtn.hidden = NO;
        cell.problemLabRightMargin.constant = 10;
    }
    if (model.isSelected) {
        [cell.selectBtn setImage:[UIImage imageNamed:@"checked"] forState:(UIControlStateNormal)];
    }else{
        [cell.selectBtn setImage:[UIImage imageNamed:@"uncheck"] forState:(UIControlStateNormal)];
    }
    [cell.selectBtn addTarget:self action:@selector(selectBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    return cell;
}

#pragma mark - UITableViewDelegate

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
