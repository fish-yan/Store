//
//  SharedBlueToothManager.h
//  Print
//
//  Created by 张旭 on 1/26/16.
//  Copyright © 2016 Cjm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UartLib.h"

@interface SharedBlueToothManager : NSObject

@property (assign, nonatomic) BOOL isBluetoothOpened;
@property (strong, nonatomic) NSArray *foundPeripherals;
@property (copy, nonatomic) void (^didConnect)(void);
@property (copy, nonatomic) void (^startConnect)(void);


+ (instancetype)sharedBlueToothManager;

- (NSDictionary *)printWashNotesWithInfoDicts:(NSDictionary *)dict;             //打印洗车单             //返回值：0.成功  1.未选择打印机 2.连接打印机失败
- (NSDictionary *)printSaleProductNotesWithInfoDicts:(NSDictionary *)dict;      //打印汽车精品单
- (NSDictionary *)printServiceNotesWithInfoDicts:(NSDictionary *)dict;          //打印项目结算单

- (void)setLoginInfo:(NSDictionary *)dict;
- (void)setActivePeripherals:(NSInteger)index;  //选择打印机
- (void)clearPrinterConfig;                     //清除默认打印机
- (void)disconnectPrinter;

@end
