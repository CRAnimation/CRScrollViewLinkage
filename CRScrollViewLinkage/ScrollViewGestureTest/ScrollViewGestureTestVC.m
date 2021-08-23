//
//  ScrollViewGestureTestVC.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/23.
//

#import "ScrollViewGestureTestVC.h"
#import "BearChildView.h"
#import "BearTestScrollView.h"
#import <Masonry/Masonry.h>

@interface ScrollViewGestureTestVC ()

@property (nonatomic, strong) BearTestScrollView *mainScrollView;
@property (nonatomic, strong) BearChildView *childView;
@property (nonatomic, strong) UIButton *myBtn;
@property (nonatomic, assign) CGFloat topHeight;

@end

@implementation ScrollViewGestureTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topHeight = 310;
    [self createUI];
    [self test];
}

- (void)createUI {
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat topHeight = self.topHeight;
    CGFloat contentHeight = topHeight + [BearChildView viewHeight];
    
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
@end
