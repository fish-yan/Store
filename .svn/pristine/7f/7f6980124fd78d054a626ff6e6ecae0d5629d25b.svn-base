//
//  SharedBlueToothManager.m
//  Print
//
//  Created by 张旭 on 1/26/16.
//  Copyright © 2016 Cjm. All rights reserved.
//

#import "SharedBlueToothManager.h"

@interface SharedBlueToothManager ()<UartDelegate>
@property (strong, nonatomic) UartLib *uartLib;
@property (assign, nonatomic) BOOL isPrinterConnected;
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) NSString *savedPeripheralIdentifier;
@property (assign, nonatomic) NSInteger printType;  //0.洗车单 1.精品单 2.服务单
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *printer;
@property (strong, nonatomic) NSDictionary *printContent;

@end

@implementation SharedBlueToothManager

static SharedBlueToothManager *instance = nil;

- (instancetype)init {
    self = [super init];
    self.isBluetoothOpened = NO;
    self.isPrinterConnected = NO;
    self.selectedPeripheral = nil;
    self.printType = 0;
    self.uartLib = [[UartLib alloc] init];
    self.uartLib.uartDelegate = self;
    self.savedPeripheralIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultPrint"];
    [self.uartLib scanStart];
    return self;
}

- (void)setLoginInfo:(NSDictionary *)dict {
    self.companyName = [dict objectForKey:@"CompanyName"];
    self.printer = [dict objectForKey:@"UserName"];
}

+ (instancetype)sharedBlueToothManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setActivePeripherals:(NSInteger)index {
    [self.uartLib scanStop];
    self.selectedPeripheral = [self.foundPeripherals objectAtIndex:index];
    //[self.uartLib connectPeripheral:self.selectedPeripheral];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedPeripheral.identifier.UUIDString forKey:@"DefaultPrint"];
    self.savedPeripheralIdentifier = self.selectedPeripheral.identifier.UUIDString;
}

- (void)disconnectPeripheral {
    if (self.isPrinterConnected) {
        [self.uartLib disconnectPeripheral:self.selectedPeripheral];
    }
}

- (void)clearPrinterConfig {
    self.savedPeripheralIdentifier = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"DefaultPrint"];
    if (self.isPrinterConnected) {
        [self.uartLib disconnectPeripheral:self.selectedPeripheral];
    }
    self.selectedPeripheral = nil;
}

- (void)disconnectPrinter {
    [self.uartLib disconnectPeripheral:self.selectedPeripheral];
}

- (NSDictionary *)printWashNotesWithInfoDicts:(NSDictionary *)dict {
    self.printContent = dict;
    if (self.selectedPeripheral == nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"Code", @"请先选择打印机", @"Message", nil];
    }
//    else if (self.isPrinterConnected == NO) {
//        return [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"Code", @"打印机连接失败", @"Message", nil];
//    }
    
    [self.uartLib connectPeripheral:self.selectedPeripheral];
    //开始连接打印机
    if (_startConnect) {
        _startConnect();
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"Code", @"发送成功!", @"Message", nil];
}

- (NSDictionary *)printSaleProductNotesWithInfoDicts:(NSDictionary *)dict {
    self.printType = 1;
    NSDictionary *result = [self printWashNotesWithInfoDicts:dict];
    return result;
}

- (NSDictionary *)printServiceNotesWithInfoDicts:(NSDictionary *)dict {
    self.printType = 2;
    self.printContent = dict;
    if (self.selectedPeripheral == nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"Code", @"请先选择打印机", @"Message", nil];
    }
//    else if (self.isPrinterConnected == NO) {
//        return [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"Code", @"打印机连接失败", @"Message", nil];
//    }
    
    [self.uartLib connectPeripheral:self.selectedPeripheral];
    
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"Code", @"发送成功!", @"Message", nil];
}

- (void)printWashNotes {
    NSDictionary *dict = self.printContent;
    NSString *companyName = self.companyName;
    NSString *storeName = [dict objectForKey:@"StoreName"];
    NSString *customName = [dict objectForKey:@"CustomName"];
    NSString *settleNumber = [dict objectForKey:@"SettleNumber"];
    NSString *settleTime = [dict objectForKey:@"SettleTime"];
    NSString *orderName = [dict objectForKey:@"OrderName"];
    NSArray *items = [dict objectForKey:@"Items"];
    NSString *taxTotalFee  = [dict objectForKey:@"TaxTotalFee"];
    NSString *change = [dict objectForKey:@"Change"];
    NSString *count = [dict objectForKey:@"Count"];
    NSString *totalFee = [dict objectForKey:@"TotalFee"];
    NSString *servicer = [dict objectForKey:@"Servicer"];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"y-MM-dd"];
    NSString *printTime = [formatter stringFromDate:date];
    NSString *settleType = [dict objectForKey:@"SettleType"];
    NSString *paymentType = [dict objectForKey:@"PaymentType"];
    
    NSMutableData *dataBundle = [NSMutableData data];
    
    Byte caprintFmt[50];
    caprintFmt[0] = 0x1b;
    caprintFmt[1] = 0x40;
    
    caprintFmt[2] = 0x1b;
    caprintFmt[3] = 0x21;
    caprintFmt[4] = 0x08;
    
    NSData *data = [[NSData alloc] initWithBytes:caprintFmt length:5];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //公司名
    NSString *printContent = [NSString stringWithFormat:@"%@\r\n", companyName];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < 31; ++i) {
        caprintFmt[i+2] = '*';
    }
    caprintFmt[33] = 0x0d;
    caprintFmt[34] = 0x0a;
    data = [[NSData alloc] initWithBytes:caprintFmt length:35];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //门店名
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"门店：", storeName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //客户名+车牌号
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"客户：", customName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //单号
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"单号：", settleNumber];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //时间
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"时间：", settleTime];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //业务类型
    printContent = [NSString stringWithFormat:@"%@%@\r\r\n", @"业务类型：", orderName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    
    //    caprintFmt[0] = 0x09;
    //    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    //    [self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"名称"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    caprintFmt[1] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:2];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"数量"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\n", @"金额"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < items.count; ++i) {
        NSString *serviceName = [[items objectAtIndex:i] objectForKey:@"Name"];
        NSString *serviceCount = [[items objectAtIndex:i] objectForKey:@"Amount"];
        NSString *servicePrice = [[items objectAtIndex:i] objectForKey:@"SettleFee"];
        
        //        caprintFmt[0] = 0x09;
        //        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        //        [self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@\r\n", serviceName];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        caprintFmt[1] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:2];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@", serviceCount];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        if (i == items.count-1) {
            printContent = [NSString stringWithFormat:@"%@\r\r\n", servicePrice];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        } else {
            printContent = [NSString stringWithFormat:@"%@\r\n", servicePrice];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        }
    }
    if (self.printType == 0) {
//        printContent = [NSString stringWithFormat:@"%@%@", @"次数：", count];
//        data = [printContent dataUsingEncoding:enc];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
//        
//        caprintFmt[0] = 0x09;
//        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
//        
//        printContent = [NSString stringWithFormat:@"%@%@\r\n", @"实收：", totalFee];
//        self.lineCount += 1;
//        data = [printContent dataUsingEncoding:enc];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    } else if (self.printType == 1) {
//        printContent = [NSString stringWithFormat:@"%@%@", @"总计：", totalFee];
//        data = [printContent dataUsingEncoding:enc];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
//        
//        caprintFmt[0] = 0x09;
//        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
//        
//        printContent = [NSString stringWithFormat:@"%@%@\r\n", @"实收：", taxTotalFee];
//        self.lineCount += 1;
//        data = [printContent dataUsingEncoding:enc];
//        [dataBundle appendData:data];
//        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@%@", @"件数：", count];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@%@\r\n", @"总计：", totalFee];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    }
    
    
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"为您服务的导购员是", servicer];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"打印时间：", printTime];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
//    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"结算类型：", settleType];
//    self.lineCount += 1;
//    data = [printContent dataUsingEncoding:enc];
//    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
//    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"支付方式：", paymentType];
//    self.lineCount += 1;
//    data = [printContent dataUsingEncoding:enc];
//    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < 31; ++i) {
        caprintFmt[i] = '*';
    }
    caprintFmt[31] = 0x0d;
    caprintFmt[32] = 0x0a;
    data = [[NSData alloc] initWithBytes:caprintFmt length:33];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\r\r\n", @"请妥善保管好购物凭证 谢谢惠顾"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    [self.uartLib sendValue:self.selectedPeripheral sendData:dataBundle type:CBCharacteristicWriteWithResponse];
    self.printType = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isPrinterConnected) {
            [self.uartLib disconnectPeripheral:self.selectedPeripheral];
        }
    });
}

- (void)printServiceNotes {
    
    NSDictionary *dict = self.printContent;
    
    NSString *companyName = self.companyName;
    NSString *storeName = [dict objectForKey:@"StoreName"];
    NSString *customName = [dict objectForKey:@"CustomName"];
    NSString *settleNumber = [dict objectForKey:@"SettleNumber"];
    NSString *settleTime = [dict objectForKey:@"SettleTime"];
    NSString *serviceType = [dict objectForKey:@"ServiceType"];
    NSString *mobile = [dict objectForKey:@"Mobile"];
    NSString *entranceTime = [dict objectForKey:@"EntranceTime"];
    NSString *deliverTime = [dict objectForKey:@"DeliverTime"];
    NSString *roadHaul = [dict objectForKey:@"RoadHaul"];
    NSString *serviceConsultant = [dict objectForKey:@"ServiceConsultant"];
    NSString *settleType = [dict objectForKey:@"SettleType"];
    NSString *remark = [dict objectForKey:@"Remark"];
    NSArray *feeList = [dict objectForKey:@"FeeList"];
    NSArray *goods = [dict objectForKey:@"Goods"];
    NSArray *projects = [dict objectForKey:@"Projects"];
    NSString *orderName = [dict objectForKey:@"OrderName"];
    NSString *printer = self.printer;
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *printTime = [formatter stringFromDate:date];
    NSString *paymentType = [dict objectForKey:@"PaymentType"];
    NSArray *ets = [entranceTime componentsSeparatedByString:@"T"];
    NSArray *dts = [deliverTime componentsSeparatedByString:@"T"];
    NSString *_et = ets[0];
    NSString *_dt = dts[0];
    NSMutableData *dataBundle = [NSMutableData data];
    
    Byte caprintFmt[50];
    caprintFmt[0] = 0x1b;
    caprintFmt[1] = 0x40;
    
    caprintFmt[2] = 0x1b;
    caprintFmt[3] = 0x21;
    caprintFmt[4] = 0x08;
    
    NSData *data = [[NSData alloc] initWithBytes:caprintFmt length:5];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //公司名
    NSString *printContent = [NSString stringWithFormat:@"%@\r\n", companyName];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < 31; ++i) {
        caprintFmt[i+2] = '*';
    }
    caprintFmt[33] = 0x0d;
    caprintFmt[34] = 0x0a;
    data = [[NSData alloc] initWithBytes:caprintFmt length:35];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //门店名
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"门店：", storeName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //客户名+车牌号
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"客户：", customName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //单号
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"单号：", settleNumber];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //时间
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"时间：", settleTime];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //服务类别
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"服务类型：", serviceType];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //联系电话
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"联系电话：", mobile];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //进场日期
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"进场日期：", _et];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //出厂日期
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"出厂日期：", _dt];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //进厂里程
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"进厂里程：", roadHaul];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //服务顾问
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"服务顾问：", serviceConsultant];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //结算类型
//    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"结算类型：", settleType];
//    self.lineCount += 1;
//    data = [printContent dataUsingEncoding:enc];
//    [dataBundle appendData:data];
//    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //业务备注
    printContent = [NSString stringWithFormat:@"%@%@\r\r\n", @"业务备注：", remark];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //费用结算表
    printContent = [NSString stringWithFormat:@"%@\r\n", @"费用结算表（工时费+配件费）"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    //    caprintFmt[0] = 0x09;
    //    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    //    [self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"序号"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"名称"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\n", @"金额"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < feeList.count; ++i) {
        NSString *number = [NSString stringWithFormat:@"%ld", (long)i+1];
        NSString *name = [[feeList objectAtIndex:i] objectForKey:@"Name"];
        NSString *settleFee = [[feeList objectAtIndex:i] objectForKey:@"SettleFee"];
        
        printContent = [NSString stringWithFormat:@"%@", number];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@", name];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        if (i == feeList.count-1) {
            printContent = [NSString stringWithFormat:@"%@\r\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        } else {
            printContent = [NSString stringWithFormat:@"%@\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        }
    }
    //工时费
    printContent = [NSString stringWithFormat:@"%@\r\n", @"工时费"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"名称"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    caprintFmt[1] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:2];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"工时"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\n", @"金额"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    
    for (NSInteger i = 0; i < projects.count; ++i) {
        NSString *name = [[projects objectAtIndex:i] objectForKey:@"Name"];
        NSString *workTime = [[projects objectAtIndex:i] objectForKey:@"WorkTime"];
        NSString *settleFee = [[projects objectAtIndex:i] objectForKey:@"SettleFee"];
        
        printContent = [NSString stringWithFormat:@"%@\r\n", name];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        caprintFmt[1] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:2];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@", workTime];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        if (i == projects.count-1) {
            printContent = [NSString stringWithFormat:@"%@\r\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        } else {
            printContent = [NSString stringWithFormat:@"%@\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        }
    }
    //配件费
    printContent = [NSString stringWithFormat:@"%@\r\n", @"配件费"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"名称"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    caprintFmt[1] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:2];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@", @"数量"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    caprintFmt[0] = 0x09;
    data = [[NSData alloc] initWithBytes:caprintFmt length:1];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\n", @"金额"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < goods.count; ++i) {
        NSString *name = [[goods objectAtIndex:i] objectForKey:@"Name"];
        NSString *amount = [[goods objectAtIndex:i] objectForKey:@"Amount"];
        NSString *settleFee = [[goods objectAtIndex:i] objectForKey:@"SettleFee"];
        
        printContent = [NSString stringWithFormat:@"%@\r\n", name];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        caprintFmt[1] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:2];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        printContent = [NSString stringWithFormat:@"%@", amount];
        data = [printContent dataUsingEncoding:enc];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        caprintFmt[0] = 0x09;
        data = [[NSData alloc] initWithBytes:caprintFmt length:1];
        [dataBundle appendData:data];
        //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        
        if (i == goods.count-1) {
            printContent = [NSString stringWithFormat:@"%@\r\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        } else {
            printContent = [NSString stringWithFormat:@"%@\r\n", settleFee];
            data = [printContent dataUsingEncoding:enc];
            [dataBundle appendData:data];
            //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
        }
    }
    //业务类型
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"业务类型：", orderName];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //打印人员
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"打印人员：", printer];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //打印时间
    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"打印时间：", printTime];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    //支付方式
//    printContent = [NSString stringWithFormat:@"%@%@\r\n", @"支付方式：", paymentType];
//    self.lineCount += 1;
//    data = [printContent dataUsingEncoding:enc];
//    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    for (NSInteger i = 0; i < 31; ++i) {
        caprintFmt[i] = '*';
    }
    caprintFmt[31] = 0x0d;
    caprintFmt[32] = 0x0a;
    data = [[NSData alloc] initWithBytes:caprintFmt length:33];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    
    printContent = [NSString stringWithFormat:@"%@\r\r\r\n", @"请妥善保管好购物凭证 谢谢惠顾"];
    data = [printContent dataUsingEncoding:enc];
    [dataBundle appendData:data];
    //[self.uartLib sendValue:self.selectedPeripheral sendData:data type:CBCharacteristicWriteWithResponse];
    [self.uartLib sendValue:self.selectedPeripheral sendData:dataBundle type:CBCharacteristicWriteWithResponse];
    self.printType = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isPrinterConnected) {
            [self.uartLib disconnectPeripheral:self.selectedPeripheral];
        }
    });
}


#pragma mark - UartDelegate

- (void) didScanedPeripherals:(NSMutableArray  *)foundPeripherals;
{
    NSLog(@"didScanedPeripherals(%lu)", (unsigned long)[foundPeripherals count]);
    
    self.foundPeripherals = foundPeripherals;
    for (CBPeripheral *peripheral in self.foundPeripherals) {
        NSLog(@"--Peripheral:%@", [peripheral name]);
        if ([peripheral.identifier.UUIDString isEqualToString:self.savedPeripheralIdentifier]) {
            [self.uartLib scanStop];
            self.selectedPeripheral = peripheral;
            //[self.uartLib connectPeripheral:self.selectedPeripheral];
            return;
        }
    }
}

- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did Connect Peripheral");
    self.isPrinterConnected = YES;
    if (_didConnect) {
        _didConnect();
    }
    if (self.printType == 0 || self.printType == 1) {
        [self printWashNotes];
    } else if (self.printType == 2) {
        [self printServiceNotes];
    }
}

- (void) didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"did Disconnect Peripheral");
    self.isPrinterConnected = NO;
    [self.uartLib scanStart];
}

- (void) didWriteData:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didWriteData:%@", [peripheral name]);
}

- (void) didReceiveData:(CBPeripheral *)peripheral recvData:(NSData *)recvData
{
    NSLog(@"uart recv(%lu):%@", (unsigned long)[recvData length], recvData);
    [self promptDisplay:recvData];
}

- (void) didBluetoothPoweredOff{
    
}
- (void) didBluetoothPoweredOn{
    
}

- (void) didRetrievePeripheral:(NSArray *)peripherals{
    
}

- (void) didRecvRSSI:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}
- (void) didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}

- (void) didDiscoverPeripheralAndName:(CBPeripheral *)peripheral DevName:(NSString *)devName{
    
}

- (void) didrecvCustom:(CBPeripheral *)peripheral CustomerRight:(bool) bRight{
    
}

- (void) promptDisplay:(NSData *)recvData{
    NSString *prompt;
    
    NSString *hexStr=@"";
    
    hexStr = [[NSString alloc] initWithData:recvData encoding:NSASCIIStringEncoding];
    if (hexStr) {
        prompt = [[NSString alloc]initWithFormat:@"R:%@\r\n", hexStr];
    }
    NSLog(@"%@", prompt);
}

@end
