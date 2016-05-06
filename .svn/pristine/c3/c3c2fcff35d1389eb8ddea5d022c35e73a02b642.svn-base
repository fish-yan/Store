//
//  ShowPhotoViewController.m
//  StoreReception
//
//  Created by cjm-ios on 15/6/10.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "ShowPhotoViewController.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface ShowPhotoViewController () {
    int nowPage;
    UIView *contentV;
    NSMutableArray *imags;
}

@end

@implementation ShowPhotoViewController

- (void)initData {
    imags = [[NSMutableArray alloc] initWithArray:_imageArray];
    nowPage = _index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initData];
    [self initHeader];
    [self initScrollView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)initScrollView {
    _scrollView = UIScrollView.new;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = UIColorFromRGB(0x111111);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    UIEdgeInsets scrollviewPadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(scrollviewPadding);
    }];
    contentV = UIView.new;
    contentV.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.height.equalTo(_scrollView);
//        make.width.equalTo(_scrollView);
    }];
    [self addImageView];
    NSLog(@"aa:   %f",(_index - 1) * CGRectGetWidth(self.view.frame));
    _scrollView.contentOffset = CGPointMake((_index - 1) * CGRectGetWidth(self.view.frame), 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint pt = scrollView.contentOffset;
    //    nowPage = pt.x/scrollView.frame.size.width + 1;
    CGFloat pageWidth = scrollView.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    nowPage = floor((pt.x - pageWidth / 2) / pageWidth) + 1;
    nowPage += 1;
    self.title = [NSString stringWithFormat:@"%d / %ld",nowPage,imags.count];
}

#pragma mark - private

- (void)addImageView {
    UIImageView *lastV = nil;
    for (int i = 0; i < imags.count; i++) {
        UIImage *image = [imags objectAtIndex:i];
        UIImageView *view = UIImageView.new;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view.clipsToBounds = YES;
        view.image = image;
        [contentV addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(contentV.centerY);
            make.width.mas_equalTo(CGRectGetWidth(self.view.frame));
            if (lastV) {
                make.left.equalTo(lastV.right);
            }else {
                make.left.equalTo(contentV.left);
            }
        }];
        
        lastV = view;
    }
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.greaterThanOrEqualTo(lastV.right);
    }];
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame) * imags.count, CGRectGetHeight(self.view.frame))];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

-(void)initHeader
{
    self.title = [NSString stringWithFormat:@"%ld / %ld",_index,imags.count];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x2878d2);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 11, 21)];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(250, 0, 22, 25)];
    [rightBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"删除-普通"] forState:UIControlStateNormal];
    //    [rightBtn setBackgroundImage:[UIImage imageNamed:@"删除-点击"] forState:UIControlStateHighlighted];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)deleteAction {
    if (imags.count == 1) {
        [imags removeAllObjects];
        [self backAction];
    }else {
        [imags removeObjectAtIndex:(nowPage - 1)];
        for (UIView *view in [contentV subviews]) {
            [view removeFromSuperview];
        }
//        --_index;
        [self addImageView];
        [self scrollViewDidEndDecelerating:_scrollView];
//        self.title = [NSString stringWithFormat:@"%d / %ld",nowPage,imags.count];
//        if (_index == 0) {
//            self.title = [NSString stringWithFormat:@"%ld / %ld",++_index,imags.count];
//        }else if (_index == _imageArray.count) {
//            self.title = [NSString stringWithFormat:@"%ld / %ld",_index,imags.count];
//        }else {
//            self.title = [NSString stringWithFormat:@"%ld / %ld",++_index,imags.count];
//        }
    }
}

- (void)backAction {
    _passImageArray(imags);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
