//
//  MessageDetailViewController.m
//  testMessage
//
//  Created by 薛焱 on 16/4/22.
//  Copyright © 2016年 薛焱. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "MessageServicerCell.h"
#import "MessageUserCell.h"
#import "MJRefresh.h"
#import "MessageTableView.h"

@interface MessageDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet MessageTableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *heightArray;

@end

@implementation MessageDetailViewController

//- (void)viewWillAppear:(BOOL)animated{
//    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0] atScrollPosition:(UITableViewScrollPositionBottom) animated:NO];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    _heightArray = [NSMutableArray array];
    NSArray *currentArray = @[@"123", @"shdf", @"skhdi mfg", @"sdaf", @"lshidghasjhyiag", @"osjd", @"123", @"shdf", @"skhdi mfg", @"sdaf", @"lshidgh是对方是打发斯蒂芬噶啥的高撒打发斯蒂芬asjhyiag", @"osjd", @"lsdf"];
    _dataArray = @[currentArray].mutableCopy;
    [_heightArray addObject:[self heightArray:currentArray]];
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSArray *addArray = @[@"skhak阿斯顿发我去玩儿去57j6j6j6j7j7j6UI无人送到干飒飒大发谁打谁发的 dgh", @"khsd", @"sdf", @"你阿萨德解放啦伤筋动骨你阿萨德解放啦伤筋动骨你阿萨德解放啦伤筋动骨你阿萨德解放啦伤筋动骨", @"khsd", @"sdf", @"sdngknaksnda"];
        [_dataArray insertObject:addArray atIndex:0];
        [_heightArray insertObject:[self heightArray:addArray] atIndex:0];
        [_tableView reloadData];
        [_tableView.header endRefreshing];
    }];
    // Do any additional setup after loading the view.
}

- (NSArray *)heightArray:(NSArray *)currentArray{
    NSMutableArray *heArray = [NSMutableArray array];
    for (NSString *str in currentArray) {
        CGRect bounds = [str boundingRectWithSize:CGSizeMake(250, 0) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        NSLog(@"%f", bounds.size.height);
        [heArray addObject:[NSNumber numberWithFloat:bounds.size.height]];
    }
    return heArray;
}
- (IBAction)backItemAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 0) {
        MessageServicerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageServicerCell" forIndexPath:indexPath];
        cell.servicerLab.text = _dataArray[indexPath.section][indexPath.row];
        
        return cell;
    }else{
        MessageUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageUserCell" forIndexPath:indexPath];
        cell.servicerLab.text =  _dataArray[indexPath.section][indexPath.row];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSArray *currentArray = [NSArray arrayWithArray:_dataArray];
        NSArray *addArray = @[@"skhakdgh", @"khsd", @"sdf", @"sdngknaksnda"];
        [_dataArray removeAllObjects];
        _dataArray = [addArray arrayByAddingObjectsFromArray:currentArray].mutableCopy;
        [_tableView reloadData];
       
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:addArray.count inSection:0] atScrollPosition:(UITableViewScrollPositionNone) animated:NO];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_heightArray[indexPath.section][indexPath.row] floatValue] + 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDeledate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)changeFrame:(NSNotification *)sender{
    CGRect rect = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat offsetY = [UIScreen mainScreen].bounds.size.height - rect.origin.y;
    
    [UIView animateWithDuration:[sender.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        self.view.transform=CGAffineTransformMakeTranslation(0, -offsetY);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
