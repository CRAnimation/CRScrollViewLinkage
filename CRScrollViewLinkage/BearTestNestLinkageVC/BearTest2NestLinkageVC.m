//
//  BearTest2NestLinkageVC.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/18.
//

#import "BearTest2NestLinkageVC.h"
#import <Masonry/Masonry.h>
#import "BearChildView.h"
#import "CRLinkageManager.h"
#import "BearTestScrollView.h"
#import "UIScrollView+CRLinkage.h"

@interface BearTest2NestLinkageVC ()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) BearTestScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray <UIScrollView *> *childViewArray;
@property (nonatomic, strong) CRLinkageManager *linkageManager;
@property (nonatomic, strong) UIButton *myBtn;
@property (nonatomic, assign) CGFloat topHeight;

@end

@implementation BearTest2NestLinkageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.topHeight = 300;
    [self createUI];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.width.height.mas_equalTo(50);
    }];
}

- (void)createUI {
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.mainScrollView addSubview:self.myBtn];
    [self.myBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(50);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.mainScrollView.mas_top).offset(150);
    }];

    [self generateChildArray];
}

- (void)generateChildArray {
    CGFloat topHeight = self.topHeight;
    CGFloat newY = topHeight;
    CGFloat childHeight = [BearChildView viewHeight];
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat gapY = 300;
    
    for (int i = 0; i < 1; i++) {
        BearChildView *childView = [self generateChildView];
        [self.childViewArray addObject:childView.myTableView];
        [self.mainScrollView addSubview:childView];
        [childView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.mainScrollView.mas_top).offset(newY);
            make.height.mas_equalTo(childHeight);
            make.width.mas_equalTo(screenWidth);
        }];
        
        newY += childHeight + gapY;
    }
    
    self.mainScrollView.contentSize = CGSizeMake(screenWidth, newY);
    [self.linkageManager configChildScrollViews:self.childViewArray];
    [self.linkageManager configMainScrollView:self.mainScrollView];
    [self.linkageManager activeCurrentChildScrollView:self.childViewArray[0]];
}

- (BearChildView *)generateChildView {
    BearChildView *childView = [BearChildView new];
    CRLinkageChildConfig *childConfig = childView.myTableView.linkageChildConfig;
    childConfig.childHoldPosition = CRChildHoldPosition_CustomRatio;
    childConfig.positionRatio = 0.5;
    childConfig.headerBounceType = CRBounceType_Child;
    childConfig.headerBounceLimit = @(100);
    childConfig.footerBounceType = CRBounceType_Child;
    childConfig.footerBounceLimit = @(100);
    return childView;
}

#pragma mark - Setter & Getter
- (UIButton *)myBtn {
    if (!_myBtn) {
        _myBtn = [UIButton new];
        _myBtn.backgroundColor = [UIColor whiteColor];
        [_myBtn setTitle:@"change height" forState:UIControlStateNormal];
    }
    
    return _myBtn;
}

- (BearTestScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [BearTestScrollView new];
        _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _mainScrollView.backgroundColor = [UIColor orangeColor];
    }
    
    return _mainScrollView;
}

- (CRLinkageManager *)linkageManager {
    if (!_linkageManager) {
        _linkageManager = [CRLinkageManager new];
    }
    
    return _linkageManager;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        _backBtn.backgroundColor = [UIColor greenColor];
        [_backBtn addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backBtn;
}

- (void)backEvent {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray <UIScrollView *> *)childViewArray {
    if (!_childViewArray) {
        _childViewArray = [NSMutableArray new];
    }
    
    return _childViewArray;
}

@end
