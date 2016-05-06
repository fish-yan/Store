//
//  CheckListViewController.m
//  TestCarCheck
//
//  Created by 薛焱 on 16/3/1.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "CheckListViewController.h"
#import "CheckListCell.h"
#import "CheckListSection.h"
#import "CheckResultViewController.h"
#import "CheckModel.h"
#import "KMCell.h"
#import "LunTaiCell.h"

@interface CheckListViewController ()<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *carNumLab;
@property (weak, nonatomic) IBOutlet UILabel *checkTimeLab;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (nonatomic, strong) NSMutableDictionary *dataDic;
@property (nonatomic, strong) NSMutableDictionary *dataSource;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSMutableDictionary *selectedDict;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSArray *pickArray;
@property (nonatomic, copy) NSString *KMStr;
@property (nonatomic, assign) NSInteger scores;
@property (nonatomic, assign) NSInteger badCount;
@property (nonatomic, strong) NSIndexPath *indexPath;
//@property (nonatomic, assign) BOOL canSelect;
@property (nonatomic, assign) CGFloat offsetY;
@end

@implementation CheckListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.carNumLab.text = [NSString stringWithFormat:@"车牌号码: %@", self.carNum];
    NSString *timeStr = [NSString stringWithFormat:@"检测日期: %@",self.pickupCarTime];
    self.checkTimeLab.text = [timeStr substringToIndex:timeStr.length - 3];
    self.dataDic = [NSMutableDictionary dictionary];
    self.selectedArray = [NSMutableArray array];
    self.sectionArray = [NSMutableArray array];
    self.dataSource = [NSMutableDictionary dictionary];
    self.selectedDict = [NSMutableDictionary dictionary];
    [self readDataSource];
        // Do any additional setup after loading the view.
}

- (void)readDataSource{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"check.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dict in array) {
        NSMutableArray *arr = [NSMutableArray array];
        NSString *key = dict.allKeys[0];
        for (NSDictionary *d in dict[key]) {
            CheckModel *model = [[CheckModel alloc]init];;
            [model setValuesForKeysWithDictionary:d];
            [arr addObject:model];
        }
        [self.sectionArray addObject:key];
        [self.dataSource setObject:arr forKey:key];
        [self.dataDic setObject:[NSArray array] forKey:key];
    }
    self.dataDic[self.sectionArray[0]] = self.dataSource[self.sectionArray[0]];
    self.pickArray = @[@"请选择",@"<5000",@">5000",@">10000",@">20000",@">30000"];
}

- (void)sectionBtnAction:(UIButton *)sender{
    if ([self.dataDic[self.sectionArray[sender.tag]]count] != 0) {
        self.dataDic[self.sectionArray[sender.tag]] = [NSArray array];
        
    }else{
        
        self.dataDic[self.sectionArray[sender.tag]] = self.dataSource[self.sectionArray[sender.tag]];
        
    }
    
    [self.tableView reloadSections:([NSIndexSet indexSetWithIndex:sender.tag]) withRowAnimation:(UITableViewRowAnimationAutomatic)];
    if ([self.dataDic[self.sectionArray[sender.tag]]count] != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sender.tag] atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
    }
    
} 
//cell上选择button
- (void)selectBtnAction:(UIButton *)sender{
    CheckListCell *cell = (CheckListCell *)((UIButton *)sender.superview.superview);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CheckModel *model = self.dataDic[self.sectionArray[indexPath.section]][indexPath.row];
    model.isSelected = !model.isSelected;
    if (model.isSelected) {
        [self.selectedArray addObject:model];
    }else{
        [self.selectedArray removeObject:model];
    }
    [self configureCellWithModel:model button:sender];
}
- (IBAction)pushBtnItemAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:@"CheckResult" sender:nil];
}
- (IBAction)backBtnItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectKM:(UIButton *)sender{
    KMCell *cell = (KMCell *)sender.superview.superview;
    self.indexPath = [self.tableView indexPathForCell:cell];
    
    self.bottomMargin.constant = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.5;
        [self.view layoutIfNeeded];
    }];
}


- (IBAction)commitBtnAction:(UIButton *)sender {
    KMCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    [cell.KMBtn setTitle:self.KMStr forState:(UIControlStateNormal)];
    CheckModel *model = self.dataDic[self.sectionArray[self.indexPath.section]][self.indexPath.row];
    model.allTitle = [NSString stringWithFormat:@"%@ %@KM",model.title, self.KMStr];
    model.KMTitle = self.KMStr;
    model.scores = self.scores;
    model.badCount = self.badCount;
    if (self.KMStr.length != 0) {
        model.isSelected = NO;
//        self.canSelect = YES;
    }else{
        model.isSelected = YES;
//        self.canSelect = NO;
    }
    [self.selectedArray removeObject:model];
    [self selectBtnAction:cell.selectBtn];
//    cell.selectBtn.userInteractionEnabled = self.canSelect;
    [self cancleBtnAction:nil];
}
- (IBAction)cancleBtnAction:(UIButton *)sender {
    self.bottomMargin.constant = -300;
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataDic[self.sectionArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckModel *model = self.dataDic[self.sectionArray[indexPath.section]][indexPath.row];
    if ([model.title containsString:@"可用"]) {
        KMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KMCell" forIndexPath:indexPath];
//        cell.selectBtn.userInteractionEnabled = self.canSelect;
        cell.selectBtn.hidden = YES;
        cell.checkLab.text = model.title;
        [cell.KMBtn setTitle:model.KMTitle forState:(UIControlStateNormal)];
        [cell.KMBtn addTarget:self action:@selector(selectKM:) forControlEvents:(UIControlEventTouchUpInside)];
        [self configureCellWithModel:model button:cell.selectBtn];
        return cell;
    }else if([model.title isEqualToString:@"轮胎年份"]) {
        LunTaiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LunTaiCell" forIndexPath:indexPath];
        cell.selectBtn.hidden = YES;
//        cell.selectBtn.userInteractionEnabled = self.canSelect;
        cell.checkLab.text = model.title;
        cell.yearTF.delegate = self;
//        cell.weekTF.delegate = self;
        [self configureCellWithModel:model button:cell.selectBtn];
        return cell;
    }else{
        CheckListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckListCell" forIndexPath:indexPath];
        model.allTitle = model.title;
        cell.checkLab.text = model.title;
        [self configureCellWithModel:model button:cell.selectBtn];
        return cell;
    }
    
}
- (void)configureCellWithModel:(CheckModel *)model button:(UIButton *)button{
    if (model.isSelected) {
        [button setImage:[UIImage imageNamed:@"checked"] forState:(UIControlStateNormal)];
    }else{
        [button setImage:[UIImage imageNamed:@"uncheck"] forState:(UIControlStateNormal)];
    }
    [button addTarget:self action:@selector(selectBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CheckListSection *sectionView = [[NSBundle mainBundle]loadNibNamed:@"CheckListSection" owner:self options:nil].lastObject;
    sectionView.frame = CGRectMake(0, 0, kScreenWidth, 50);
    sectionView.sectionBtn.tag = section;
    sectionView.sectionLab.text = self.sectionArray[section];
    [sectionView.sectionBtn addTarget:self action:@selector(sectionBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
    return sectionView;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickArray[row];
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (row == 0) {
        self.KMStr = @"";
        self.badCount = 0;
        self.scores = 0;
    }else{
        switch (row) {
            case 1:
                self.scores = -8;
                self.badCount = 6;
                break;
            case 2:
                self.scores = -5;
                self.badCount = 4;
                break;
            case 3:
                self.scores = -2;
                self.badCount = 3;
                break;
            case 4:
                self.scores = -1;
                self.badCount = 2;
                break;
            default:
                self.scores = 0;
                self.badCount = 0;
                break;
        }
       self.KMStr = self.pickArray[row];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self cancleBtnAction:nil];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.offsetY = self.tableView.contentOffset.y;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ChangeOffset:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)ChangeOffset:(NSNotification *)sender{
    CGRect rect = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (rect.origin.y < kScreenHeight - 10) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height - 150, 0);
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - kScreenHeight + 84 + rect.size.height - 150);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - kScreenHeight + 84);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    LunTaiCell *cell = (LunTaiCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CheckModel *model = self.dataDic[self.sectionArray[indexPath.section]][indexPath.row];
    NSInteger year = [cell.yearTF.text integerValue];
    if (year >= 3) {
        model.scores = -5;
        model.isSelected = NO;
        //星级
    }else{
        model.scores = 0;
        model.isSelected = YES;
    }
//    if (cell.yearTF.text.length > 0 && year >= 3) {
//        model.isSelected = NO;
////        self.canSelect = YES;
//    }else {
//        model.isSelected = YES;
////        self.canSelect = NO;
//    }
    model.allTitle = [NSString stringWithFormat:@"%@ %@年",model.title, cell.yearTF.text];
    [self.selectedArray removeObject:model];
    [self selectBtnAction:cell.selectBtn];
//    cell.selectBtn.userInteractionEnabled = self.canSelect;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    CheckResultViewController *checkResultVC = segue.destinationViewController;
    checkResultVC.dataArray = self.selectedArray;
    checkResultVC.carNum = self.carNum;
    checkResultVC.pickupCarTime = self.pickupCarTime;
    checkResultVC.carId = self.carId;
    checkResultVC.isFromeCheckList = YES;
}

@end
