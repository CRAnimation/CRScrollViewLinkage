//
//  LBLinkageManager.h
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIScrollView+LBLinkage.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    /// 只允许mainScrollview刷新
    LKRefreshForMain,
    /// 只允许childScrollview刷新
    LKRefreshForChild,
}LKRefreshType;

typedef enum : NSUInteger {
    /// 只允许mainScrollview上拉加载更多
    LKLoadMoreForMain,
    /// 只允许childScrollview上拉加载更多
    LKLoadMoreForChild,
}LKLoadMoreType;

@interface LBLinkageManager : NSObject

@property (nonatomic, strong, readonly) UIScrollView *mainScrollView;
@property (nonatomic, strong, readonly) UIScrollView *childScrollView;
/// 下拉刷新谁来触发（main/child）
@property (nonatomic, assign) LKRefreshType refreshType;
/// 上拉加载更多谁来触发（main/child）
@property (nonatomic, assign) LKLoadMoreType loadMoreType;
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

/**
 注意：
 # 该manager对mainScroll，childScroll都是weak持有！
 # 并且对于mainScroll会自动生成linkage_mainScroll中间类，并hook对应的手势代理方法。（类似于KVO原理）
 # 所以并不会对原生scrollView和自定义scrollView造成入侵。
 
 用法：
 // 配置联动-main（一般只调用一次）
 [[StockDetailRankManager sharedInstance].linkageManager configMainScrollView:self.mainScrollView];
 // 配置联动-child（可多次调用）
 [[StockDetailRankManager sharedInstance].linkageManager configChildScrollView:controller.panTableView childViewHeight:self.view.frame.size.height];
 */

NS_ASSUME_NONNULL_END
