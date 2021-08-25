//
//  CRLinkageManager.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    /// 只允许mainScrollview刷新
    LKRefreshForMain,
    /// 只允许childScrollview刷新
    LKRefreshForChild,
}CRRefreshType;

@interface CRLinkageManager : NSObject

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) NSPointerArray *childScrollViews;



@end

NS_ASSUME_NONNULL_END
