//
//  CRLinkageMainConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import "CRLinkageMainConfig.h"
#import "CRLinkageManager.h"

@implementation CRLinkageMainConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // main专用
        self.mainScrollView = nil;
        self.mainGestureType = CRGestureForMainScrollView;
        self.mainLinkageInternal = nil;
        
        /// 头部/底部拉动极限
        self.headerBounceLimit = nil;
        self.footerBounceLimit = nil;
        
        self.isCanScroll = NO;
        self.holdOffSetY = 0;
    }
    return self;
}

@end
