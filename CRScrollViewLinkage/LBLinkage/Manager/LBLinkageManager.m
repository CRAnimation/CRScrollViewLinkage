//
//  LBLinkageManager.m
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import "LBLinkageManager.h"
#import "LBLinkageHookInstanceCook.h"
#import "LBLinkageConfig.h"

static NSString * const kContentOffset = @"contentOffset";
static NSString * const kCenter = @"center";

typedef enum : NSUInteger {
    // 不变
    LBScrollDir_Hold,
    // 向上滑
    LBScrollDir_Up,
    // 向下滑
    LBScrollDir_Down,
} LBScrollDir;

typedef enum : NSUInteger {
    LBLinkageScrollStatus_Idle = 0,
    
    // default: main可以滑动，child不能滑
    //
    // InMain
    // main.canscroll = YES; value=0;
    // child.canscroll = NO; hold=0;
    // next = mainScroll;
    // main.canscroll = YES;
    // child.canscroll = NO; hold=0;
//    LBLinkageScrollStatus_MainDefault,
    
    // mainScroll: main可以滑动，child不能滑
    //
    // InMain
    // 1,区域内可滑:（0<=value<mainOffsetY）
    //  nil
    // 2,继续上滑，滑到顶了，child即将允许滑动：(value>=mainOffsetY)
    //  next = childScroll
    //  main.canscroll = NO; hold=mainOffsetY;
    //  child.canscroll = YES;
    // 3,还在下拉，两个scrollView都拉到顶了，判断谁能刷新:(value<0)
    //  根据条件判断
    //  3.1,next=mainRefresh
    //      main.canscroll = YES;
    //      child.canscroll = NO; hold=0;
    //  3.2,next=childRefresh
    //      main.canscroll = NO; hold=0;
    //      child.canscroll = YES;
    LBLinkageScrollStatus_MainScroll,
    
    // childScroll: main不能滑，child可以滑动
    //
    // InChild
    // 1,区域内可滑:（value>=0）
    //  nil
    // 2,拉到头了，切换为main滑动:(value<0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    LBLinkageScrollStatus_ChildScroll,
    
    // mainRefresh: main可以滑动，child不能滑
    //
    // InMain
    // 1,区域内可滑:（value<0）
    // nil
    // 2,又开始往上滑了:(value>=0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    LBLinkageScrollStatus_MainRefresh,
    
    // childRefresh: main不能滑，child可以滑动
    //
    // InChild
    // 1,区域内可滑:（value<0）
    // nil
    // 2,又开始往上滑了:(value>=0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    LBLinkageScrollStatus_ChildRefresh,
} LBLinkageScrollStatus;

@interface LBLinkageManager()

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong, readwrite) UIScrollView *childScrollView;
@property (nonatomic, strong) LBLinkageHookInstanceCook *hookInstanceCook;
@property (nonatomic, assign) BOOL useLinkageHook;
@property (nonatomic, assign) LBLinkageScrollStatus linkageScrollStatus;
/// child的顶层容器view（child和main之间，离main最近的那个view。没有嵌套的话，就是childScrollView本身）
@property (nonatomic, strong) UIView *childNestedView;

@end

@implementation LBLinkageManager

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
        self.refreshType = LKRefreshForMain;
        self.linkageScrollStatus = LBLinkageScrollStatus_Idle;
        self.refreshType = LKRefreshForChild;
        self.customTopHeight = nil;
    }
    return self;
}


/// 配置mainScrollView
/// @param mainScrollView mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView {
    self.mainScrollView = mainScrollView;
    [self tryConfigLibkageScrollType];
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
    CGFloat tmpTopHeight = self.childScrollView.frame.origin.y;
    if (childViewHeight == 0) {
        self.childScrollView.linkageConfig.childHeight = self.mainScrollView.frame.size.height;
    } else {
        self.childScrollView.linkageConfig.childHeight = childViewHeight;
    }
    [self childScrollViewUpdateTopHeight:tmpTopHeight];
    [self tryConfigLibkageScrollType];
}

- (void)childScrollViewUpdateTopHeight:(CGFloat)topHeight {
    if (self.customTopHeight == nil) {
        if (self.mainScrollView) {
            self.mainScrollView.linkageConfig.mainTopHeight = topHeight;
        }
    }
}

/// 尝试初始化libkageScrollType
- (void)tryConfigLibkageScrollType {
    if (self.mainScrollView != nil && self.childScrollView != nil && self.linkageScrollStatus == LBLinkageScrollStatus_Idle) {
        self.linkageScrollStatus = LBLinkageScrollStatus_MainScroll;
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
            [self childScrollViewUpdateTopHeight:self.childNestedView.frame.origin.y];
        }
    }
}

/// 判断方向
- (LBScrollDir)checkDirByOldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    LBScrollDir dir = LBScrollDir_Hold;
    if (oldOffset < newOffset) {
        dir = LBScrollDir_Up;
    }else if (oldOffset > newOffset) {
        dir = LBScrollDir_Down;
    }
    return dir;
}

#pragma mark - Process
- (void)processMain:(UIScrollView *)mainScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CGFloat tmpOffset = [self getMainAnchorOffset];
    CGFloat currentOffSetY = mainScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
            
            // idle: 空
        case LBLinkageScrollStatus_Idle:
//            NSLog(@"--1");
            [self mainHold];
            break;
            
            // mainScroll: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainScroll:
//            NSLog(@"--2");
//            NSLog(@"--currentOffSetY:%f", currentOffSetY);
            // 区域内可滑:（0<=value<tmpOffset）
            if (currentOffSetY < tmpOffset && currentOffSetY >= 0) {
                nil;
            }
            // 继续上滑，滑到顶了，child即将允许滑动：(value>=tmpOffset)
            else if (currentOffSetY >= tmpOffset) {
                // 只滑了main的私有区域，即使到顶了，也不能切换为childScroll。
                // 继续保持为mainScroll
                if (mainScrollView.linkageConfig.mainGestureType == LKGestureForMainScrollView) {
                    nil;
                } else {
                    // 向下滑，此时为临界状态，继续保持为mainScroll
                    // （在main私有区域中上滑，然后在main&child共有区域立马下滑，会触发）
                    if ([self checkDirByOldOffset:oldOffset newOffset:newOffset] == LBScrollDir_Down) {
                        nil;
                    } else {
                        self.linkageScrollStatus = LBLinkageScrollStatus_ChildScroll;
                    }
                }
            }
            // 还在下拉，两个scrollView都拉到顶了，判断谁能刷新:(value<0)
            else {
                switch (self.refreshType) {
                        // 只能main刷新
                    case LKRefreshForMain:
                        self.linkageScrollStatus = LBLinkageScrollStatus_MainRefresh;
                        break;
                        
                        // 只能child刷新
                    case LKRefreshForChild:
                        self.linkageScrollStatus = LBLinkageScrollStatus_ChildRefresh;
                        break;
                }
            }
            break;
            
            // childScroll: main不能滑，child可以滑动
        case LBLinkageScrollStatus_ChildScroll:
//            NSLog(@"--3");
            [self mainHoldNeedRelax:YES];
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainRefresh:
//            NSLog(@"--4");
            // 区域内可滑:（value<0）
            if (currentOffSetY < 0) {
                nil;
            }
            // 又开始往上滑了:(value>=0)
            else {
                self.linkageScrollStatus = LBLinkageScrollStatus_MainScroll;
            }
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case LBLinkageScrollStatus_ChildRefresh:
//            NSLog(@"--5");
            // childRefresh状态下，却只滑了main的私有区域。
            // 并且child offsetY是0，没有滑动，则标识这会是个临界状态（滑得比较猛，自动触发到的childRefresh状态）
            if (mainScrollView.linkageConfig.mainGestureType == LKGestureForMainScrollView && self.childScrollView.contentOffset.y == 0) {
                self.linkageScrollStatus = LBLinkageScrollStatus_MainScroll;
            } else {
//                // 因为手势的问题，导致child在连贯的操作中无法拿到手势
//                if (self.childScrollView.contentOffset.y == 0) {
//                    CGFloat newOffSetY = self.childScrollView.contentOffset.y + (newOffset - oldOffset);
//                    CGPoint newOffset = CGPointMake(self.childScrollView.contentOffset.x, newOffSetY);
//                    self.childScrollView.contentOffset = newOffset;
//                } else {
                    [self mainHold];
//                }
            }
            break;
    }
}

- (BOOL)checkScrollViewIsTopBottom:(UIScrollView *)scrollView {
    BOOL scrollViewIsToBottom = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height <= 0;
    return scrollViewIsToBottom;
}

- (void)processChild:(UIScrollView *)childScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CGFloat currentOffSetY = childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {

        case LBLinkageScrollStatus_Idle:
            [self childHold];
            break;
            
            // mainScroll: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainScroll:
            if (self.refreshType == LKRefreshForChild) {
                // 刷新类型为child，mainContentOffset==0
                if (self.mainScrollView.contentOffset.y == 0) {
                    if (newOffset < 0) {
                        // 尝试向下滑，则切换为childRefresh
                        self.linkageScrollStatus = LBLinkageScrollStatus_ChildRefresh;
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
                                switch (self.loadMoreType) {
                                    case LKLoadMoreForMain: { tmpScrollType = TmpScrollTypeMain; } break;
                                    case LKLoadMoreForChild: { tmpScrollType = TmpScrollTypeChild; } break;
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
                                self.linkageScrollStatus = LBLinkageScrollStatus_ChildScroll;
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
        case LBLinkageScrollStatus_ChildScroll:
            // 区域内可滑:（value>=0）
            if (currentOffSetY >= 0) {
                nil;
            }
            // 拉到头了，切换为main滑动:(value<0)
            else {
                self.linkageScrollStatus = LBLinkageScrollStatus_MainScroll;
            }
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainRefresh:
            [self childHold];
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case LBLinkageScrollStatus_ChildRefresh:
            // 区域内可滑:（value<0）
            if (currentOffSetY < 0) {
                nil;
            }
            // 又开始往上滑了:(value>=0)
            else {
                self.linkageScrollStatus = LBLinkageScrollStatus_MainScroll;
            }
            break;
    }
}

#pragma mark - Tool Method
- (CGFloat)getMainAnchorOffset {
    CGFloat childHeight = self.childScrollView.linkageConfig.childHeight;
    CGFloat mainTopHeight = self.mainScrollView.linkageConfig.mainTopHeight;
    CGFloat mainScrollViewHeight = self.mainScrollView.frame.size.height;
    CGFloat tmpOffset = childHeight + mainTopHeight - mainScrollViewHeight;
    return tmpOffset;
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
    CGFloat offsetY = scrollView.linkageConfig.holdOffSetY;
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

#pragma mark - Setter & Getter
- (void)setLinkageScrollStatus:(LBLinkageScrollStatus)linkageScrollStatus {
    LBLinkageConfig *mainConfig = self.mainScrollView.linkageConfig;
    LBLinkageConfig *childConfig = self.childScrollView.linkageConfig;
    
    switch (linkageScrollStatus) {

        case LBLinkageScrollStatus_Idle:
            mainConfig.isCanScroll = NO;
            mainConfig.holdOffSetY = 0;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // default: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainScroll:
            mainConfig.isCanScroll = YES;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // childScroll: main不能滑，child可以滑动
        case LBLinkageScrollStatus_ChildScroll:
            mainConfig.isCanScroll = NO;
            mainConfig.holdOffSetY = [self getMainAnchorOffset];
            
            childConfig.isCanScroll = YES;
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case LBLinkageScrollStatus_MainRefresh:
            mainConfig.isCanScroll = YES;
            
            childConfig.isCanScroll = NO;
            childConfig.holdOffSetY = 0;
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case LBLinkageScrollStatus_ChildRefresh:
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
        LBLinkageConfig *config = [LBLinkageConfig new];
        if (_childScrollView != nil) {
            config = _childScrollView.linkageConfig;
            [self removeChildObserver];
            [self clearChildNestedView];
        }
        _childScrollView = childScrollView;
        _childScrollView.linkageConfig = config;
        [self findChildNestedView];
        [self addChildObserver];
    }
}

@synthesize mainScrollView = _mainScrollView;
- (void)setMainScrollView:(UIScrollView *)mainScrollView {
    if (mainScrollView != _mainScrollView) {
        if (_mainScrollView != nil) {
            // 清空旧的
            _mainScrollView.linkageConfig = [LBLinkageConfig new];
            [self removeMainObserver];
        }
        
        // 生成新的
        _mainScrollView = mainScrollView;
        _mainScrollView.linkageConfig.isMain = YES;
        _mainScrollView.linkageConfig.mainLinkageManager = self;
        
        if (self.useLinkageHook) {
            [self.hookInstanceCook hookScrollViewInstance:mainScrollView];
            // 重新挂载手势代理，不然如果原本（包括父类）没有实现shouldRecognizeSimultaneouslyWithGestureRecognizer方法的话，通过runtime添加该方法不会被触发。
            _mainScrollView.panGestureRecognizer.delegate = _mainScrollView.panGestureRecognizer.delegate;
        }
        [self addMainObserver];
    }
}

- (LBLinkageHookInstanceCook *)hookInstanceCook {
    if (!_hookInstanceCook) {
        _hookInstanceCook = [LBLinkageHookInstanceCook new];
    }
    return _hookInstanceCook;
}

- (void)setCustomTopHeight:(NSNumber *)customTopHeight {
    _customTopHeight = customTopHeight;
    if (self.mainScrollView) {
        self.mainScrollView.linkageConfig.mainTopHeight = [customTopHeight floatValue];
    }
}

#pragma mark - Dealloc
- (void)dealloc {
    [self removeMainObserver];
    [self removeChildObserver];
}

@end
