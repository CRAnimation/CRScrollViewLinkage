//
//  CRLinkageBaseConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageBaseConfig.h"

@implementation CRLinkageBaseConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentScrollView = nil;
        
        /// 头部/底部拉动极限
        self.headerBounceLimit = nil;
        self.footerBounceLimit = nil;
    }
    return self;
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

- (void)processChildScrollDir:(CRScrollDir)scrollDir
                      isLimit:(BOOL)isLimit
       overHeaderOrLimitBlock:(void (^)(BOOL isOver))overHeaderOrLimitBlock
       overFooterOrLimitBlock:(void (^)(BOOL isOver))overFooterOrLimitBlock {
    if (isLimit) {
        [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
            // 拉到头了，需要处理
            if (overHeaderOrLimitBlock) {
                overHeaderOrLimitBlock([self isScrollOverHeaderLimit]);
            }
        } downBlock:^{
            if (overFooterOrLimitBlock) {
                overFooterOrLimitBlock([self isScrollOverFooterLimit]);
            }
        }];
    } else {
        [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
            if (overHeaderOrLimitBlock) {
                overHeaderOrLimitBlock([self isScrollOverHeader]);
            }
        } downBlock:^{
            if (overFooterOrLimitBlock) {
                overFooterOrLimitBlock([self isScrollOverFooter]);
            }
        }];
    }
}

#pragma mark - Private
- (BOOL)_isScrollOverHeaderWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = 0 + limit;
    if (self.currentScrollView.contentOffset.y <= bestContentOffSetY) {
        return YES;
    }
    return NO;
}
- (BOOL)_isScrollOverFooterWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = self.currentScrollView.contentSize.height - self.currentScrollView.frame.size.height + limit;
    if (self.currentScrollView.contentOffset.y >= bestContentOffSetY) {
        return YES;
    }
    return NO;
}

@end
