//
//  CRLinkageConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageChildConfig.h"
#import "CRLinkageManager.h"
#import "CRLinkageManagerInternal.h"

@implementation CRLinkageChildConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.frameObserveType = CRChildFrameObserveType_NearMain;
        
        /// 头部/尾部固定预留高度
        self.childTopFixHeight = 0;
        self.childBottomFixHeight = 0;
        
        /// 上拉/下拉回弹类型
        self.headerBounceType = CRBounceType_Main;
        self.footerBounceType = CRBounceType_Main;
        
        self.childHoldPosition = CRChildHoldPosition_Center;
        self.positionRatio = 0.5;
        
        // main，child共用
        self.isCanScroll = NO;
        self.holdOffSetY = 0;
    }
    return self;
}

- (void)setPositionRatio:(CGFloat)positionRatio {
    if (positionRatio > 1) {
        positionRatio = 1;
    }
    if (positionRatio < 0) {
        positionRatio = 0;
    }
    _positionRatio = positionRatio;
}

/// 计算出bestContentOffSet
- (void)caculateMainAnchorOffset {
    UIScrollView *mainScrollView = self.linkageInternal.mainScrollView;
    if (!mainScrollView) {
        return;
    }
    CGRect mainFrame = mainScrollView.frame;
    CGRect childFrame = self._frameObservedView.frame;
    CGFloat mainScrollViewHeight = mainScrollView.frame.size.height;
    CGFloat resOffSet = 0;
    switch (self.childHoldPosition) {
        case CRChildHoldPosition_Center:
            resOffSet = CGRectGetMidY(childFrame) - mainScrollViewHeight/2.0;
            break;
        case CRChildHoldPosition_Top:
            resOffSet = CGRectGetMinY(childFrame) - self.childTopFixHeight;
            break;
        case CRChildHoldPosition_Bottom:
            resOffSet = CGRectGetMaxY(childFrame) + self.childBottomFixHeight - mainScrollViewHeight;
            break;
        case CRChildHoldPosition_CustomRatio:
            resOffSet = CGRectGetMinY(childFrame) + (mainScrollViewHeight - CGRectGetHeight(childFrame)) * self.positionRatio;
            break;
    }
    self.bestMainAnchorOffset = CGPointMake(0, resOffSet);
}

- (void)setChildHoldPosition:(CRChildHoldPosition)childHoldPosition {
    if (_childHoldPosition != childHoldPosition) {
        _childHoldPosition = childHoldPosition;
        [self caculateMainAnchorOffset];
    }
}

- (void)configFrameObservedView:(UIView * _Nullable)frameObservedView {
    __frameObservedView = frameObservedView;
}

@end
