//
//  CRLinkageManagerInternal.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import <UIKit/UIKit.h>
#import "CRLinkageChildConfig.h"
#import "CRLinkageMainConfig.h"
#import "UIScrollView+CRLinkage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRLinkageManagerInternalDelegate <NSObject>

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
@property (nonatomic, assign) BOOL internalActive;

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

#pragma mark - Tool Method
/// 判断方向
- (CRScrollDir)_checkDirByOldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset;

- (CRLinkageMainConfig *)mainConfig;
- (CRLinkageChildConfig *)childConfig;
- (CRBounceType)headerBounceType;
- (CRBounceType)footerBounceType;
#warning Bear 这里后面查一下是不是功能和已有方法重复了
- (BOOL)checkScrollViewIsTopBottom:(UIScrollView *)scrollView;

#pragma mark Last Hold Point
- (void)setLastMainHoldPoint:(CGPoint)lastMainHoldPoint;
- (void)setLastChildHoldPoint:(CGPoint)lastChildHoldPoint;
- (BOOL)checkEqualLastMainHoldPoint:(CGPoint)lastPoint;
- (BOOL)checkEqualLastChildHoldPoint:(CGPoint)lastPoint;

@end

NS_ASSUME_NONNULL_END
