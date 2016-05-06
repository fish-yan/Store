//
//  BillingUserView.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/24.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "BillingUserView.h"
#import "TSLocateView.h"
#import "ZAActivityBar.h"
#import <AFNetworking/AFNetworking.h>
#import "ToolKit.h"

@interface BillingUserView () {
    TSLocateView *linceView;
    NSInteger linceRow;
    NSInteger subLinceRow;
    NSDictionary *licensePlateDict;
    NSMutableArray *carArray;
    NSDictionary *userInfo;
}

@end

@implementation BillingUserView

- (void)awakeFromNib {
    _stTextField.delegate = self;
    _licenNumTextField.delegate = self;
    _telNumberTextField.delegate = self;
    _telPersonTextField.delegate = self;
    [_licenNumTextField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSDictionary *storeConfig = userInfo[@"StoreConfig"];
    NSString *carProvince = storeConfig[@"CarProvince"];
    NSString *carRegion = storeConfig[@"CarRegion"];
    if (storeConfig) {
        if (![storeConfig isKindOfClass:[NSNull class]]) {
            _stTextField.text = [NSString stringWithFormat:@"%@%@",carProvince,carRegion];
        }
    }
    UIImageView *sjImgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_stTextField.frame)-9, CGRectGetHeight(_stTextField.frame)-9, 9, 9)];
    sjImgV.image = [UIImage imageNamed:@"三角"];
    [_stTextField addSubview:sjImgV];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"LicensePlate" ofType:@"plist"];
    licensePlateDict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    linceView = [[TSLocateView alloc] initWithTitle:@"选择车牌" delegate:self];
    linceView.passAllValue = ^(NSInteger row,NSInteger subRow) {
        linceRow = row;
        subLinceRow = subRow;
    };
    [linceView initData:licensePlateDict];
    _stTextField.inputView = linceView;
    carArray = [[NSMutableArray alloc] init];
    _linceView.layer.borderWidth = 0.5;
    _linceView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    _linceView.layer.cornerRadius = 6;
    _constraintHeight.constant = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self creatToolBar];
}

- (void)textFieldEditChanged:(UITextField *)textField
{
    if (textField.markedTextRange == nil) {
        NSLog(@"text:  %@",textField.text);
        [self getCarInfo:textField.text.uppercaseString];
    }
}

- (void)reset {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)hiddenKeybord {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintHeight.constant = 0;
        [_linceView layoutIfNeeded];
    }];
    if (_endBegin) {
        _endBegin();
    }
}

- (void)showKeybord {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintHeight.constant = 90;
        [_linceView layoutIfNeeded];
    }];
    if (_editBegin) {
        _editBegin();
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField != _licenNumTextField) {
        [self hiddenKeybord];
    }
    return  YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _telNumberTextField) {
        if (string.length == 0) return YES;
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 11) {
            return NO;
        }
    }
    return YES;
}

- (IBAction) searchClick {
    _editLicen();
}

- (void)creatToolBar {
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    UIButton* cancelDone = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelDone.frame = CGRectMake(10, 5, 60, 20);
    [cancelDone setBackgroundColor:[UIColor clearColor]];
    [cancelDone setTitle:@"取消" forState:UIControlStateNormal];
    cancelDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:cancelDone];
    UIButton* btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(topView.frame.size.width-70, 5, 60, 20);
    [btnDone setBackgroundColor:[UIColor clearColor]];
    [btnDone setTitle:@"确定" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topView addSubview:btnDone];
    [btnDone addTarget:self action:@selector(OnTapDone:) forControlEvents:UIControlEventTouchUpInside];
    [cancelDone addTarget:self action:@selector(OnTapCancel:) forControlEvents:UIControlEventTouchUpInside];
    _stTextField.inputAccessoryView = topView;
}

- (void)OnTapCancel:(id) sender{
    [_stTextField resignFirstResponder];
}

-(void)OnTapDone:(id) sender{
    NSArray *array = licensePlateDict.allKeys;
    NSString *key = array[linceRow];
    NSArray *subArray = licensePlateDict[key];
    NSString *subValue = @"";
    if (subArray.count != 0) {
        subValue = subArray[subLinceRow];
    }
    _stTextField.text = [NSString stringWithFormat:@"%@%@",key,subValue];
    [_stTextField resignFirstResponder];
}

- (void)hidden {
    [self.telNumberTextField resignFirstResponder];
}

- (void)getCarInfo:(NSString *)linceStr {
    if (linceStr.length > 0) {
        [ZAActivityBar showWithStatus:LODING_MSG];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
        manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
        NSString *userId = userInfo[@"UserId"];
        NSString *token = userInfo[@"Token"];
        NSString *companyId = userInfo[@"CompanyId"];
        NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
        NSDictionary *parameters = @{@"UserToken":userDict,@"CompanyId":companyId,@"Key":linceStr,@"PageIndex":@"0",@"PageSize":@"50"};
        NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetCar];
        NSLog(@"aa:   %@",linceStr);
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            int code = [responseObject[@"Code"] intValue];
            if (code == 0) {
                [ZAActivityBar dismiss];
                [carArray removeAllObjects];
                [carArray addObjectsFromArray:responseObject[@"Result"][@"Cars"]];
                if (carArray.count > 0) {
                    [self showKeybord];
                }else {
                    [self hiddenKeybord];
                }
                [_tableView reloadData];
                NSLog(@"JSON: %@", responseObject);
            }else {
                NSLog(@"msg:  %@",responseObject[@"Message"]);
                [ZAActivityBar showErrorWithStatus:responseObject[@"Message"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        }];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return carArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *itemCell = @"itemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (carArray.count > 0 && carArray.count > indexPath.row) {
        NSDictionary *dict = carArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",dict[@"CarNumber"],dict[@"MemberName"]];
        cell.textLabel.textColor = UIColorFromRGB(0x5D5D5D);
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 43, CGRectGetWidth(cell.frame), 1)];
        lineV.backgroundColor = UIColorFromRGB(0xD9D9D9);
        [cell.contentView addSubview:lineV];
        __weak __typeof(UITableViewCell *)weakCell = cell;
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakCell).with.insets(UIEdgeInsetsMake(43, 0, 0, 0));
        }];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _info = [carArray[indexPath.row] copy];
    _telNumberTextField.text = _info[@"TelNumber"];
    _telPersonTextField.text = _info[@"MemberName"];
    if (_passValue) {
        _passValue(_info);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end
