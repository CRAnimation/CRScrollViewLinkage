//
//  CRLinkageMainConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
#import "CRLinkageChildConfig.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageMainConfig : NSObject

/// main专用
@property (nonatomic, weak) UIScrollView *mainScrollView;
@property (nonatomic, weak, readonly) CRLinkageChildConfig *currentChildConfig;
@property (nonatomic, weak, readonly) UIScrollView *currentChildScrollView;
@property (nonatomic, weak) CRLinkageManagerInternal *mainLinkageInternal;

/// 头部/底部拉动极限
@property (nonatomic, strong) NSNumber *headerBounceLimit;
@property (nonatomic, strong) NSNumber *footerBounceLimit;

/// 头部允许下拉到负一楼
@property (nonatomic, assign) BOOL headerAllowToFirstFloor;
/// 底部允许上拉到阁楼
@property (nonatomic, assign) BOOL footerAllowToLoft;

// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

#pragma mark - Scroll Over Check
- (BOOL)isScrollOverHeader;
- (BOOL)isScrollOverHeaderLimit;
- (BOOL)isScrollOverFooter;
- (BOOL)isScrollOverFooterLimit;

@end

NS_ASSUME_NONNULL_END
