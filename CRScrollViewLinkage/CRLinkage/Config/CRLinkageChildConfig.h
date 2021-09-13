//
//  CRLinkageConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "CRLinkageBaseConfig.h"
#import "CRLinkageDefine.h"


NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageChildConfig : CRLinkageBaseConfig

/**
 * 需要被监听frame的view
 * 默认：NearMain
 */
@property (nonatomic, assign) CRChildFrameObserveType frameObserveType;
/**
 * 需要被监听frame的view
 */
@property (nonatomic, weak, setter=configFrameObservedView:, nullable) UIView *_frameObservedView;
/**
 * 自定义需要被监听frame的view
 * frameObserveType为custom时生效
 */
@property (nonatomic, weak) UIView *customframeObservedView;

/// 头部/尾部固定预留高度
@property (nonatomic, assign) CGFloat childTopFixHeight;
@property (nonatomic, assign) CGFloat childBottomFixHeight;

/// 上拉/下拉回弹类型
@property (nonatomic, assign) CRBounceType headerBounceType;
@property (nonatomic, assign) CRBounceType footerBounceType;

/// 手势滑动类型
@property (nonatomic, assign) CRGestureType gestureType;


/// child固定类型（第一个child一定是top类型，最后一个child一定是bottom类型）
@property (nonatomic, assign) CRChildHoldPosition childHoldPosition;
/**
 * childHoldPosition为customRatio类型时生效。（0～1.0）
 * 默认：0.5，剧中
 * 0等同于childHoldPosition==Top
 * 1等同于childHoldPosition==Bottom
 * 数字越小越靠近顶部，反之靠近底部。
 */
@property (nonatomic, assign) CGFloat positionRatio;

/// 上一个scrollView（类似双向链表的结构）
@property (nonatomic, weak) UIScrollView *lastScrollView;
/// 下一个scrollView
@property (nonatomic, weak) UIScrollView *nextScrollView;

#warning Bear 这两个属性可能用不上了，最后检查下
// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;


#warning Bear 这里的建议弄成soft属性，在切换child时，可以清空。并且只能internal进行操作。
/**
 * 在mainScrollView中，contentOffSet滑动到该位置时，应该切换到child
 */
@property (nonatomic, assign) CGPoint bestMainAnchorOffset;
/// 计算出bestContentOffSet
- (void)caculateMainAnchorOffset;
- (void)configFrameObservedView:(UIView * _Nullable)frameObservedView;

#pragma mark - Triggered Limit
// config
- (void)configHaveTriggeredHeaderLimit;
- (void)configHaveTriggeredFooterLimit;
/// get
- (BOOL)_getHaveTriggeredFooterLimit;
- (BOOL)_getHaveTriggeredHeaderLimit;
/// reset
- (void)_resetTriggeredHeaderLimit;
- (void)_resetTriggeredFooterLimit;

@end

NS_ASSUME_NONNULL_END
