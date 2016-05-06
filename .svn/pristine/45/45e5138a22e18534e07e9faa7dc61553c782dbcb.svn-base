//
//  SocketKit.m
//  StoreReception
//
//  Created by cjm-ios on 15/11/23.
//  Copyright © 2015年 cjm-ios. All rights reserved.
//

#import "SocketKit.h"
#import "NSDictionary+jsonString.h"
#import "ZAActivityBar.h"

@interface SocketKit () {
    AsyncSocket *socket;
    NSData *data;
}

@end

@implementation SocketKit

+ (SocketKit *)shareSocketKitManager {
    static SocketKit *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [[SocketKit alloc] init];
    });
    return instance;
}

- (id)init {
    if (self == [super init]) {
        socket = [[AsyncSocket alloc]initWithDelegate:self];
    }
    return self;
}


- (void)socketWriteData:(NSDictionary *)info {
    [socket disconnect];
    NSDictionary *printInfo = [[NSUserDefaults standardUserDefaults] objectForKey:PRINT_INFO];
    NSString *ipAddress = printInfo[@"IpAddress"];
    NSString *ipPort = printInfo[@"IpPort"];
    if (ipAddress.length > 0 && ipPort.length > 0) {
        if (![socket connectToHost:ipAddress onPort:[ipPort intValue] error:nil]) {
            [ZAActivityBar showErrorWithStatus:@"打印服务无响应"];
            return;
        }
        NSString *str = [NSString stringWithFormat:@"%@\n",[info DataTOjsonString]];
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
}

#pragma mark  - 连接成功回调
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected To %@:%i.", host, port);
    [socket writeData:data withTimeout:10 tag:1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [socket disconnect];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    NSLog(@"Disconnected.");
//    [socket setDelegate:nil];
//    socket = nil;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
    NSLog(@"onSocketWillConnect:");
    return YES;
}

@end
