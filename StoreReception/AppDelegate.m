//
//  AppDelegate.m
//  StoreReception
//
//  Created by cjm-ios on 15/5/19.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreBluetooth/CBCentralManager.h>

@interface AppDelegate () {
    id contents;
}

@end

@implementation AppDelegate

- (void)checkVersion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    NSDictionary *parameters = @{@"ds_id":Check_Action,@"p1":App_id};
    NSString *url = [NSString stringWithFormat:@"%@%@",UPDATE_HEADER,UpdateVersion];
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        contents = [dic objectForKey:@"contents"];
        if ([contents isKindOfClass:[NSArray class]]) {
            NSDictionary *info = contents[0];
            int versionCode = [info[@"VERCODE"] intValue];
            NSDictionary *appInfo= [[NSBundle mainBundle] infoDictionary];
            int build =[appInfo[@"CFBundleVersion"] intValue]; // Build
            int forceFlag = [info[@"FORCEFLAG"] intValue];
            if (versionCode > build) {
                if (forceFlag > 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前有更新版本，请更新后使用" delegate:self cancelButtonTitle:nil otherButtonTitles:@"更新", nil];
                    alertView.tag = 2;
                    [alertView show];
                }else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前有更新版本，是否更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
                    alertView.tag = 1;
                    [alertView show];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self checkVersion];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        
        [application registerUserNotificationSettings:notiSettings];
        
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    self.blueToothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    [AVOSCloud setApplicationId:@"5re2cbxgwsus5v3czexu725l" clientKey:@"3f3ojnhkzt5y6phmcai2hxs6"];
    LoginViewController *loginV = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // Override point for customization after application launch.
    self.window.backgroundColor = UIColor.whiteColor;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginV];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

#ifdef __IPHONE_8_0
//ios8需要调用内容
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

#endif

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"设备令牌: %@", deviceToken);
    NSString *token = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:KEY_TOKEN];
    AVInstallation *currentInstallation = [AVInstallation
                                           currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    //显示推送消息
    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"经过推送发送过来的消息"
                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:@"处理",nil];
        alert.tag = 99;
        [alert show];
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册推送服务时，发生以下错误： %@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSDictionary *info = contents[0];
            NSString *url = info[@"URL"];
            NSString *_url = [url stringByReplacingOccurrencesOfString:@"http" withString:@"itms"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
        }
    }else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            [self exitApplication];
            NSDictionary *info = contents[0];
            NSString *url = info[@"URL"];
            NSString *_url = [url stringByReplacingOccurrencesOfString:@"http" withString:@"itms"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
//            [self performSelector:@selector(exitApplication) withObject:nil afterDelay:1];
        }
    }
    
}

- (void)exitApplication {
    
    [UIView beginAnimations:@"exitApplication" context:nil];
    
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationDelegate:self];
    
    // [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.view.window cache:NO];
    
    [UIView setAnimationTransition:UIViewAnimationCurveEaseOut forView:self.window cache:NO];
    
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    
    //self.view.window.bounds = CGRectMake(0, 0, 0, 0);
    
    self.window.bounds = CGRectMake(0, 0, 0, 0);
    
    [UIView commitAnimations];
    
}



- (void)animationFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    if ([animationID compare:@"exitApplication"] == 0) {
        exit(0);
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (self.blueToothManager.state == CBCentralManagerStatePoweredOn) {
        [SharedBlueToothManager sharedBlueToothManager].isBluetoothOpened = YES;
    } else {
        [SharedBlueToothManager sharedBlueToothManager].isBluetoothOpened = NO;
        NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
        [[UIApplication sharedApplication] canOpenURL:url];
    }
}

@end
