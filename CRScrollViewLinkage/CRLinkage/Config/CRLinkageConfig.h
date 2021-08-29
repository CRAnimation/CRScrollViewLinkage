//
//  CRLinkageConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageConfig : NSObject

/// main专用
@property (nonatomic, assign) CRGestureType mainGestureType;
@property (nonatomic, weak) CRLinkageManagerInternal *mainLinkageInternal;

/// child专用
@property (nonatomic, assign) CGFloat childTopFixHeight;
@property (nonatomic, assign) CGFloat childBottomFixHeight;
@property (nonatomic, assign) CRBounceType headerBounceType;
@property (nonatomic, assign) CRBounceType footerBounceType;
/// child固定类型（第一个child一定是top类型，最后一个child一定是bottom类型）
@property (nonatomic, assign) CRChildHoldPosition childHoldPosition;
/// childHoldPosition为customRatio类型时生效。（默认：0.5）
@property (nonatomic, assign) CGFloat positionRatio;
/// 上一个scrollView（类似双向链表的结构）
@property (nonatomic, weak) UIScrollView *lastScrollView;
/// 下一个scrollView
@property (nonatomic, weak) UIScrollView *nextScrollView;

// main，child共用
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
