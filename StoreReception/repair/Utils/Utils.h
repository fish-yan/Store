//
//  Utils.h
//  Repair
//
//  Created by Kassol on 15/9/7.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#ifndef Repair_Utils_h
#define Repair_Utils_h

//#define BASEURL     @"http://61.186.130.102:8003/api/"  //测试
#define BASEURL     @"http://61.186.130.102:805/api/"  //正式

#define MAINCOLOR   [UIColor colorWithRed:0 green:0.83 blue:0.62  alpha:1.0f]
#define NORMALCOLOR   [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0  alpha:1.0f]

#define PNCOLOR1    [UIColor colorWithRed:37.0/255.0 green:191.0/255.0 blue:235.0/255.0  alpha:1.0f]
#define PNCOLOR2    [UIColor colorWithRed:45.0/255.0 green:205.0/255.0 blue:135.0/255.0  alpha:1.0f]
#define PNCOLOR3    [UIColor colorWithRed:0.76 green:0.53 blue:0.76  alpha:1.0f]
#define PNCOLOR4    [UIColor colorWithRed:136.0/255.0 green:139.0/255.0 blue:195.0/255.0 alpha:1.0f]
#define REDCOLOR    [UIColor colorWithRed:240.0/255.0 green:84.0/255.0 blue:84.0/255.0 alpha:1.0]

#define PREORDER    @"PreOrder"
#define WAITING     @"Waiting"
#define WORKING     @"Working"
#define FINISH      @"Finish"
#define MYWORKING   @"MyWorking"
#define MYFINISH    @"MyFinish"

#define ERROR_CONNECTION    @"请检查网络连接"
#define ERROR_LOGIN         @"账号或密码错误"
#define ERROR_NONUMBER      @"含非法字符，请输入纯数字！"
#define ERROR_NUMBERLESSTHANZERO     @"输入值需要大于0！"
#define ERROR_TEXTFIELDNONE     @"输入值不能为空"
#define ERROR_NOTDELIEVERED     @"项目需要全部分配才能提交！"
#define ERROR_FINISHPRIROTY     @"您没有完工权限！"
#define ERROR_NOTCONTAINS       @"不能提交未指派给您的任务！"
#define ERROR_STARTDATEERROR    @"请选择开始日期！"
#define ERROR_ENDDATEERROR      @"请选择结束日期！"
#define ERROR_DATEERROR         @"日期选择错误！"
#define ERROR_DATEMISSING       @"请选择日期！"
#define ERROR_WORKTIME          @"分配工时大于项目总工时！"
#define ERROR_WORKTIMEPRICE     @"分配价格大于项目总价格！"

#define DAYFORMATTER   @"%04ld年%02ld月%02ld日"
#define DAYFORMATTERFORPICKER   @"%04ld-%02ld-%02ld"

#endif
