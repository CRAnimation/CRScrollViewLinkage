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
        self.mainLinkageManager = nil;
        
        // child专用
        self.childTopFixHeight = nil;
//        self.childHeight
        self.headerBounceType = CRBounceForMain;
        self.footerBounceType = CRBounceForMain;
        
        // main，child共用
        self.isMain = NO;
//        self.isCanScroll = NO;
//        self.holdOffSetY = 0;
    }
    return self;
}

@end
