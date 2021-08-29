//
//  CRLinkageConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageChildConfig.h"
#import "CRLinkageManager.h"

@implementation CRLinkageChildConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // child专用
        self.childTopFixHeight = 0;
        self.childBottomFixHeight = 0;
        self.headerBounceType = CRBounceForMain;
        self.footerBounceType = CRBounceForMain;
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
- (void)caculateMainAnchorOffset:(UIScrollView *)mainScrollView {
    CGRect childFrame = self.currentScrollView.frame;
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
    self.bestContentOffSet = CGPointMake(0, resOffSet);
}

@end
