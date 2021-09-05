//
//  CRLinkageManagerInternal.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import <UIKit/UIKit.h>
#import "CRLinkageChildConfig.h"
#import "CRLinkageMainConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRLinkageManagerInternalDelegate <NSObject>

/// 联动器需要扭转状态
- (void)linkageNeedRelayStatus:(CRLinkageRelayStatus)linkageRelayStatus;
/// scrollView触发拉动极限
- (void)scrollViewTriggerLimitWithScrollView:(UIScrollView *)scrollView
                              scrollViewType:(CRScrollViewType)scrollViewType
                           bouncePostionType:(CRBouncePostionType)bouncePostionType;

@end

@interface CRLinkageManagerInternal : NSObject

@property (nonatomic, weak) id <CRLinkageManagerInternalDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *mainScrollView;
@property (nonatomic, strong, readonly) UIScrollView *childScrollView;
@property (nonatomic, assign) CRLinkageScrollStatus linkageScrollStatus;
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

#pragma mark - Tool Method
/// 判断方向
- (CRScrollDir)_checkDirByOldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset;
#pragma mark Hold
- (void)mainHold;
- (void)mainHoldNeedRelax:(BOOL)needRelax;
- (void)childHold;
- (void)childHoldNeedRelax:(BOOL)needRelax;

- (CRLinkageMainConfig *)mainConfig;
- (CRLinkageChildConfig *)childConfig;
- (CRBounceType)headerBounceType;
- (CRBounceType)footerBounceType;
#warning Bear 这里后面查一下是不是功能和已有方法重复了
- (BOOL)checkScrollViewIsTopBottom:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
