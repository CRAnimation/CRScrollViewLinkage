//
//  CRLinkageMainConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageMainConfig : NSObject

/// main专用
@property (nonatomic, weak) UIScrollView *mainScrollView;
@property (nonatomic, assign) CRGestureType mainGestureType;
@property (nonatomic, weak) CRLinkageManagerInternal *mainLinkageInternal;

/// 头部/底部拉动极限
@property (nonatomic, strong, nullable) NSNumber *headerBounceLimit;
@property (nonatomic, strong, nullable) NSNumber *footerBounceLimit;

// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
