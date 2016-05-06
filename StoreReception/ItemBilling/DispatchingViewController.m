//
//  DispatchingViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "DispatchingViewController.h"
#import "DispatchTopTableViewCell.h"
#import "PersonContentTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "ZAActivityBar.h"
#import "DispatchPersonViewController.h"
#import "DispatchServiceView.h"
static NSString *headCell = @"headCell";
static NSString *personCell = @"personCell";
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface DispatchingViewController () {
    NSDictionary *resultInfo;
    NSMutableArray *conPros;
    PersonContentTableViewCell *currentCell;
    BOOL keyboardIsShowing;
    float keyboardHeight;
    float tableHeight;
}

@end

@implementation DispatchingViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"接车单";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    if ([_type isEqualToString:REPAIRPERSON]) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(250, 0, 44, 44)];
        [rightBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.enabled = NO;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (BOOL)checkTimeOrAccount {//计算该项目派工累计的工时或者金额不可超过项目的工时和金额
    for (int i = 0; i < conPros.count; i++) {
        NSDictionary *dict = conPros[i];
        NSString *projName = dict[@"ProjectName"];
        NSMutableArray *array = dict[@"persons"];
        float totalPay = [dict[@"TotalPay"] floatValue];
        float workTime = [dict[@"workTime"] floatValue];
        float price = 0;
        float time = 0;
        for (int j = 0; j < array.count; j++) {
            NSDictionary *person = array[j];
            price += [person[@"price"] floatValue];
            time += [person[@"time"] floatValue];
            if (price > totalPay) {
                [ZAActivityBar showErrorWithStatus:[NSString stringWithFormat:@"派工金额合计不可超过［%@］的金额",projName]];
                return false;
            }
            if (time > workTime) {
                [ZAActivityBar showErrorWithStatus:[NSString stringWithFormat:@"派工工时合计不可超过［%@］的工时",projName]];
                return false;
            }
        }
    }
    return YES;
}

- (void)doneAction {
    BOOL bol = NO;
    [currentCell.priceTextField endEditing:YES];
    [currentCell.timeTextField endEditing:YES];
    NSMutableArray *mutArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < conPros.count; i++) {
        NSDictionary *dict = conPros[i];
        NSString *projId = dict[@"ProjectID"];
        NSMutableArray *array = dict[@"persons"];
        if (array.count == 0) {
            bol = YES;
        }
        for (int i = 0; i < array.count; i++) {
            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *person = [array[i] mutableCopy];
            NSString *time = person[@"time"];
            NSString *pricestr = person[@"price"];
            float price = 0;
            float workTime = 0;
            if (array > 0) {
                price = [dict[@"TotalPay"] floatValue] / array.count;
                workTime = [dict[@"workTime"] floatValue] / array.count;
            }
            if (!time) {
                time = [NSString stringWithFormat:@"%.2f",workTime];
            }
            if (!pricestr) {
                pricestr = [NSString stringWithFormat:@"%.2f",price];
            }
            [person setObject:time forKey:@"time"];
            [person setObject:pricestr forKey:@"price"];
            [array removeObjectAtIndex:i];
            [array insertObject:person atIndex:i];
            [info setObject:projId forKey:@"ProjectId"];
            [info setObject:time forKey:@"WorkTime"];
            [info setObject:pricestr forKey:@"Price"];
            [info setObject:person[@"Name"] forKey:@"Name"];
            [info setObject:person[@"FID"] forKey:@"UserID"];
            [mutArray addObject:info];
        }
    }
    if (!bol) {
        if ([self checkTimeOrAccount]) {
            [self repairPerson:mutArray];
            if (_repaireComplete) {
                _repaireComplete();
            }
        }
    }else {
        [ZAActivityBar showErrorWithStatus:@"请完成指派技师"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    UINib *headNib = [UINib nibWithNibName:@"DispatchTopTableViewCell" bundle:nil];
    UINib *personNib = [UINib nibWithNibName:@"PersonContentTableViewCell" bundle:nil];
    [_tableView registerNib:headNib forCellReuseIdentifier:headCell];
    [_tableView registerNib:personNib forCellReuseIdentifier:personCell];
    [self repairItemDesc];
    // Do any additional setup after loading the view from its nib.
}

- (void)setPersonValue:(NSInteger)section value:(NSString *)value key:(NSString *)key row:(NSInteger)row{
    NSMutableDictionary *info = conPros[section - 2];
    NSMutableArray *array = info[@"persons"];
    NSDictionary *person = array[row];
    NSMutableDictionary *mutPerson = [person mutableCopy];
    [mutPerson setObject:value forKey:key];
    [array removeObjectAtIndex:row];
    [array insertObject:mutPerson atIndex:row];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else if (section == 1) {
        return 0;
    }else {
        NSMutableDictionary *info = conPros[section - 2];
        NSArray *array = info[@"persons"];
        return array.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + conPros.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            DispatchTopTableViewCell *dttvc = [tableView dequeueReusableCellWithIdentifier:headCell];
            dttvc.linceL.text = resultInfo[@"LicenNum"];
            dttvc.ppL.text = resultInfo[@"CarBrand"];
            dttvc.xhL.text = resultInfo[@"MotoType"];
            dttvc.zzcsL.text = resultInfo[@"CarBrand"];
            dttvc.clcxL.text = resultInfo[@"MotoType"];
            dttvc.gdhmL.text = resultInfo[@"ConNo"];
            dttvc.qtL.text = resultInfo[@"ServerConsultant"];
            dttvc.sxsjL.text = resultInfo[@"PickupCarTime"];
            dttvc.jcsjL.text = resultInfo[@"PlanLeaveFacDate"];
            return dttvc;
        }else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = UIColorFromRGB(0xF3F3F3);
            }
            return cell;
        }
    }else if (indexPath.section > 1){
        NSMutableDictionary *info = conPros[indexPath.section - 2];
        NSMutableArray *persons = info[@"persons"];
        NSMutableDictionary *dict = persons[indexPath.row];
        PersonContentTableViewCell *dstvc = [tableView dequeueReusableCellWithIdentifier:personCell];
        dstvc.tag = indexPath.row;
        float price = 0;
        float workTime = 0;
        if (persons > 0) {
            price = [info[@"TotalPay"] floatValue] / persons.count;
            workTime = [info[@"workTime"] floatValue] / persons.count;
        }
        NSLog(@"aa:  %@",dstvc.priceTextField.text);
        NSLog(@"bb:  %@",dstvc.timeTextField.text);
        if (!dict[@"price"]) {
            dstvc.priceTextField.text = [NSString stringWithFormat:@"%.2f",price];
        }
        if (!dict[@"time"]) {
            dstvc.timeTextField.text = [NSString stringWithFormat:@"%.2f",workTime];
        }
        dstvc.nameL.text = dict[@"Name"];
        dstvc.passPrice = ^(NSString *price) {
            [self setPersonValue:indexPath.section value:price key:@"price" row:indexPath.row];
        };
        dstvc.passValue = ^(NSString *value) {
            [self setPersonValue:indexPath.section value:value key:@"time" row:indexPath.row];
        };
        dstvc.passCurrentCell = ^(PersonContentTableViewCell *cell) {
            currentCell = cell;
        };
        dstvc.tag = indexPath.section - 2;
        dstvc.lineV.hidden = YES;
        if (indexPath.row == persons.count - 1) {
            dstvc.lineV.hidden = NO;
        }
        return dstvc;
    }
    return nil;
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

- (void)click:(UIButton *)sender {
    [currentCell.priceTextField endEditing:YES];
    [currentCell.timeTextField endEditing:YES];
    NSInteger tag = sender.tag;
    NSMutableDictionary *info = conPros[tag - 2];
    DispatchPersonViewController *dpvc = [[DispatchPersonViewController alloc] initWithNibName:@"DispatchPersonViewController" bundle:nil];
    dpvc.persons = info[@"persons"];
    dpvc.passPerson = ^(NSMutableArray *persons) {
        [info setObject:persons forKey:@"persons"];
        [_tableView reloadData];
    };
    [self.navigationController pushViewController:dpvc animated:YES];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DispatchServiceView *dsv = [[[NSBundle mainBundle] loadNibNamed:@"DispatchServiceView" owner:self options:nil] lastObject];
    dsv.repaireBtn.hidden = YES;
    if (section == 0) {
        dsv.serviceNameL.text = @"基本信息";
        dsv.workTimeL.hidden = YES;
        dsv.accountL.hidden = YES;
    }else if (section == 1) {
        dsv.serviceNameL.text = @"服务项目";
        dsv.workTimeL.hidden = YES;
        dsv.accountL.hidden = YES;
    }else {
        NSDictionary *info = conPros[section - 2];
        dsv.serviceNameL.text = info[@"ProjectName"];
        NSArray *array = info[@"persons"];
        if (array.count == 0) {
            [dsv.repaireBtn setTitle:@"指派" forState:UIControlStateNormal];
        }else {
            [dsv.repaireBtn setTitle:@"变更" forState:UIControlStateNormal];
        }
        if (![_type isEqualToString:DETAIL]) {
            dsv.repaireBtn.hidden = NO;
        }
        NSString *workTime = info[@"workTime"];
        NSString *totalPay = info[@"TotalPay"];
        float time = 0;
        float price = 0;
        if (workTime) {
            time = [workTime floatValue];
        }
        if (totalPay) {
            price = [totalPay floatValue];
        }
        dsv.workTimeL.text = [NSString stringWithFormat:@"工时：%.2f",time];
        dsv.accountL.text = [NSString stringWithFormat:@"金额：%.2f",price];
        [dsv.repaireBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        dsv.repaireBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        dsv.repaireBtn.tag = section;
        [dsv.repaireBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return dsv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 250;
        }else {
            return 30;
        }
    }else {
        return 44 ;
    }
}


#pragma mark - request
- (void)repairItemDesc {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"ConId":_orderId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,RepairItemDesc];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            resultInfo = [[NSDictionary alloc] initWithDictionary:responseObject[@"Result"]];
            NSArray *array = resultInfo[@"ConPros"];
            conPros = [[NSMutableArray alloc] init];
            for (int i = 0; i < array.count; i++) {
                NSDictionary *dict = array[i];
                NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:dict];
                [info setObject:[[NSMutableArray alloc] init] forKey:@"persons"];
                [conPros addObject:info];
            }
            NSLog(@"result:   %@",responseObject);
            [_tableView reloadData];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

- (void)repairPerson:(NSMutableArray *)mutArray {
    [ZAActivityBar showWithStatus:LODING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"MentId":_orderId,@"giveRepairs":mutArray};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,RepairPerson];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [ZAActivityBar showSuccessWithStatus:responseObject[@"Message"]];
            [self performSelector:@selector(backAction) withObject:nil afterDelay:0.5];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
