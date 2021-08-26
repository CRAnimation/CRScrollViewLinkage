//
//  CRLinkageManager.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageManager.h"
#import "CRLinkageManagerInternal.h"

@interface CRLinkageManager() <CRLinkageManagerInternalDelegate>

@property (nonatomic, strong, readwrite) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSMutableArray *childScrollViews;
@property (nonatomic, strong) UIScrollView *currentChildScrollView;

@property (nonatomic, strong) CRLinkageManagerInternal *linkageInternal;

@end

@implementation CRLinkageManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - 配置mainScrollView
/// 配置mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView {
    self.mainScrollView = mainScrollView;
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

#pragma mark - CRLinkageManagerInternalDelegate
- (void)linkageNeedRelayStatus:(CRLinkageRelayStatus)linkageRelayStatus {
    switch (linkageRelayStatus) {
        case CRLinkageRelayStatus_Idle:
        {
            
        }
            break;
        case CRLinkageRelayStatus_ToUpScrollView:
        {
            
        }
            break;
        case CRLinkageRelayStatus_ToDownScrollView:
        {
            
        }
            break;
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

- (CRLinkageManagerInternal *)linkageInternal {
    if (!_linkageInternal) {
        _linkageInternal = [CRLinkageManagerInternal new];
        _linkageInternal.delegate = self;
    }
    
    return _linkageInternal;
}

@end
