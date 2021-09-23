//
//  CRLinkageBaseConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageBaseConfig.h"
#import "CRLinkageManagerInternal.h"

@interface CRLinkageBaseConfig()

@property (nonatomic, weak, readwrite) CRLinkageManagerInternal *linkageInternal;

@end

@implementation CRLinkageBaseConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentScrollView = nil;
        self.linkageInternal = nil;
        
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
            /// 向上滑，判断是否触发footer极限
            if (overFooterOrLimitBlock) {
                BOOL result = [self isScrollOverFooterLimit];
                overFooterOrLimitBlock(result);
            }
        } downBlock:^{
            /// 向下滑，判断是否触发header极限
            if (overHeaderOrLimitBlock) {
                BOOL result = [self isScrollOverHeaderLimit];
                if (result) {
                    NSLog(@"--1");
                }
                overHeaderOrLimitBlock(result);
            }
        }];
    } else {
        [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
            /// 向上滑，判断是否触发footer
            if (overFooterOrLimitBlock) {
                BOOL result = [self isScrollOverFooter];
                overFooterOrLimitBlock(result);
            }
        } downBlock:^{
            /// 向下滑，判断是否触发header
            if (overHeaderOrLimitBlock) {
                BOOL result = [self isScrollOverHeader];
                overHeaderOrLimitBlock(result);
            }
        }];
    }
}

#pragma mark - ConfigLinkageInternal
- (void)configLinkageInternalForMain:( CRLinkageManagerInternal *)linkageInternal {
    self.linkageInternal = linkageInternal;
}

- (void)configLinkageInternalForChild:( CRLinkageManagerInternal *)linkageInternal {
    self.linkageInternal = linkageInternal;
}

#pragma mark - Private
- (BOOL)_isScrollOverHeaderWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = 0 + limit;
    if (self.currentScrollView.contentOffset.y < bestContentOffSetY) {
        return YES;
    }
    return NO;
}
- (BOOL)_isScrollOverFooterWithLimit:(CGFloat)limit {
    CGFloat bestContentOffSetY = self.currentScrollView.contentSize.height - self.currentScrollView.frame.size.height + limit;
    if (self.currentScrollView.contentOffset.y > bestContentOffSetY) {
        return YES;
    }
    return NO;
}

#pragma mark - Setter & Getter
- (void)setHeaderBounceLimit:(NSNumber *)headerBounceLimit {
    if (headerBounceLimit) {
        int tmpIntValue = [headerBounceLimit intValue];
        if (tmpIntValue > 0) {
            headerBounceLimit = @(-tmpIntValue);
        }
    }
    _headerBounceLimit = headerBounceLimit;
}

@end
