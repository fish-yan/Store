//
//  LoginViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/27.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "ZAActivityBar.h"
#import "SharedBlueToothManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //        self.automaticallyAdjustsScrollViewInsets = NO;
        //        self.edgesForExtendedLayout = UIEventSubtypeNone;
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.navigationController.navigationBarHidden = YES;
    _loginTextF.delegate = self;
    _pwdTextF.delegate = self;
    [self addTapGesture];
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ACCOUNT];
    _loginTextF.text = account;
//    _loginTextF.text = @"cjmyfadmincsdg002";
//    _pwdTextF.text = @"888888";
//    _loginTextF.text = @"小五";
//    _loginTextF.text = @"xiaowu89";
//    _loginTextF.text = @"mjxh";
//    _pwdTextF.text = @"888888";
}

- (void)viewWillAppear:(BOOL)animated {
    _pwdTextF.text = @"";
    if (CGRectGetHeight(self.view.frame) == 480.f) {
        [self registerForKeyboardNotifications];
    }
}

- (void)addTapGesture {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeybord:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)hideKeybord:(UIGestureRecognizer *)gestureRecognizer {
    [_loginTextF resignFirstResponder];
    [_pwdTextF resignFirstResponder];
}

- (IBAction)loginClick:(id)sender {
    if (_loginTextF.text.length > 0 && _pwdTextF.text.length > 0) {
        [_loginTextF resignFirstResponder];
        [_pwdTextF resignFirstResponder];
        [self loginRequest];
    }else {
        if (_loginTextF.text.length == 0) {
            [ZAActivityBar showErrorWithStatus:@"请输入帐号"];
        }
        if (_pwdTextF.text.length == 0) {
            [ZAActivityBar showErrorWithStatus:@"请输入密码"];
        }
    }
}

#pragma  mark - keyboard

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _viewToTitleConstraint.constant = -45;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    _viewToTitleConstraint.constant = 0;
    [UIView commitAnimations];
}

#pragma mark - request

-(void)loginRequest
{
    [ZAActivityBar showWithStatus:LOGING_MSG];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_TOKEN"];
    NSDictionary *parameters = @{@"LoginName":_loginTextF.text,@"LoginPwd":_pwdTextF.text,@"LoginLimit":@"AppDG",@"DeviceType":@"IOS"};
    NSMutableDictionary *parmut = [parameters mutableCopy];
    if (token.length > 0) {
        [parmut setObject:token forKey:@"DeviceCode"];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,LOGIN];
    [manager POST:url parameters:parmut success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            [ZAActivityBar dismiss];
            [[NSUserDefaults standardUserDefaults] setObject:[responseObject objectForKey:@"Result"] forKey:USER_INFO];
            [[NSUserDefaults standardUserDefaults] setObject:_loginTextF.text forKey:USER_ACCOUNT];
            [[SharedBlueToothManager sharedBlueToothManager] setLoginInfo:[responseObject objectForKey:@"Result"]];
            MainViewController *mvc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
            [self.navigationController pushViewController:mvc animated:YES];
            [self GetPrintSpots];
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [ZAActivityBar showErrorWithStatus:NETWORK_ERRO];
        NSLog(@"Error: %@", error);
    }];
}

-(void)GetPrintSpots
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//响应
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    NSString *userId = [userInfo objectForKey:@"UserId"];
    NSString *token = [userInfo objectForKey:@"Token"];
    NSString *storeId = [userInfo objectForKey:@"StoreId"];
    NSDictionary *userDict = @{@"UserId":userId,@"Token":token};
    NSDictionary *parameters = @{@"UserToken":userDict,@"StoreID":storeId};
    NSString *url = [NSString stringWithFormat:@"%@%@",URL_HEADER,GetPrintSpotsController];
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 0) {
            id result = responseObject[@"Result"];
            if ([result isKindOfClass:[NSArray class]]) {
                NSArray *array = result;
                if (array.count > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:array[0] forKey:PRINT_INFO];
                }
            }
        }else {
            [ZAActivityBar showErrorWithStatus:[responseObject objectForKey:@"Message"]];
        }
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == _pwdTextF) {
        [self loginClick:nil];
    }
    return YES;
}

#define Move_Height 80
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

@end
