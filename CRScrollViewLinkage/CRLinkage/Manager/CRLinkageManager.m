//
//  CRLinkageManager.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageManager.h"
#import "CRLinkageHookInstanceCook.h"
#import "CRLinkageManagerInternal.h"
#import "CRLinkageChildConfig.h"
#import "CRLinkageMainConfig.h"
#import "UIScrollView+CRLinkage.h"
#import <pthread.h>

@interface CRLinkageManager() <CRLinkageManagerInternalDelegate>
{
    pthread_mutex_t _arrayLock;
}

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIScrollView *currentChildScrollView;
@property (nonatomic, strong) NSMutableArray <CRLinkageManagerInternal *> *linkageInternalArray;
@property (nonatomic, assign) BOOL useLinkageHook;
@property (nonatomic, strong) CRLinkageHookInstanceCook *hookInstanceCook;
@property (nonatomic, assign) NSInteger currentActiveIndex;
@property (nonatomic, assign) BOOL haveAddMainObserver;

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
        self.currentActiveIndex = -1;
        self.useLinkageHook = useLinkageHook;
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        pthread_mutex_init(&_arrayLock, &attr);
    }
    return self;
}

#pragma mark Public
#pragma mark 配置mainScrollView
/// 配置mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView {
    self.mainScrollView = mainScrollView;
    
    CRLinkageMainConfig *config = [CRLinkageMainConfig new];
    config.currentScrollView = mainScrollView;
    self.mainScrollView.linkageMainConfig = config;
    self.mainScrollView.isLinkageMainScrollView = YES;
    
    if (self.useLinkageHook) {
        [self.hookInstanceCook hookScrollViewInstance:mainScrollView];
        // 重新挂载手势代理，不然如果原本（包括父类）没有实现shouldRecognizeSimultaneouslyWithGestureRecognizer方法的话，通过runtime添加该方法不会被触发。
        mainScrollView.panGestureRecognizer.delegate = mainScrollView.panGestureRecognizer.delegate;
    }
    
    [self.linkageInternalArray enumerateObjectsUsingBlock:^(CRLinkageManagerInternal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj configMainScrollView:mainScrollView];
    }];
    
    [self tryCommonConfig];
    [self addMainObserver];
}

- (void)tryCommonConfig {
#warning Bear 主要靠这个currentActiveIndex，后面看能不能删掉
    if (self.mainScrollView && self.currentActiveIndex >= 0 && self.linkageInternalArray.count > 0) {
        [self.mainScrollView.linkageMainConfig configLinkageInternalForMain:self.linkageInternalArray[self.currentActiveIndex]];
    }
}

#pragma mark 激活childScrollView
/// 激活childScrollView
- (void)activeCurrentChildScrollView:(UIScrollView *)childScrollView {
    CRLinkageManagerInternal *oldInternal = [self getLinkageManagerInternalByChild:self.currentChildScrollView];
    if (oldInternal) {
        oldInternal.internalActive = NO;
    }
    
    CRLinkageManagerInternal *newInternal = [self getLinkageManagerInternalByChild:childScrollView];
    newInternal.internalActive = YES;
    self.currentChildScrollView = childScrollView;
    [self.mainScrollView.linkageMainConfig configLinkageInternalForMain:newInternal];
}

#pragma mark 添加/删除/重置childScrollView
//- (void)addChildScrollView:(UIScrollView *)childScrollView {
//    pthread_mutex_lock(&_arrayLock);
//    [self.childScrollViews addObject:childScrollView];
//    pthread_mutex_unlock(&_arrayLock);
//}
//
//- (void)removeChildScrollView:(UIScrollView *)childScrollView {
//    pthread_mutex_lock(&_arrayLock);
//    [self.childScrollViews removeObject:childScrollView];
//    pthread_mutex_unlock(&_arrayLock);
//}

- (void)configChildScrollViews:(NSArray <UIScrollView *> *)childScrollViews activeChildIndex:(NSInteger)activeChildIndex {
    self.currentActiveIndex = activeChildIndex;
    __weak typeof(self) weakSelf = self;
    [childScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull tmpChildScrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        CRLinkageManagerInternal *tmpLinkageInternal = [weakSelf generateLinkageInternal];
        [tmpLinkageInternal configChildScrollView:tmpChildScrollView];
        [weakSelf.linkageInternalArray addObject:tmpLinkageInternal];
    }];
    
    if (childScrollViews.count > activeChildIndex) {
        UIScrollView *tmpChildScrollView = childScrollViews[activeChildIndex];
        [self activeCurrentChildScrollView:tmpChildScrollView];
    }
}

//- (void)clearChildScrollViews {
//    pthread_mutex_lock(&_arrayLock);
//    [self.childScrollViews removeAllObjects];
//    pthread_mutex_unlock(&_arrayLock);
//}

//- (void)childChanged {
//    [self clearOrderCache];
//}

#pragma mark - Private
//- (void)clearOrderCache {
//    pthread_mutex_lock(&_arrayLock);
//    NSArray *originArray = [self.childScrollViews copy];
//    pthread_mutex_unlock(&_arrayLock);
//
//#warning Bear 这里线程安全优化下
//    [originArray enumerateObjectsUsingBlock:^(UIScrollView *tmpScrollView, NSUInteger idx, BOOL * _Nonnull stop) {
//        tmpScrollView.linkageChildConfig.lastScrollView = nil;
//        tmpScrollView.linkageChildConfig.nextScrollView = nil;
//    }];
//}

#pragma mark - CRLinkageManagerInternalDelegate
- (void)linkageNeedRelayStatus:(CRLinkageRelayStatus)linkageRelayStatus {
    UIScrollView *newChildScrollView = [self findNextScrollView:linkageRelayStatus currentScrollView:self.currentChildScrollView];
    [self activeCurrentChildScrollView:newChildScrollView];
    [self.mainScrollView.linkageMainConfig configLinkageInternalForMain:newChildScrollView.linkageChildConfig.linkageInternal];
}

- (void)scrollViewTriggerLimitWithScrollView:(nonnull UIScrollView *)scrollView scrollViewType:(CRScrollViewType)scrollViewType bouncePostionType:(CRBouncePostionType)bouncePostionType {
    NSString *typeStr;
    switch (scrollViewType) {
        case CRScrollViewType_Main: {typeStr = @"main";} break;
        case CRScrollViewType_Child: {typeStr = @"child";} break;
    }
    NSString *positionStr;
    switch (bouncePostionType) {
        case CRBouncePositionOverHeaderLimit: {positionStr = @"headerLimit";} break;
        case CRBouncePositionOverFooterLimit: {positionStr = @"footerLimit";} break;
    }
    NSLog(@"--triggerLimit typeStr:%@ positionStr:%@", typeStr, positionStr);
    
    switch (scrollViewType) {
        case CRScrollViewType_Main:
        {
            nil;
        }
            break;
        case CRScrollViewType_Child:
        {
            UIScrollView *nextScrollView;
            switch (bouncePostionType) {
                case CRBouncePositionOverHeaderLimit:
                {
                    nextScrollView = [self findNextScrollView:CRLinkageRelayStatus_ToLastScrollView currentScrollView:scrollView];
                }
                    break;
                case CRBouncePositionOverFooterLimit:
                {
                    nextScrollView = [self findNextScrollView:CRLinkageRelayStatus_ToNextScrollView currentScrollView:scrollView];
                }
                    break;
            }
            NSLog(@"--nextScrollView:%@", nextScrollView);
            [self activeCurrentChildScrollView:nextScrollView];
        }
            break;
    }
}


#pragma mark - Func
- (UIScrollView * __nullable)findNextScrollView:(CRLinkageRelayStatus)linkageRelayStatus currentScrollView:(UIScrollView *)currentScrollView {
    /// 先查缓存
    CRLinkageChildConfig *linkageConfig = currentScrollView.linkageChildConfig;
    switch (linkageRelayStatus) {
        case CRLinkageRelayStatus_RemainCurrent:
        {
            nil;
        }
            break;
        case CRLinkageRelayStatus_ToLastScrollView:
        {
            if (linkageConfig.lastScrollView) {
                return linkageConfig.lastScrollView;
            }
        }
            break;
        case CRLinkageRelayStatus_ToNextScrollView:
        {
            if (linkageConfig.nextScrollView) {
                return linkageConfig.nextScrollView;
            }
        }
            break;
    }
    
    pthread_mutex_lock(&_arrayLock);
    NSArray *originArray = [self getChilds];
    pthread_mutex_unlock(&_arrayLock);
    
    if (linkageRelayStatus == CRLinkageRelayStatus_RemainCurrent || originArray.count == 0) {
        return currentScrollView;
    }
    
    if (originArray.count == 1) {
        return originArray[0];
    }
    
    __block UIScrollView *resultScrollView;
    
    switch (linkageRelayStatus) {
        case CRLinkageRelayStatus_RemainCurrent:
        {
            nil;
        }
            break;
        case CRLinkageRelayStatus_ToLastScrollView:
        {
            if (self.currentActiveIndex > 0) {
                self.currentActiveIndex--;
                resultScrollView = [self getChilds][self.currentActiveIndex];
            }
        }
            break;
        case CRLinkageRelayStatus_ToNextScrollView:
        {
            if (self.currentActiveIndex < [self getChilds].count - 1) {
                self.currentActiveIndex++;
                resultScrollView = [self getChilds][self.currentActiveIndex];
            }
        }
            break;
    }
    
    return resultScrollView;
}

//- (UIScrollView * __nullable)findNextScrollView:(CRLinkageRelayStatus)linkageRelayStatus currentScrollView:(UIScrollView *)currentScrollView {
//    /// 先查缓存
//    CRLinkageChildConfig *linkageConfig = currentScrollView.linkageChildConfig;
//    switch (linkageRelayStatus) {
//        case CRLinkageRelayStatus_RemainCurrent:
//        {
//            nil;
//        }
//            break;
//        case CRLinkageRelayStatus_ToLastScrollView:
//        {
//            if (linkageConfig.lastScrollView) {
//                return linkageConfig.lastScrollView;
//            }
//        }
//            break;
//        case CRLinkageRelayStatus_ToNextScrollView:
//        {
//            if (linkageConfig.nextScrollView) {
//                return linkageConfig.nextScrollView;
//            }
//        }
//            break;
//    }
//
//    pthread_mutex_lock(&_arrayLock);
//    NSArray *originArray = [self getChilds];
//    pthread_mutex_unlock(&_arrayLock);
//
//    if (linkageRelayStatus == CRLinkageRelayStatus_RemainCurrent || originArray.count == 0) {
//        return currentScrollView;
//    }
//
//    if (originArray.count == 1) {
//        return originArray[0];
//    }
//
//    __block UIScrollView *resultScrollView;
//    __block CGFloat minDeltaValue = CGFLOAT_MAX;
//    __block CGFloat minDeltaIndex = 0;
//    CGFloat currentBottom = CGRectGetMaxY(currentScrollView.frame);
//    CGFloat currentTop = CGRectGetMinY(currentScrollView.frame);
//
//#warning Bear 这里线程安全优化下
//    [originArray enumerateObjectsUsingBlock:^(UIScrollView *tmpScrollView, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (tmpScrollView == currentScrollView) {
//            return;
//        }
//
//        CGFloat tmpBottom = CGRectGetMaxY(tmpScrollView.frame);
//        CGFloat tmpTop = CGRectGetMinY(tmpScrollView.frame);
//
//        switch (linkageRelayStatus) {
//            case CRLinkageRelayStatus_RemainCurrent:
//            {
//                nil;
//            }
//                break;
//            case CRLinkageRelayStatus_ToLastScrollView:
//            {
//                CGFloat delta = currentBottom - tmpBottom;
//                if (delta > 0 && delta < minDeltaValue) {
//                    minDeltaValue = delta;
//                    resultScrollView = tmpScrollView;
//                    minDeltaIndex = idx;
//                    linkageConfig.lastScrollView = resultScrollView;
//                }
//            }
//                break;
//            case CRLinkageRelayStatus_ToNextScrollView:
//            {
//                CGFloat delta = tmpTop - currentTop;
//                if (delta > 0 && delta < minDeltaValue) {
//                    minDeltaValue = delta;
//                    resultScrollView = tmpScrollView;
//                    minDeltaIndex = idx;
//                    linkageConfig.nextScrollView = resultScrollView;
//                }
//            }
//                break;
//        }
//    }];
//
//    return resultScrollView;
//}

#pragma mark - Setter & Getter
//- (NSArray <UIScrollView *> *)getChildScrollViews {
//    pthread_mutex_lock(&_arrayLock);
//    NSArray *tmpArray = [self.childScrollViews copy];
//    pthread_mutex_unlock(&_arrayLock);
//
//    return tmpArray;
//}

- (NSArray <UIScrollView *> *)getChilds {
    NSMutableArray *resArray = [NSMutableArray new];
    [self.linkageInternalArray enumerateObjectsUsingBlock:^(CRLinkageManagerInternal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resArray addObject:obj.childScrollView];
    }];
    return [resArray copy];
}

//- (NSMutableArray <UIScrollView *> *)childScrollViews {
//    if (!_childScrollViews) {
//        _childScrollViews = [NSMutableArray new];
//    }
//
//    return _childScrollViews;
//}

- (NSMutableArray<CRLinkageManagerInternal *> *)linkageInternalArray {
    if (!_linkageInternalArray) {
        _linkageInternalArray = [NSMutableArray new];
    }
    
    return _linkageInternalArray;
}

- (CRLinkageHookInstanceCook *)hookInstanceCook {
    if (!_hookInstanceCook) {
        _hookInstanceCook = [CRLinkageHookInstanceCook new];
    }
    return _hookInstanceCook;
}

#pragma mark - KVO
- (void)addMainObserver {
    if (self.haveAddMainObserver) {
        return;
    }
    [self.mainScrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)removeMainObserver {
    if (self.haveAddMainObserver) {
        self.haveAddMainObserver = NO;
        [self.mainScrollView removeObserver:self forKeyPath:kContentOffset];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.currentChildScrollView) {
        [self.currentChildScrollView.linkageChildConfig.linkageInternal observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - LinkageInternal Method
- (CRLinkageManagerInternal *)getLinkageManagerInternalByChild:(UIScrollView *)childScrollView {
    for (CRLinkageManagerInternal *linkageManagerInternal in self.linkageInternalArray) {
        if (linkageManagerInternal.childScrollView == childScrollView) {
            return linkageManagerInternal;
        }
    }
    return nil;
}

- (CRLinkageManagerInternal *)generateLinkageInternal {
    CRLinkageManagerInternal *linkageInternal = [CRLinkageManagerInternal new];
    linkageInternal.delegate = self;
    return linkageInternal;
}

#pragma mark - Dealloc
- (void)dealloc
{
    [self removeMainObserver];
    NSLog(@"--dealloc:%@", NSStringFromClass([self class]));
}

@end
