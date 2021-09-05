//
//  CRLinkageBaseConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
#import "CRLinkageTool.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageBaseConfig : NSObject

/// main专用
@property (nonatomic, weak, nullable) UIScrollView *currentScrollView;
@property (nonatomic, weak) CRLinkageManagerInternal *linkageInternal;

/// 头部/底部拉动极限
@property (nonatomic, strong, nullable) NSNumber *headerBounceLimit;
@property (nonatomic, strong, nullable) NSNumber *footerBounceLimit;

#pragma mark - Scroll Over Check
- (BOOL)isScrollOverHeader;
- (BOOL)isScrollOverHeaderLimit;
- (BOOL)isScrollOverFooter;
- (BOOL)isScrollOverFooterLimit;

- (void)processChildScrollDir:(CRScrollDir)scrollDir
                      isLimit:(BOOL)isLimit
       overHeaderOrLimitBlock:(void (^)(BOOL isOver))overHeaderOrLimitBlock
       overFooterOrLimitBlock:(void (^)(BOOL isOver))overFooterOrLimitBlock;
@end

NS_ASSUME_NONNULL_END
