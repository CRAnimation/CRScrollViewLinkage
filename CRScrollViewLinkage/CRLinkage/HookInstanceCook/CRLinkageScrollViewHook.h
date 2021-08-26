//
//  LBLinkageHookMethods.h
//  InterLock
//
//  Created by apple on 2021/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 该协议用于规范runtime生成的类，添加这些方法
@protocol CRLinkageRuntimeMethodProtocol <NSObject>

@optional
/// 判断手势点击的是否在2个view的交集区
- (BOOL)gestureIsInBothArea:(UIGestureRecognizer *)gestureRecognizer;

/// 用于判断手势是否需要处理
- (BOOL)linkageCheckGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

/// 手动调用父类方法
- (BOOL)manualCallSuperWithSel:(SEL)sel defaultReturn:(BOOL)defaultReturn paras:(NSArray *)paras;

@end

@interface CRLinkageScrollViewHook : UIScrollView

@end

NS_ASSUME_NONNULL_END
