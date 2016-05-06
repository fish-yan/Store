//
//  PickUserView.h
//  StoreReception
//
//  Created by cjm-ios on 15/9/1.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickUserView : UIView <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *licenNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *bxComTextField;//保险公司
@property (weak, nonatomic) IBOutlet UITextField *userTypeTextField;//客户类别
@property (weak, nonatomic) IBOutlet UITextField *serviceTextField;//服务类别
@property (weak, nonatomic) IBOutlet UITextField *bxDateTextField;//保险到期
@property (weak, nonatomic) IBOutlet UITextField *byDateTextField;//保养到期
@property (weak, nonatomic) IBOutlet UITextField *registerDateTextField;//注册时间
@property (weak, nonatomic) IBOutlet UITextField *yearCheckDateTextField;//年检时间
@property (weak, nonatomic) IBOutlet UITextField *inDateTextField;//进厂时间
@property (weak, nonatomic) IBOutlet UITextField *ppTextField;//品牌型号
@property (weak, nonatomic) IBOutlet UITextField *clppTextField;//车辆品牌
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;//vin
@property (weak, nonatomic) IBOutlet UITextField *cxTextField;//车辆车型
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;//客户姓名
@property (weak, nonatomic) IBOutlet UITextField *userTelTextField;//客户联系方式
@property (weak, nonatomic) IBOutlet UITextField *carYearTextField;//车辆年款
@property (weak, nonatomic) IBOutlet UITextField *repairTextField;//送修人员
@property (weak, nonatomic) IBOutlet UITextField *repairTelTextField;//送修电话
@property (weak, nonatomic) IBOutlet UITextField *serviceNameTextField;//服务顾问
@property (weak, nonatomic) IBOutlet UITextField *serivceTelTextField;//服务顾问联系方式
@property (weak, nonatomic) IBOutlet UITextField *outDateTextField;//出厂日期
@property (weak, nonatomic) IBOutlet UITextField *licTextField;//进厂里程
@property (weak, nonatomic) IBOutlet UILabel *byMark;
@property (weak, nonatomic) IBOutlet UILabel *zcMark;
@property (weak, nonatomic) IBOutlet UILabel *njMark;
@property (weak, nonatomic) IBOutlet UILabel *jhjcMark;
@property (weak, nonatomic) IBOutlet UITextField *stTextField;
@property (weak, nonatomic) IBOutlet UITextField *clcxTextField;//车辆车系
@property (weak, nonatomic) IBOutlet UITextField *brandSelectTextField;
@property (weak, nonatomic) IBOutlet UITextField *serialSelectTextField;
@property (weak, nonatomic) IBOutlet UITextField *carNameSelectTextField;

@property (copy, nonatomic) void (^editLicen)(void);
@property (nonatomic, copy) void (^editBegin)(void);
@property (nonatomic, copy) void (^endBegin)(void);
@property (nonatomic, copy) void (^passValue)(NSDictionary *);
@property (nonatomic, retain) NSArray *bxArray;
@property (nonatomic, retain) NSArray *userTypeArray;
@property (nonatomic, retain) NSArray *serviceTypeArray;
@property (nonatomic, retain) NSDictionary *info;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewConstraintHeight;
@property (weak, nonatomic) IBOutlet UIView *lincenView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)hidden;
- (NSMutableDictionary *)getData;
- (void)repairInfobyCarNum;
- (BOOL)checkValidata;
- (void)resetView;
- (void)getCarInfo:(NSString *)linceStr;
- (void)reset;
@end
