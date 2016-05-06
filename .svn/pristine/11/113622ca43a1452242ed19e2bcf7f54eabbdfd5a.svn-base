//
//  DispatchPersonViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/10/29.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//  派工
//

#import "DispatchPersonViewController.h"
#import "DispatchPersonTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "ZAActivityBar.h"

static NSString *persionCell = @"persionCell";
@interface DispatchPersonViewController () {
    NSMutableArray *resultArray;
    NSMutableArray *newPersons;
}

@end

@implementation DispatchPersonViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initHeader
{
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.title = @"添加接单技师";
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

- (void)doneAction {
    if (_passPerson) {
        _passPerson(newPersons);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHeader];
    resultArray = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"DispatchPersonTableViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:persionCell];
    if (!_persons) {
        _persons = [[NSMutableArray alloc] init];
    }
    newPersons = [[NSMutableArray alloc] initWithArray:_persons];
    [self repairItemDesc];
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)checkSelectedPerson:(NSDictionary *)info {
    for (int i = 0; i < _persons.count; i++) {
        NSDictionary *dict = _persons[i];
        if ([info[@"FID"] isEqualToString:dict[@"FID"]]) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getSameInfo:(NSDictionary *)info {
    for (int i = 0; i < newPersons.count; i++) {
        NSDictionary *dict = newPersons[i];
        if ([dict[@"FID"] isEqualToString:info[@"FID"]]) {
            return dict;
        }
    }
    return nil;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *info = resultArray[indexPath.row];
    DispatchPersonTableViewCell *dstvc = [tableView dequeueReusableCellWithIdentifier:persionCell];
    dstvc.personL.text = info[@"Name"];
    dstvc.passPerson = ^(BOOL bol) {
        if (bol) {
            [newPersons addObject:info];
        }else {
            NSDictionary *dict = [self getSameInfo:info];
            if (dict) {
                [newPersons removeObject:dict];
            }
        }
    };
    BOOL bol = [self checkSelectedPerson:info];
    dstvc.bol = bol;
    if (bol) {
        [dstvc.clickBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }else {
        [dstvc.clickBtn setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
    }
    return dstvc;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
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
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreId":storeId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,RepairUserList];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            id info = responseObject[@"Result"];
            if ([info isKindOfClass:[NSArray class]]) {
                [resultArray addObjectsFromArray:info];
            }
            [_tableView reloadData];
            NSLog(@"result:   %@",responseObject);
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
    }];
}

@end
