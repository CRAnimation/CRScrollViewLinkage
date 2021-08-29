//
//  CRLinkageManager.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageManager.h"
#import "CRLinkageManagerInternal.h"
#import "CRLinkageChildConfig.h"
#import "UIScrollView+CRLinkage.h"
#import <pthread.h>

@interface CRLinkageManager() <CRLinkageManagerInternalDelegate>
{
    pthread_mutex_t _arrayLock;
}

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray <UIScrollView *> *childScrollViews;
@property (nonatomic, strong) UIScrollView *currentChildScrollView;

@property (nonatomic, strong) CRLinkageManagerInternal *linkageInternal;

@end

@implementation CRLinkageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    [self.linkageInternal configMainScrollView:mainScrollView];
}

#pragma mark 配置childScrollView
/// 配置childScrollView
- (void)configCurrentChildScrollView:(UIScrollView *)childScrollView {
    self.currentChildScrollView = childScrollView;
    [self.linkageInternal configChildScrollView:childScrollView];
}

#pragma mark 添加/删除/重置childScrollView
- (void)addChildScrollView:(UIScrollView *)childScrollView {
    pthread_mutex_lock(&_arrayLock);
    [self.childScrollViews addObject:childScrollView];
    pthread_mutex_unlock(&_arrayLock);
}

- (void)removeChildScrollView:(UIScrollView *)childScrollView {
    pthread_mutex_lock(&_arrayLock);
    [self.childScrollViews removeObject:childScrollView];
    pthread_mutex_unlock(&_arrayLock);
}

- (void)resetChildScrollViews:(NSArray <UIScrollView *> *)childScrollViews {
    pthread_mutex_lock(&_arrayLock);
    [self.childScrollViews removeAllObjects];
    [self.childScrollViews addObjectsFromArray:childScrollViews];
    pthread_mutex_unlock(&_arrayLock);
}

- (void)clearChildScrollViews {
    pthread_mutex_lock(&_arrayLock);
    [self.childScrollViews removeAllObjects];
    pthread_mutex_unlock(&_arrayLock);
}

- (void)childChanged {
    [self clearOrderCache];
}

#pragma mark - Private
- (void)clearOrderCache {
    pthread_mutex_lock(&_arrayLock);
    NSArray *originArray = [self.childScrollViews copy];
    pthread_mutex_unlock(&_arrayLock);
    
#warning Bear 这里线程安全优化下
    [originArray enumerateObjectsUsingBlock:^(UIScrollView *tmpScrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        tmpScrollView.linkageConfig.lastScrollView = nil;
        tmpScrollView.linkageConfig.nextScrollView = nil;
    }];
}

#pragma mark - CRLinkageManagerInternalDelegate
- (void)linkageNeedRelayStatus:(CRLinkageRelayStatus)linkageRelayStatus {
    UIScrollView *newChildScrollView = [self findNextScrollView:linkageRelayStatus currentScrollView:self.currentChildScrollView];
    [self configCurrentChildScrollView:newChildScrollView];
}

#pragma mark - Func
- (UIScrollView * __nullable)findNextScrollView:(CRLinkageRelayStatus)linkageRelayStatus currentScrollView:(UIScrollView *)currentScrollView {
    /// 先查缓存
    CRLinkageChildConfig *linkageConfig = currentScrollView.linkageConfig;
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
    NSArray *originArray = [self.childScrollViews copy];
    pthread_mutex_unlock(&_arrayLock);
    
    if (linkageRelayStatus == CRLinkageRelayStatus_RemainCurrent || originArray.count == 0) {
        return currentScrollView;
    }
    
    if (originArray.count == 1) {
        return originArray[0];
    }
    
    __block UIScrollView *resultScrollView;
    __block CGFloat minDeltaValue = CGFLOAT_MAX;
    __block CGFloat minDeltaIndex = 0;
    CGFloat currentBottom = CGRectGetMaxY(currentScrollView.frame);
    CGFloat currentTop = CGRectGetMinY(currentScrollView.frame);
    
#warning Bear 这里线程安全优化下
    [originArray enumerateObjectsUsingBlock:^(UIScrollView *tmpScrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tmpScrollView == currentScrollView) {
            return;
        }
        
        CGFloat tmpBottom = CGRectGetMaxY(tmpScrollView.frame);
        CGFloat tmpTop = CGRectGetMinY(tmpScrollView.frame);
        
        switch (linkageRelayStatus) {
            case CRLinkageRelayStatus_RemainCurrent:
            {
                nil;
            }
                break;
            case CRLinkageRelayStatus_ToLastScrollView:
            {
                CGFloat delta = currentBottom - tmpBottom;
                if (delta > 0 && delta < minDeltaValue) {
                    minDeltaValue = delta;
                    resultScrollView = tmpScrollView;
                    minDeltaIndex = idx;
                    linkageConfig.lastScrollView = resultScrollView;
                }
            }
                break;
            case CRLinkageRelayStatus_ToNextScrollView:
            {
                CGFloat delta = tmpTop - currentTop;
                if (delta > 0 && delta < minDeltaValue) {
                    minDeltaValue = delta;
                    resultScrollView = tmpScrollView;
                    minDeltaIndex = idx;
                    linkageConfig.nextScrollView = resultScrollView;
                }
            }
                break;
        }
    }];
    
    return resultScrollView;
}

#pragma mark - Setter & Getter
- (NSArray <UIScrollView *> *)getChildScrollViews {
    pthread_mutex_lock(&_arrayLock);
    NSArray *tmpArray = [self.childScrollViews copy];
    pthread_mutex_unlock(&_arrayLock);
    
    return tmpArray;
}

- (NSMutableArray <UIScrollView *> *)childScrollViews {
    if (!_childScrollViews) {
        _childScrollViews = [NSMutableArray new];
    }
    
    return _childScrollViews;
}

- (CRLinkageManagerInternal *)linkageInternal {
    if (!_linkageInternal) {
        _linkageInternal = [CRLinkageManagerInternal new];
        _linkageInternal.delegate = self;
    }
    
    return _linkageInternal;
}

@end
