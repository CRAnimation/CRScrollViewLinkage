//
//  BearTestNestLinkageVC.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/23.
//

#import "BearTestNestLinkageVC.h"
#import <Masonry/Masonry.h>
#import "BearChildView.h"
#import "CRLinkageManagerInternal.h"
#import "BearTestScrollView.h"

@interface BearTestNestLinkageVC () <CRLinkageManagerInternalDelegate>

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) BearTestScrollView *mainScrollView;
@property (nonatomic, strong) BearChildView *childView;
@property (nonatomic, strong) CRLinkageManagerInternal *linkageManagerInternal;
@property (nonatomic, strong) UIButton *myBtn;
@property (nonatomic, assign) CGFloat topHeight;

@end

@implementation BearTestNestLinkageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.topHeight = 300;
    [self createUI];
    [self test];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
//        make.leading.trailing.inset(20);
        make.width.height.mas_equalTo(50);
    }];
}

- (void)createUI {
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat topHeight = self.topHeight;
    CGFloat contentHeight = topHeight + [BearChildView viewHeight] + 500;
    
    self.mainScrollView = [BearTestScrollView new];
    self.mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.mainScrollView.backgroundColor = [UIColor orangeColor];
    self.mainScrollView.contentSize = CGSizeMake(screenWidth, contentHeight);
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
    
    self.childView = [BearChildView new];
    [self.mainScrollView addSubview:self.childView];
    [self.childView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.mainScrollView.mas_top).offset(topHeight);
        make.height.mas_equalTo([BearChildView viewHeight]);
        make.width.mas_equalTo(screenWidth);
    }];
    
    [self.linkageManagerInternal configMainScrollView:self.mainScrollView];
    CRLinkageChildConfig *childConfig = self.childView.myTableView.linkageChildConfig;
//    childConfig.childHoldPosition = CRChildHoldPosition_Top;
    //    childConfig.childTopFixHeight = 50;
//    childConfig.childHoldPosition = CRChildHoldPosition_Center;
//    childConfig.childHoldPosition = CRChildHoldPosition_Bottom;
    childConfig.childHoldPosition = CRChildHoldPosition_CustomRatio;
    childConfig.positionRatio = 0.5;
    childConfig.headerBounceType = CRBounceType_Child;
    childConfig.headerBounceLimit = @(100);
    childConfig.footerBounceType = CRBounceType_Child;
    childConfig.footerBounceLimit = @(100);
//    CRChildHoldPosition position = self.childView.myTableView.linkageChildConfig.childHoldPosition;
    [self.linkageManagerInternal configChildScrollView:self.childView.myTableView];
    
    self.linkageManagerInternal.internalActive = YES;
}

- (void)test {
    NSString *aaa = @"+86";
    NSNumber *num = [NSNumber numberWithInt:aaa.intValue];
    NSLog(@"num:%@", num);
}

- (void)changeTopHeightEvent {
    NSLog(@"--1");
    
    self.topHeight += 50;
    [self.childView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainScrollView.mas_top).offset(self.topHeight);
    }];
    
}

#pragma mark - Setter & Getter
- (UIButton *)myBtn {
    if (!_myBtn) {
        _myBtn = [UIButton new];
        _myBtn.backgroundColor = [UIColor whiteColor];
        [_myBtn addTarget:self action:@selector(changeTopHeightEvent) forControlEvents:UIControlEventTouchUpInside];
        [_myBtn setTitle:@"change height" forState:UIControlStateNormal];
    }
    
    return _myBtn;
}

- (CRLinkageManagerInternal *)linkageManagerInternal {
    if (!_linkageManagerInternal) {
        _linkageManagerInternal = [CRLinkageManagerInternal new];
        _linkageManagerInternal.delegate = self;
    }
    
    return _linkageManagerInternal;
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

#pragma mark - CRLinkageManagerInternalDelegate
- (void)scrollViewTriggerLimitWithScrollView:(UIScrollView *)scrollView scrollViewType:(CRScrollViewType)scrollViewType bouncePostionType:(CRBouncePostionType)bouncePostionType {
    self.linkageManagerInternal.internalActive = NO;
    NSLog(@"--1 scrollViewType:%lu, bouncePostionType:%lu", (unsigned long)scrollViewType, (unsigned long)bouncePostionType);
}

@end
