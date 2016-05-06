//
//  CarCheckViewController.m
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/1.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CarCheckViewController.h"
#import "CarCheckCell.h"
#import "CheckResultViewController.h"
#import "HttpClient.h"
#import "JDStatusBarNotification.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"

@interface CarCheckViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    BOOL isCheck;
}
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *maskView;

@property (nonatomic, strong) NSMutableDictionary *option;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation CarCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.option = [NSMutableDictionary dictionary];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.searchTF.delegate = self;
    [self readDataSource];
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self readDataSource];
    }];
    // Do any additional setup after loading the view.
}
- (IBAction)searchBtnAction:(UIButton *)sender {
    [self readDataSource];
}

- (void)readDataSource{
    NSUserDefaults *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    [self.option setObject:[userInfo objectForKey:@"UserId"] forKey:@"ServiceConsultantID"];
    [self.option setObject:[userInfo objectForKey:@"CompanyId"] forKey:@"CompanyId"];
    [self.option setObject:[userInfo objectForKey:@"StoreId"] forKey:@"StoreId"];
    NSMutableDictionary *userToken = [NSMutableDictionary dictionary];
    [userToken setObject:[userInfo objectForKey:@"UserId"] forKey:@"UserId"];
    [userToken setObject:[userInfo objectForKey:@"Token"] forKey:@"Token"];
    [self.option setObject:userToken forKey:@"UserToken"];
    [self.option setObject:self.searchTF.text forKey:@"Key"];
    NSLog(@"%@",self.option);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpClient sharedHttpClient]getCarCheckList:self.option success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([responseObject[@"Code"] integerValue] == 0) {
            _dataSource = responseObject[@"Result"][@"list"];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        }else{
            [JDStatusBarNotification showWithStatus:[(NSDictionary *)responseObject objectForKey:@"Message"] dismissAfter:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [JDStatusBarNotification showWithStatus:NETWORK_ERRO dismissAfter:2];
    }];
}

//设置不同状态的button
- (void)changeButtonAction:(CarCheckCell *)cell{
    UIColor *checkBtnColor;
    UIColor *reportBtnColor;
    if (isCheck) {
        checkBtnColor = UIColorFromRGB(0xc3c3c3);
        reportBtnColor = UIColorFromRGB(0x2878D2);
        
        
    }else{
        checkBtnColor = UIColorFromRGB(0x2878D2);
        reportBtnColor = UIColorFromRGB(0xc3c3c3);
    }
    cell.checkBtn.layer.borderColor = checkBtnColor.CGColor;
    [cell.checkBtn setTitleColor:checkBtnColor forState:(UIControlStateNormal)];
    cell.checkBtn.userInteractionEnabled = !isCheck;
    cell.reportBtn.layer.borderColor = reportBtnColor.CGColor;
    [cell.reportBtn setTitleColor:reportBtnColor forState:(UIControlStateNormal)];
    cell.reportBtn.userInteractionEnabled = isCheck;
    [cell.checkBtn addTarget:self action:@selector(checkBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [cell.reportBtn addTarget:self action:@selector(reportBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];

}
- (void)checkBtnAction:(UIButton *)sender{
    
}
- (void)reportBtnAction:(UIButton *)sender{
    
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
    return _dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CarCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarCheckCell" forIndexPath:indexPath];
    cell.carNumLab.text = _dataSource[indexPath.row][@"CarNum"];
    [cell.checkBtn setTitle:_dataSource[indexPath.row][@"TotalScore"] forState:(UIControlStateNormal)];
    cell.reportBtn.hidden = YES;
    isCheck = YES;
    
    [self changeButtonAction:cell];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"CarCheck" sender:indexPath];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldChange:(NSNotification *)sender{
    if (self.searchTF.text.length == 0) {
        [self readDataSource];
    }
}

- (void)keyboardChange:(NSNotification *)sender{
    self.maskView.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.maskView.hidden = YES;
    [self.view endEditing:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    CheckResultViewController *checkResultVC = segue.destinationViewController;
    checkResultVC.isFromeCheckList = NO;
    checkResultVC.carNum = _dataSource[indexPath.row][@"CarNum"];
    checkResultVC.carId = _dataSource[indexPath.row][@"Id"];
}

@end
