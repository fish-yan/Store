//
//  InputMsgViewController.h
//  StoreReception
//
//  Created by cjm-ios on 15/8/11.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputMsgViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextFieldDelegate> {
@private
        NSString *brandName;
        NSString *serineName;
        NSString *serineId;
        NSString *carName;
        NSString *carId;
        NSString *brandId;
        NSInteger brandRow;
        NSInteger serineRow;
        NSInteger carRow;
        NSInteger currentTag;
        NSInteger carTypeRow;
        NSInteger memberRow;
        NSInteger memberMethodRow;
        NSInteger certificateTypeRow;
        NSInteger blowRow;
    
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSDictionary *info;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic,retain) UIToolbar * accessoryView;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) NSArray *pickerData;
@property (copy, nonatomic) void(^refresh)();
@property (assign, nonatomic) BOOL isAddNew;
@end
