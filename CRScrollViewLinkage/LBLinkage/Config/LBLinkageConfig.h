//
//  LBLinkageConfig.h
//  InterLock
//
//  Created by apple on 2021/3/11.
//

#import <UIKit/UIKit.h>
@class LBLinkageManager;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LKGestureForMainScrollView = 0,
    LKGestureForBothScrollView = 1,
} LKMainGestureType;

@interface LBLinkageConfig : NSObject

// main专用
@property (nonatomic, assign) CGFloat mainTopHeight;
@property (nonatomic, assign) LKMainGestureType mainGestureType;
@property (nonatomic, weak) LBLinkageManager *mainLinkageManager;


// child专用
@property (nonatomic, assign) CGFloat childHeight;

// main，child共用
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
