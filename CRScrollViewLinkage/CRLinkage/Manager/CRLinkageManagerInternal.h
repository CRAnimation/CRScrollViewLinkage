//
//  CRLinkageManagerInternal.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import <UIKit/UIKit.h>
#import "CRLinkageChildConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRLinkageManagerInternalDelegate <NSObject>

/// 联动器需要扭转状态
- (void)linkageNeedRelayStatus:(CRLinkageRelayStatus)linkageRelayStatus;

@end

@interface CRLinkageManagerInternal : NSObject

@property (nonatomic, weak) id <CRLinkageManagerInternalDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *mainScrollView;
@property (nonatomic, strong, readonly) UIScrollView *childScrollView;
/**
 * 自定义滑动时，头部允许滑动的范围高度
 * 默认：nil，此时会自动根据childScrollView计算。
 * 如果手动赋值，则不会自动根据childScrollView计算。
 */
@property (nonatomic, strong) NSNumber * __nullable customTopHeight;

/// 配置mainScrollView
/// @param mainScrollView mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView;

/// 配置child（默认使用childScrollView的高度）
/// 可以根据场景多次调用，修改当前相应的child
/// @param childScrollView childScrollView
- (void)configChildScrollView:(UIScrollView *)childScrollView;

/// 配置child
/// 可以根据场景多次调用，修改当前相应的child
/// @param childScrollView childScrollView
/// @param childViewHeight 指定Child的高度（因为可能childScroll会放在其他容器中，这时需要使用容器高度，尽量保证每次都一样。）
- (void)configChildScrollView:(UIScrollView *)childScrollView childViewHeight:(CGFloat)childViewHeight;

@end

NS_ASSUME_NONNULL_END
