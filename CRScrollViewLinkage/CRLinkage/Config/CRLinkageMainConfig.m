//
//  CRLinkageMainConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import "CRLinkageMainConfig.h"
#import "CRLinkageManager.h"
#import "UIScrollView+CRLinkage.h"
#import "CRLinkageManagerInternal.h"

@implementation CRLinkageMainConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // main专用
        self.mainScrollView = nil;
        self.mainLinkageInternal = nil;
        
        /// 头部/底部拉动极限
        self.headerBounceLimit = nil;
        self.footerBounceLimit = nil;
        /// 头部允许下拉到负一楼
        self.headerAllowToFirstFloor = NO;
        /// 底部允许上拉到阁楼
        self.footerAllowToLoft = NO;
        
        self.isCanScroll = NO;
        self.holdOffSetY = 0;
    }
    return self;
}

- (CRLinkageChildConfig *)currentChildConfig {
    return self.currentChildScrollView.linkageChildConfig;
}

- (UIScrollView *)currentChildScrollView {
    return self.mainLinkageInternal.childScrollView;
}

- (BOOL)isScrollOverTop {
    CGFloat bestContentOffSetY = 0;
    if (self.mainScrollView.contentOffset.y <= bestContentOffSetY) {
        return YES;
    }
    return NO;
}

- (BOOL)isScrollOverBottom {
    CGFloat bestContentOffSetY = self.mainScrollView.contentSize.height - self.mainScrollView.frame.size.height;
    if (self.mainScrollView.contentOffset.y >= bestContentOffSetY) {
        return YES;
    }
    return NO;
}

@end
