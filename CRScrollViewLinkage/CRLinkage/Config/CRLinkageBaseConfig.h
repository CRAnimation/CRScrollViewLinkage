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
@property (nonatomic, weak, readonly) CRLinkageManagerInternal *linkageInternal;

/// 头部拉动极限（填入正数即可，里面会自动转成负数）
@property (nonatomic, strong, nullable) NSNumber *headerBounceLimit;
/// 底部拉动极限（填入正数）
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

#pragma mark - ConfigLinkageInternal
- (void)configLinkageInternalForMain:( CRLinkageManagerInternal *)linkageInternal;
- (void)configLinkageInternalForChild:( CRLinkageManagerInternal *)linkageInternal;

@end

NS_ASSUME_NONNULL_END
