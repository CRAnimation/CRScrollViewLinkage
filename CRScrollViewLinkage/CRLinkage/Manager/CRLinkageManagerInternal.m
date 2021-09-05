//
//  CRLinkageManagerInternal.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import "CRLinkageManagerInternal.h"
#import "CRLinkageHookInstanceCook.h"
#import "UIScrollView+CRLinkage.h"

static NSString * const kContentOffset = @"contentOffset";
static NSString * const kCenter = @"center";

@interface CRLinkageManagerInternal()

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong, readwrite) UIScrollView *childScrollView;
@property (nonatomic, strong) CRLinkageHookInstanceCook *hookInstanceCook;
@property (nonatomic, assign) BOOL useLinkageHook;
@property (nonatomic, assign) CRLinkageScrollStatus linkageScrollStatus;
/// child的顶层容器view（child和main之间，离main最近的那个view。没有嵌套的话，就是childScrollView本身）
@property (nonatomic, strong) UIView *childNestedView;
@property (nonatomic, strong) CRLinkageMainConfig *mainConfig;
@property (nonatomic, strong) CRLinkageChildConfig *childConfig;

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
    [self _tryConfigLinkageScrollType];
    [self _tryConfigOffSet];
}

/// 配置child（默认使用childScrollView的高度）
/// 可以根据场景多次调用，修改当前相应的child
/// @param childScrollView childScrollView
- (void)configChildScrollView:(UIScrollView *)childScrollView {
    [self configChildScrollView:childScrollView childViewHeight:childScrollView.frame.size.height];
}

/// 配置child
/// 可以根据场景多次调用，修改当前相应的child
/// @param childScrollView childScrollView
/// @param childViewHeight 指定Child的高度（因为可能childScroll会放在其他容器中，这时需要使用容器高度，尽量保证每次都一样。）
- (void)configChildScrollView:(UIScrollView *)childScrollView childViewHeight:(CGFloat)childViewHeight {
    self.childScrollView = childScrollView;
//    CGFloat tmpTopHeight = self.childScrollView.frame.origin.y;
//    [self childScrollViewUpdateTopHeight:tmpTopHeight];
    [self _tryConfigLinkageScrollType];
    [self _tryConfigOffSet];
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

- (void)findChildNestedView {
    if (!self.mainScrollView) {
        return;
    }
    
    UIView *tmpView = self.childScrollView;
    UIResponder *tmpResponder = tmpView.nextResponder;
    while (tmpResponder != nil && ![tmpResponder isKindOfClass:[UIWindow class]] && tmpResponder != self.mainScrollView) {
        tmpView = (UIView *)tmpResponder;
        tmpResponder = tmpResponder.nextResponder;
    }
    if (tmpResponder == self.mainScrollView) {
        self.childNestedView = tmpView;
    }
}

- (void)clearChildNestedView {
    self.childNestedView = nil;
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
    if (self.childNestedView) {
        [self.childNestedView addObserver:self forKeyPath:kCenter options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeChildObserver {
    [self.childScrollView removeObserver:self forKeyPath:kContentOffset];
    if (self.childNestedView) {
        [self.childNestedView removeObserver:self forKeyPath:kCenter];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kContentOffset]) {
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
            [self processMain:self.mainScrollView oldOffset:oldOffset newOffset:newOffset];
        } else if (object == self.childScrollView) {
            [self processChild:self.childScrollView oldOffset:oldOffset newOffset:newOffset];
        }
    } else if ([keyPath isEqualToString:kCenter]) {
        NSValue *oldValue = change[NSKeyValueChangeOldKey];
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGPoint oldPoint = [oldValue CGPointValue];
        CGPoint newPoint = [newValue CGPointValue];
        if (CGPointEqualToPoint(oldPoint, newPoint)) {
            return;
        }
        
        if (object == self.childNestedView) {
//            [self childScrollViewUpdateTopHeight:self.childNestedView.frame.origin.y];
        }
    }
}

#pragma mark - Header/Footer bounce type
- (CRBounceType)headerBounceType {
    return self.childScrollView.linkageChildConfig.headerBounceType;
}

- (CRBounceType)footerBounceType {
    return self.childScrollView.linkageChildConfig.footerBounceType;
}

#pragma mark - Process
- (void)processMain:(UIScrollView *)mainScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
    CGFloat bestOffSetY = self.childConfig.bestContentOffSet.y;
    CGFloat mainOffSetY = mainScrollView.contentOffset.y;
    CGFloat childOffSetY = self.childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
        
        case CRLinkageScrollStatus_Idle:
        {
            [self mainHold];
        }
            break;
        case CRLinkageScrollStatus_MainScroll:
        {
            [self _processMainScrollWithMainScrollView:mainScrollView oldOffset:oldOffset newOffset:newOffset];
        }
            break;
        case CRLinkageScrollStatus_ChildScroll:
        {
            // childScroll: main不能滑，child可以滑动
            [self mainHoldNeedRelax:YES];
        }
            break;
        case CRLinkageScrollStatus_MainRefresh:
        {
            if (mainOffSetY < bestOffSetY) {
                // 这个区域，mainRefresh: main可以滑动，child不能滑
                nil;
            } else {
                // 又开始往上滑了
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
        }
            break;
        case CRLinkageScrollStatus_MainRefreshToLimit:
        {
            /// 下拉刷新到极限
            if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [self.delegate scrollViewTriggerLimitWithScrollView:self.mainScrollView
                                                     scrollViewType:CRScrollViewForMain
                                                  bouncePostionType:CRBouncePositionToHeaderLimit];
            }
            
            /// 头部允许下拉到负一楼
            if (self.mainConfig.headerAllowToFirstFloor) {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainHoldOnFirstFloor;
                [self autoScrollToFirstFloor];
            }
            /// 头部不允许下拉到负一楼
            else {
                /// 状态重置到初始状态
                self.linkageScrollStatus = CRLinkageScrollStatus_Idle;
            }
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnFirstFloor:
        {
            switch (scrollDir) {
                case CRScrollDir_Hold: { nil; } break;
                case CRScrollDir_Up:
                {
#warning Bear 这里要结合child一起处理
                }
                    break;
                case CRScrollDir_Down:
                {
                    /// 下拉不再处理。固定在这个位置
                    [self mainHold];
                }
                    break;
            }
        }
            break;
        case CRLinkageScrollStatus_MainLoadMore:
        {
            if (mainOffSetY < bestOffSetY) {
                // 这个区域，mainRefresh: main可以滑动，child不能滑
                nil;
            } else {
                // 又开始往上滑了
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
        }
            break;
        case CRLinkageScrollStatus_MainLoadMoreToLimit:
        {}
            break;
        case CRLinkageScrollStatus_MainHoldOnLoft:
        {}
            break;
        case CRLinkageScrollStatus_ChildRefresh:
        {
            if (self.childConfig.gestureType == CRGestureForMainScrollView && childOffSetY == 0) {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            } else {
                [self mainHold];
            }
        }
            break;
        case CRLinkageScrollStatus_ChildRefreshToLimit:
        {}
            break;
        case CRLinkageScrollStatus_ChildLoadMore:
        {}
            break;
        case CRLinkageScrollStatus_ChildLoadMoreToLimit:
        {}
            break;
    }
}

#pragma mark ProcessMainScroll
- (void)_processMainScrollWithMainScrollView:(UIScrollView *)mainScrollView
                                   oldOffset:(CGFloat)oldOffset
                                   newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
    CGFloat bestOffSetY = self.childConfig.bestContentOffSet.y;
    CGFloat currentOffSetY = mainScrollView.contentOffset.y;
    BOOL isScrollToChild = NO;
    switch (scrollDir) {
        case CRScrollDir_Hold: { nil; } break;
            
        /// 往上滑
        case CRScrollDir_Up: {
            if (currentOffSetY >= bestOffSetY) {
                isScrollToChild = YES;
                switch (self.childConfig.gestureType) {
                    case CRGestureForMainScrollView: {
                        // 只滑了main的私有区域，即使到顶了，也不能切换为childScroll。
                        // 继续保持为mainScroll
                        
                        nil;
                    } break;
                    case CRGestureForBothScrollView:
                    {
                        // 切换为child滑动
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                    } break;
                }
            } else {
                // 继续保持为mainScroll
                nil;
            }
        }
            break;
            
        /// 往下滑
        case CRScrollDir_Down: {
            if (currentOffSetY <= bestOffSetY) {
                isScrollToChild = YES;
                switch (self.childConfig.gestureType) {
                    case CRGestureForMainScrollView: {
                        // 只滑了main的私有区域，即使到底了，也不能切换为childScroll。
                        if (self.mainConfig.footerBounceLimit && newOffset > -self.mainConfig.footerBounceLimit.floatValue) {
                            // 超过极限了
                            self.linkageScrollStatus = CRLinkageScrollStatus_MainRefreshToLimit;
                        } else {
                            // 继续保持为mainScroll
                            nil;
                        }
                        nil;
                    } break;
                    case CRGestureForBothScrollView:
                    {
                        // 切换为child滑动
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                    } break;
                }
            } else {
                // 继续保持为mainScroll
                nil;
            }
        }
            break;
    }
}

#pragma mark 自动滑到负1楼
/// main下拉超过极限，自动滑到负1楼
- (void)autoScrollToLoft {
    CGFloat bestMainOffSetY = 0 - CGRectGetHeight(self.mainScrollView.frame);
    [self autoScrollToContentOffSetY:bestMainOffSetY];
}

#pragma mark 自动滑到阁楼
/// main上拉超过极限，自动滑到阁楼
- (void)autoScrollToFirstFloor {
    CGFloat bestMainOffSetY = self.mainScrollView.contentSize.height;
    [self autoScrollToContentOffSetY:bestMainOffSetY];
    if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
        [self.delegate scrollViewTriggerLimitWithScrollView:self.mainScrollView
                                             scrollViewType:CRScrollViewForMain
                                          bouncePostionType:CRBouncePositionOverHeaderLimit];
    }
}

- (void)autoScrollToContentOffSetY:(CGFloat)contentOffSetY {
    CGFloat bestMainOffSetY = contentOffSetY;
    CGFloat currentMainOffSetY = self.mainScrollView.contentOffset.y;
    if (currentMainOffSetY != bestMainOffSetY) {
        CGPoint tmpContentOffSet = self.mainScrollView.contentOffset;
        tmpContentOffSet.y = bestMainOffSetY;
        [self.mainScrollView setContentOffset:tmpContentOffSet animated:YES];
    }
}

- (BOOL)checkScrollViewIsTopBottom:(UIScrollView *)scrollView {
    BOOL scrollViewIsToBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height <= 0;
    return scrollViewIsToBottom;
}

- (void)processChild:(UIScrollView *)childScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CGFloat currentOffSetY = childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {

        case CRLinkageScrollStatus_Idle:
            [self childHold];
            break;
            
            // mainScroll: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainScroll:
#warning Bear 这里的逻辑都再过一下
            if ([self headerBounceType] == CRBounceForChild) {
                // 刷新类型为child，mainContentOffset==0
                if (self.mainScrollView.contentOffset.y == 0) {
                    if (newOffset < 0) {
                        // 尝试向下滑，则切换为childRefresh
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildRefresh;
                    } else if (newOffset > 0) {
                        enum TmpScrollType {
                            TmpScrollTypeMain,
                            TmpScrollTypeChild,
                        };
                        enum TmpScrollType tmpScrollType = TmpScrollTypeMain;
                        BOOL mainScrollViewIsToBottom = [self checkScrollViewIsTopBottom:self.mainScrollView];
                        BOOL childScrollViewIsToBottom = [self checkScrollViewIsTopBottom:self.childScrollView];
                        
                        // 向上
                        if (self.mainScrollView.scrollEnabled == NO
                            || self.mainScrollView.userInteractionEnabled == NO) {
                            // main无法滑动，切换为childScroll
                            tmpScrollType = TmpScrollTypeChild;
                        } else if (self.childScrollView.scrollEnabled == NO
                                   || self.childScrollView.userInteractionEnabled == NO) {
                            // main可以滑动
                            tmpScrollType = TmpScrollTypeMain;
                        } else {
                            // main,child都滑倒底了
                            if (mainScrollViewIsToBottom && childScrollViewIsToBottom) {
                                switch ([self footerBounceType]) {
                                    case CRBounceForMain: { tmpScrollType = TmpScrollTypeMain; } break;
                                    case CRBounceForChild: { tmpScrollType = TmpScrollTypeChild; } break;
                                }
                            } else if (mainScrollViewIsToBottom) {
                                tmpScrollType = TmpScrollTypeChild;
                            } else {
                                tmpScrollType = TmpScrollTypeMain;
                            }
                        }
                        
                        switch (tmpScrollType) {
                            case TmpScrollTypeMain:
                                // main可以滑动
                                [self childHold];
                                break;
                            case TmpScrollTypeChild:
                                // main无法滑动，切换为childScroll
                                self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                                break;
                        }
                    } else {
                        [self childHold];
                    }
                } else {
                    [self childHold];
                }
            } else {
                // 向下滑，此时为临界状态，继续保持为mainScroll
                [self childHold];
            }
            break;
            
            // childScroll: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildScroll:
            // 区域内可滑:（value>=0）
            if (currentOffSetY >= 0) {
                nil;
            }
            // 拉到头了，切换为main滑动:(value<0)
            else {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainRefresh:
            [self childHold];
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildRefresh:
            // 区域内可滑:（value<0）
            if (currentOffSetY < 0) {
                nil;
            }
            // 又开始往上滑了:(value>=0)
            else {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
            break;
    }
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

- (void)mainHold {
    [self mainHoldNeedRelax:NO];
}

- (void)mainHoldNeedRelax:(BOOL)needRelax {
    [self scrollHoldDetail:self.mainScrollView needRelax:needRelax];
}

- (void)childHold {
    [self childHoldNeedRelax:NO];
}

- (void)childHoldNeedRelax:(BOOL)needRelax {
    [self scrollHoldDetail:self.childScrollView needRelax:needRelax];
}

- (void)scrollHoldDetail:(UIScrollView *)scrollView needRelax:(BOOL)needRelax {
    CGFloat offsetY = scrollView.linkageChildConfig.holdOffSetY;
    CGFloat currentOffsetY = scrollView.contentOffset.y;
//    CGFloat delta = 1;
    if (currentOffsetY != offsetY) {
        /// 这里面的后面再继续优化
//        if (needRelax) {
//            if (fabs(currentOffsetY - offsetY) > 20) {
//                return;
//            }
////            if (fabs(currentOffsetY - offsetY) > delta) {
////                if (offsetY > currentOffsetY) {
////                    offsetY = currentOffsetY + delta;
////                } else if (offsetY < currentOffsetY) {
////                    offsetY = currentOffsetY - delta;
////                }
////            }
//        }
        scrollView.contentOffset = CGPointMake(0, offsetY);
    }
}


#pragma mark - Reset Func
- (void)updateConfig {
    [self _tryConfigOffSet];
    [self _tryConfigLinkageScrollType];
}

- (void)_tryConfigOffSet {
    if (self.childScrollView && self.mainScrollView) {
        [self.childScrollView.linkageChildConfig caculateMainAnchorOffset:self.mainScrollView];
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
            mainConfig.holdOffSetY = childConfig.bestContentOffSet.y;
            
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
        CRLinkageChildConfig *config = [CRLinkageChildConfig new];
        config.currentScrollView = childScrollView;
        if (_childScrollView != nil) {
            config = _childScrollView.linkageChildConfig;
            [self removeChildObserver];
            [self clearChildNestedView];
        }
        _childScrollView = childScrollView;
        _childScrollView.linkageChildConfig = config;
        [self findChildNestedView];
        [self addChildObserver];
    }
}

@synthesize mainScrollView = _mainScrollView;
- (void)setMainScrollView:(UIScrollView *)mainScrollView {
    if (mainScrollView != _mainScrollView) {
        if (_mainScrollView != nil) {
            // 清空旧的
            CRLinkageMainConfig *config = [CRLinkageMainConfig new];
            config.mainScrollView = mainScrollView;
            _mainScrollView.linkageMainConfig = config;
            _mainScrollView.isLinkageMainScrollView = YES;
            [self removeMainObserver];
        }
        
        // 生成新的
        _mainScrollView = mainScrollView;
        _mainScrollView.linkageMainConfig.mainLinkageInternal = self;
        
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

#pragma mark - Dealloc
- (void)dealloc {
    [self removeMainObserver];
    [self removeChildObserver];
}

@end
