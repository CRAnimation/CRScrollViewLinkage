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
        self.mainTopHeight = 0;
        self.mainGestureType = CRGestureForMainScrollView;
        self.mainLinkageManager = nil;
        
        self.isMain = NO;
        self.headerBounceType = CRBounceForMain;
        self.footerBounceType = CRBounceForMain;
//        self.isCanScroll = NO;
//        self.holdOffSetY = 0;
    }
    return self;
}

@end
