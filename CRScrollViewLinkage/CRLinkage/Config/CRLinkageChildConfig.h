//
//  CRLinkageConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"


NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageChildConfig : NSObject

/// child专用
@property (nonatomic, assign) CGFloat childTopFixHeight;
@property (nonatomic, assign) CGFloat childBottomFixHeight;
@property (nonatomic, assign) CRBounceType headerBounceType;
@property (nonatomic, assign) CRBounceType footerBounceType;


/// 手势滑动类型
#warning Bear 这里用来表示main上的手势是否允许多个scrollView接收（可以参考原先的代码）
@property (nonatomic, assign) CRGestureType gestureType;


/// child固定类型（第一个child一定是top类型，最后一个child一定是bottom类型）
@property (nonatomic, assign) CRChildHoldPosition childHoldPosition;
/// childHoldPosition为customRatio类型时生效。（默认：0.5）
@property (nonatomic, assign) CGFloat positionRatio;

/// 当前scrollView
@property (nonatomic, weak) UIScrollView *currentScrollView;
/// 上一个scrollView（类似双向链表的结构）
@property (nonatomic, weak) UIScrollView *lastScrollView;
/// 下一个scrollView
@property (nonatomic, weak) UIScrollView *nextScrollView;

/**
 * 在mainScrollView中，contentOffSet滑动到该位置时，应该切换到child
 */
@property (nonatomic, assign) CGPoint bestContentOffSet;

// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

/// 计算出bestContentOffSet
- (void)caculateMainAnchorOffset:(UIScrollView *)mainScrollView;

@end

NS_ASSUME_NONNULL_END
