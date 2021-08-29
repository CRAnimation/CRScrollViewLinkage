//
//  CRLinkageConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageConfig.h"
#import "CRLinkageManager.h"

@implementation CRLinkageConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // main专用
        self.mainGestureType = CRGestureForMainScrollView;
        self.mainLinkageInternal = nil;
        
        // child专用
        self.childTopFixHeight = 0;
        self.childBottomFixHeight = 0;
        self.headerBounceType = CRBounceForMain;
        self.footerBounceType = CRBounceForMain;
        self.childHoldPosition = CRChildHoldPosition_Center;
        self.positionRatio = 0.5;
        
        // main，child共用
        self.isMain = NO;
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

@end
