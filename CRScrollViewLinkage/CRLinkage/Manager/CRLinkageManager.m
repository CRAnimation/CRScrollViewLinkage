//
//  CRLinkageManager.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageManager.h"
#import "CRLinkageHookInstanceCook.h"
#import "CRLinkageConfig.h"
#import "CRLinkageDefine.h"

static NSString * const kContentOffset = @"contentOffset";
static NSString * const kCenter = @"center";

@interface CRLinkageManager()

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray *childScrollViews;
@property (nonatomic, strong) UIScrollView *currentChildScrollView;
@property (nonatomic, strong) CRLinkageHookInstanceCook *hookInstanceCook;
@property (nonatomic, assign) BOOL useLinkageHook;
@property (nonatomic, assign) CRLinkageScrollStatus linkageScrollStatus;
/// child的顶层容器view（child和main之间，离main最近的那个view。没有嵌套的话，就是childScrollView本身）
@property (nonatomic, strong) UIView *childNestedView;

@end

@implementation CRLinkageManager

/// init
- (instancetype)init
{
    return [self initWithUseLinkageHook:YES];
}

/// init
/// @param useLinkageHook 是否使用默认hook方法（用来hook shouldRecognizeSimultaneouslyWithGestureRecognizer）
- (instancetype)initWithUseLinkageHook:(BOOL)useLinkageHook
{
    self = [super init];
    if (self) {
        self.useLinkageHook = useLinkageHook;
        self.linkageScrollStatus = CRLinkageScrollStatus_Idle;
    }
    return self;
}

#pragma mark - 配置mainScrollView
/// 配置mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView {
    self.mainScrollView = mainScrollView;
    [self tryConfigLibkageScrollType];
}

#pragma mark - 配置childScrollView
- (void)addChildScrollView:(UIScrollView *)childScrollView {
    [self.childScrollViews addObject:childScrollView];
}

- (void)removeChildScrollView:(UIScrollView *)childScrollView {
    [self.childScrollViews removeObject:childScrollView];
}

- (void)resetChildScrollViews:(NSArray <UIScrollView *> *)childScrollViews {
    [self.childScrollViews removeAllObjects];
    [self.childScrollViews addObjectsFromArray:childScrollViews];
}

/// 尝试初始化libkageScrollType
- (void)tryConfigLibkageScrollType {
    if (self.mainScrollView != nil && self.currentChildScrollView != nil && self.linkageScrollStatus == CRLinkageScrollStatus_Idle) {
        self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
    }
}

#pragma mark - Setter & Getter
- (NSArray <UIScrollView *> *)getChildScrollViews {
    return [self.childScrollViews copy];
}

- (NSMutableArray *)childScrollViews {
    if (!_childScrollViews) {
        _childScrollViews = [NSMutableArray new];
    }
    
    return _childScrollViews;
}

@end
