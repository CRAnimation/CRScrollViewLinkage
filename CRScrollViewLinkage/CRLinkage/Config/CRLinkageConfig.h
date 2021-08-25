//
//  CRLinkageConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
@class CRLinkageManager;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CRGestureForMainScrollView = 0,
    CRGestureForBothScrollView = 1,
} CRGestureType;

typedef enum : NSUInteger {
    /// 只允许mainScrollview上拉/下拉加载更多
    CRBounceForMain,
    /// 只允许childScrollview上拉/下拉加载更多
    CRBounceForChild,
}CRBounceType;

@interface CRLinkageConfig : NSObject

// main专用
@property (nonatomic, assign) CGFloat mainTopHeight;
@property (nonatomic, assign) CRGestureType mainGestureType;
@property (nonatomic, weak) CRLinkageManager *mainLinkageManager;


// child专用
@property (nonatomic, assign) CGFloat childHeight;

// main，child共用
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) CRBounceType headerBounceType;
@property (nonatomic, assign) CRBounceType footerBounceType;
//@property (nonatomic, assign) BOOL isCanScroll;
//@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
