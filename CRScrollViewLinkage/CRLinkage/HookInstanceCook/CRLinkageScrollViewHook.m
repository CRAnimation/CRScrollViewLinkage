//
//  LBLinkageHookMethods.m
//  InterLock
//
//  Created by apple on 2021/3/12.
//

#import "CRLinkageScrollViewHook.h"
#import <objc/message.h>
#import "LBLinkageConfig.h"
#import "UIScrollView+LBLinkage.h"
#import "LBLinkageManager.h"

@interface CRLinkageScrollViewHook() <UIGestureRecognizerDelegate, CRLinkageRuntimeMethodProtocol>

@end

@implementation CRLinkageScrollViewHook

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL resVal = [self gestureIsInBothArea:gestureRecognizer];
    if (!resVal) {
        return YES;
    }
    
    SEL originSel = @selector(gestureRecognizerShouldBegin:);
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        UIPanGestureRecognizer *tmpPanGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        UIScrollView *scrollView = (UIScrollView *)gestureRecognizer.view;
        CGPoint velocity = [tmpPanGesture velocityInView:gestureRecognizer.view];
        if ([scrollView.oldlinkageConfig.mainLinkageManager refreshType] == LKRefreshForChild) {
            if (velocity.y > 0) {
                /// 向下滑
                if (self.contentOffset.y <= 0) {
                    /// main到顶了，不接收该手势，让child接收。
                    /// （不这么写的话，child的gestureRecognizerShouldBegin不会被触发。在mian到顶的情况下，停止一会。无法对child直接下拉刷新。）
                    return NO;
                }
            } else if (velocity.y < 0) {
                /// 向上滑
            } else {
                /// nil
            }
        }
//        NSLog(@"velocityInView-- %@", NSStringFromCGPoint(velocity));
    }
//    NSLog(@"--0 Main Scroll ShouldBegin");
    return [self manualCallSuperWithSel:originSel defaultReturn:YES paras:@[gestureRecognizer]];
}

/// 实现的核心方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    NSLog(@"--0 Main Scroll Simultaneously");
    SEL originSel = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]
        && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *mainScrollView = (UIScrollView *)gestureRecognizer.view;
        LBLinkageConfig *mainConfig = mainScrollView.oldlinkageConfig;
        
        UIScrollView *childScrollView = (UIScrollView *)otherGestureRecognizer.view;
        
        if (mainConfig.isMain && mainConfig.mainLinkageManager.childScrollView == childScrollView) {

            BOOL mainIsPan = [self linkageCheckGestureRecognizer:gestureRecognizer];
            BOOL otherIsPan = [self linkageCheckGestureRecognizer:otherGestureRecognizer];
            if (!mainIsPan || !otherIsPan) {
                return [self manualCallSuperWithSel:originSel defaultReturn:NO paras:@[gestureRecognizer, otherGestureRecognizer]];
            }

            BOOL resVal = [self gestureIsInBothArea:gestureRecognizer];
            if (resVal) {
                mainScrollView.oldlinkageConfig.mainGestureType = LKGestureForBothScrollView;
            } else {
                mainScrollView.oldlinkageConfig.mainGestureType = LKGestureForMainScrollView;
            }
            
            return resVal;
        }
    }

    return [self manualCallSuperWithSel:originSel defaultReturn:NO paras:@[gestureRecognizer, otherGestureRecognizer]];
}

#pragma mark - LBLinkageRuntimeMethodProtocol

/// 判断手势点击的是否在2个view的交集区
- (BOOL)gestureIsInBothArea:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)gestureRecognizer.view;
        CGFloat offsetY = scrollView.oldlinkageConfig.mainTopHeight;
        CGSize contentSize = scrollView.contentSize;
        CGRect targetRect = CGRectMake(0,
                                       offsetY,
                                       contentSize.width,
                                       contentSize.height - offsetY);
        CGPoint currentPoint = [gestureRecognizer locationInView:self];
        BOOL resVal = CGRectContainsPoint(targetRect, currentPoint);
        //        NSLog(@"--resVal:%@", resVal ? @"YES" : @"NO");
        return resVal;
    }
    return NO;
}

/// 用于判断手势是否需要处理
- (BOOL)linkageCheckGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    BOOL res = [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]
    || [gestureRecognizer isKindOfClass:NSClassFromString(@"UILongPressGestureRecognizer")]
    || [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
    return res;
}

/// 手动调用父类方法
- (BOOL)manualCallSuperWithSel:(SEL)sel defaultReturn:(BOOL)defaultReturn paras:(NSArray *)paras {

    Class cls = object_getClass(self);
    // 消除KVO影响
    while ([NSStringFromClass(cls) hasPrefix:@"NSKVONotifying_"]) {
        cls = class_getSuperclass(cls);
    }
    // 调用父类该方法，如果父类没有实现
    Class superCls = class_getSuperclass(cls);
    // 父类没有实现shouldRecognizeSimultaneouslyWithGestureRecognizer，默认返回NO，和系统保持一致
    // 一般runtime生成的类会自动添加，但不会添加到原生scrollView上。
    // 注意：这里要用instancesRespondToSelector来排查，因为可能原生scrollView有这个方法名，但是没有实现。
    // 用respondToSelector无法判断出来
    BOOL superHaveSel = [superCls instancesRespondToSelector:sel];
    if (!superHaveSel) {
        // 默认返回，和系统默认保持一致
        return defaultReturn;
    }
    
    struct objc_super obj_super_class = {
        .receiver = self,
        .super_class = superCls
    };

    BOOL res = defaultReturn;
    if (paras.count == 1) {
        int (*superMethod)(void *, SEL, id para1) = (void *)objc_msgSendSuper;
        res = superMethod(&obj_super_class, sel, paras[0]);
    } else if (paras.count == 2) {
        int (*superMethod)(void *, SEL, id para1, id para2) = (void *)objc_msgSendSuper;
        res = superMethod(&obj_super_class, sel, paras[0], paras[1]);
    }
    return res;
}

@end