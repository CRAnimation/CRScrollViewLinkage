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


#pragma mark - Scroll Over Check
- (BOOL)isScrollOverHeader {
    return [self _isScrollOverHeaderWithLimit:0];
}
- (BOOL)isScrollOverHeaderLimit {
    if (self.headerBounceLimit) {
        return [self _isScrollOverHeaderWithLimit:self.headerBounceLimit.floatValue];
    }
    return NO;
}

- (BOOL)isScrollOverFooter {
    return [self _isScrollOverFooterWithLimit:0];
}
- (BOOL)isScrollOverFooterLimit {
    if (self.footerBounceLimit) {
        return [self _isScrollOverFooterWithLimit:self.footerBounceLimit.floatValue];
    }
    return NO;
}

#pragma mark - Private
- (BOOL)_isScrollOverHeaderWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = 0 + limit;
    if (self.mainScrollView.contentOffset.y <= bestContentOffSetY) {
        return YES;
    }
    return NO;
}
- (BOOL)_isScrollOverFooterWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = self.mainScrollView.contentSize.height - self.mainScrollView.frame.size.height + limit;
    if (self.mainScrollView.contentOffset.y >= bestContentOffSetY) {
        return YES;
    }
    return NO;
}

@end
