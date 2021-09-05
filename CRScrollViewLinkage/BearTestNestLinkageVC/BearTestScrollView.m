//
//  BearTestScrollView.m
//  InterLock
//
//  Created by apple on 2021/3/11.
//

#import "BearTestScrollView.h"
#import "UIScrollView+CRLinkage.h"
#import "LBLinkageConfig.h"
#import "LBLinkageManager.h"

@interface BearTestScrollView() <UIGestureRecognizerDelegate>

@end

@implementation BearTestScrollView

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    NSLog(@"--success");
//    return YES;
//}
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
//        UIPanGestureRecognizer *tmpPanGesture = (UIPanGestureRecognizer *)gestureRecognizer;
//        UIScrollView *scrollView = (UIScrollView *)gestureRecognizer.view;
//        CGPoint velocity = [tmpPanGesture velocityInView:gestureRecognizer.view];
//        if ([scrollView.oldlinkageConfig.mainLinkageManager refreshType] == LKRefreshForChild) {
//            if (velocity.y > 0) {
//                /// 向下滑
//                if (self.contentOffset.y <= 0) {
//                    /// main到顶了，不接收该手势，让child接收。
//                    /// （不这么写的话，child的gestureRecognizerShouldBegin不会被触发。在mian到顶的情况下，停止一会。无法对child直接下拉刷新。）
//                    return NO;
//                }
//            } else if (velocity.y < 0) {
//                /// 向上滑
//            } else {
//                /// nil
//            }
//        }
//        NSLog(@"velocityInView-- %@", NSStringFromCGPoint(velocity));
//    }
//    NSLog(@"--0 Main Scroll ShouldBegin");
//    return YES;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    NSLog(@"--001 Main Scroll Simultaneously");
//    return YES;
//}

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    NSLog(@"sel--%@", NSStringFromSelector(sel));
//    if (sel == @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)) {
//        NSLog(@"--kkkkkkkkkkk");
//    }
////    NSLog(@"--sel:%@", NSStringFromSelector(sel));
//    return [super resolveInstanceMethod:sel];
//}
//
//+ (BOOL)resolveClassMethod:(SEL)sel {
//    if (sel == @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)) {
//        NSLog(@"--22222222");
//    }
//    return [super resolveClassMethod:sel];
//}

@end
