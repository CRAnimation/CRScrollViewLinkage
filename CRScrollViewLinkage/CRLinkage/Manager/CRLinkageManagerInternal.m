//
//  CRLinkageManagerInternal.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import "CRLinkageManagerInternal.h"
#import "CRLinkageHookInstanceCook.h"
#import "UIScrollView+CRLinkage.h"
#import "CRLinkageTool.h"
#import "CRLinkageManagerInternal+Child.h"
#import "CRLinkageManagerInternal+Main.h"

static NSString * const kContentOffset = @"contentOffset";
static NSString * const kBounds = @"bounds";
static NSString * const kCenter = @"center";

@interface CRLinkageManagerInternal()

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong, readwrite) UIScrollView *childScrollView;
@property (nonatomic, strong) CRLinkageHookInstanceCook *hookInstanceCook;
@property (nonatomic, assign) BOOL useLinkageHook;

@property (nonatomic, assign) CGPoint lastMainHoldPoint;
@property (nonatomic, assign) CGPoint lastChildHoldPoint;
@property (nonatomic, assign) BOOL haveLastMainHoldPoint;
@property (nonatomic, assign) BOOL haveLastChildHoldPoint;

@end

@implementation CRLinkageManagerInternal

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
//        self.customTopHeight = nil;
    }
    return self;
}

/// 配置mainScrollView
/// @param mainScrollView mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView {
    self.mainScrollView = mainScrollView;
    [self _updateConfig];
}

/// 配置child（默认使用childScrollView的高度）
/// 可以根据场景多次调用，修改当前相应的child
/// @param childScrollView childScrollView
- (void)configChildScrollView:(UIScrollView *)childScrollView {
    self.childScrollView = childScrollView;
    [self _updateConfig];
}

#warning Bear 检查下这个方法是否需要
- (void)childScrollViewUpdateTopHeight:(CGFloat)topHeight {
//    if (self.customTopHeight == nil) {
//        if (self.mainScrollView) {
//            self.mainScrollView.linkageConfig.childTopFixHeight = topHeight;
//        }
//    }
}

/// 尝试初始化libkageScrollType
- (void)_tryConfigLinkageScrollType {
    if (self.mainScrollView != nil && self.childScrollView != nil && self.linkageScrollStatus == CRLinkageScrollStatus_Idle) {
        self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
    }
}

#pragma mark - KVO
- (void)addMainObserver {
    [self.mainScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)removeMainObserver {
    [self.mainScrollView removeObserver:self forKeyPath:kContentOffset];
}

- (void)addChildObserver {
    [self.childScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    if (self.childFrameObservedView) {
        [self.childFrameObservedView addObserver:self forKeyPath:kBounds options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        [self.childFrameObservedView addObserver:self forKeyPath:kCenter options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeChildObserver {
    [self.childScrollView removeObserver:self forKeyPath:kContentOffset];
    if (self.childFrameObservedView) {
        [self.childFrameObservedView removeObserver:self forKeyPath:kBounds];
        [self.childFrameObservedView removeObserver:self forKeyPath:kCenter];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kContentOffset]) {
        if (self.enable == NO) {
            return;
        }
        
        UIScrollView *tmpScrollView = (UIScrollView *)object;
        //    if (tmpScrollView == self.mainScrollView) {
        //        NSLog(@"--main");
        //    } else if (object == self.childScrollView) {
        //        NSLog(@"--child");
        //    }
        
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGFloat oldOffset = oldValue.UIOffsetValue.vertical;
        CGFloat newOffset = newValue.UIOffsetValue.vertical;
        if (oldOffset == newOffset) {
            return;
        }
        
        if (tmpScrollView == self.mainScrollView) {
            [self _processMain:self.mainScrollView oldOffset:oldOffset newOffset:newOffset];
        } else if (object == self.childScrollView) {
            [self _processChild:self.childScrollView oldOffset:oldOffset newOffset:newOffset];
        }
    } else if ([keyPath isEqualToString:kCenter]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGPoint oldPoint = [oldValue CGPointValue];
        CGPoint newPoint = [newValue CGPointValue];
        if (CGPointEqualToPoint(oldPoint, newPoint)) {
            return;
        }
        
        if (object == self.childFrameObservedView) {
            [self _tryUpdateOffSet];
//            [self childScrollViewUpdateTopHeight:self.childFrameObservedView.frame.origin.y];
        }
    } else if ([keyPath isEqualToString:kBounds]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGRect oldFrame = [oldValue CGRectValue];
        CGRect newFrame = [newValue CGRectValue];
        if (CGRectEqualToRect(oldFrame, newFrame)) {
            return;
        }
        
        if (object == self.childFrameObservedView) {
            [self _tryUpdateOffSet];
        }
    }
}

#warning Bear 这里后面查一下是不是功能和已有方法重复了
- (BOOL)checkScrollViewIsTopBottom:(UIScrollView *)scrollView {
    BOOL scrollViewIsToBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height <= 0;
    return scrollViewIsToBottom;
}

#pragma mark - Tool Method
/// 判断方向
- (CRScrollDir)_checkDirByOldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CRScrollDir dir = CRScrollDir_Hold;
    if (oldOffset < newOffset) {
        dir = CRScrollDir_Up;
    }else if (oldOffset > newOffset) {
        dir = CRScrollDir_Down;
    }
    return dir;
}

#pragma mark - Reset Func
- (void)_updateConfig {
    [self _tryUpdateOffSet];
    [self _tryConfigLinkageScrollType];
}

- (void)_tryUpdateOffSet {
    if (self.childScrollView) {
        [self.childScrollView.linkageChildConfig caculateMainAnchorOffset];
    }
}

#pragma mark - Setter & Getter
- (void)setLinkageScrollStatus:(CRLinkageScrollStatus)linkageScrollStatus {
    CRLinkageMainConfig *mainConfig = self.mainScrollView.linkageMainConfig;
    CRLinkageChildConfig *childConfig = self.childScrollView.linkageChildConfig;
    
    switch (linkageScrollStatus) {

        case CRLinkageScrollStatus_Idle:
            mainConfig.isCanScroll = NO;
            mainConfig.holdOffSetY = 0;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // default: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainScroll:
            mainConfig.isCanScroll = YES;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // childScroll: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildScroll:
            mainConfig.isCanScroll = NO;
            mainConfig.holdOffSetY = childConfig.bestMainAnchorOffset.y;
            
            childConfig.isCanScroll = YES;
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainRefresh:
            mainConfig.isCanScroll = YES;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildRefresh:
            mainConfig.isCanScroll = NO;
            mainConfig.holdOffSetY = 0;
            
            childConfig.isCanScroll = YES;
            break;
    }
    
    _linkageScrollStatus = linkageScrollStatus;
}

@synthesize childScrollView = _childScrollView;
- (void)setChildScrollView:(UIScrollView *)childScrollView {
    if (childScrollView != _childScrollView) {
        CRLinkageChildConfig *config;
        if (childScrollView.linkageChildConfig) {
            config = childScrollView.linkageChildConfig;
        } else {
            config = [CRLinkageChildConfig new];
        }
        config.currentScrollView = childScrollView;
        if (_childScrollView != nil) {
            [self removeChildObserver];
            [self childClearFrameObservedView];
        }
        _childScrollView = childScrollView;
        _childScrollView.linkageChildConfig = config;
        _childScrollView.linkageChildConfig.linkageInternal = self;
        [self childGenerateFrameObservedView];
        [self addChildObserver];
    }
}

@synthesize mainScrollView = _mainScrollView;
- (void)setMainScrollView:(UIScrollView *)mainScrollView {
    if (mainScrollView != _mainScrollView) {
        if (_mainScrollView != nil) {
            // 清空旧的
            CRLinkageMainConfig *config = [CRLinkageMainConfig new];
            config.currentScrollView = mainScrollView;
            _mainScrollView.linkageMainConfig = config;
            _mainScrollView.isLinkageMainScrollView = YES;
            [self removeMainObserver];
        }
        
        // 生成新的
        _mainScrollView = mainScrollView;
        _mainScrollView.linkageMainConfig.linkageInternal = self;
        
        if (self.useLinkageHook) {
            [self.hookInstanceCook hookScrollViewInstance:mainScrollView];
            // 重新挂载手势代理，不然如果原本（包括父类）没有实现shouldRecognizeSimultaneouslyWithGestureRecognizer方法的话，通过runtime添加该方法不会被触发。
            _mainScrollView.panGestureRecognizer.delegate = _mainScrollView.panGestureRecognizer.delegate;
        }
        [self addMainObserver];
    }
}

- (CRLinkageHookInstanceCook *)hookInstanceCook {
    if (!_hookInstanceCook) {
        _hookInstanceCook = [CRLinkageHookInstanceCook new];
    }
    return _hookInstanceCook;
}

//- (void)setCustomTopHeight:(NSNumber *)customTopHeight {
//    _customTopHeight = customTopHeight;
//    if (self.mainScrollView) {
//        self.mainScrollView.linkageConfig.childTopFixHeight = customTopHeight;
//    }
//}

- (CRLinkageMainConfig *)mainConfig {
    return self.mainScrollView.linkageMainConfig;
}

- (CRLinkageChildConfig *)childConfig {
    return self.childScrollView.linkageChildConfig;
}

#pragma mark Header/Footer bounce type
- (CRBounceType)headerBounceType {
    return self.childScrollView.linkageChildConfig.headerBounceType;
}

- (CRBounceType)footerBounceType {
    return self.childScrollView.linkageChildConfig.footerBounceType;
}

#pragma mark Last Hold Point
- (void)setLastMainHoldPoint:(CGPoint)lastMainHoldPoint {
    _lastMainHoldPoint = lastMainHoldPoint;
    self.haveLastMainHoldPoint = YES;
}
- (void)setLastChildHoldPoint:(CGPoint)lastChildHoldPoint {
    _lastChildHoldPoint = lastChildHoldPoint;
    self.haveLastChildHoldPoint = YES;
}

- (BOOL)checkEqualLastMainHoldPoint:(CGPoint)lastPoint {
    if (self.haveLastMainHoldPoint && CGPointEqualToPoint(self.lastMainHoldPoint, lastPoint)) {
        return NO;
    }
    self.haveLastMainHoldPoint = NO;
    return YES;
}
- (BOOL)checkEqualLastChildHoldPoint:(CGPoint)lastPoint {
    if (self.haveLastChildHoldPoint && CGPointEqualToPoint(self.lastChildHoldPoint, lastPoint)) {
        return NO;
    }
    self.haveLastChildHoldPoint = NO;
    return YES;
}

#pragma mark - Dealloc
- (void)dealloc {
    [self removeMainObserver];
    [self removeChildObserver];
    NSLog(@"--dealloc:%@", NSStringFromClass([self class]));
}



@end
