//
//  CRLinkageDefine.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageDefine : NSObject

#pragma mark - CRGestureType
typedef enum : NSUInteger {
    CRGestureForMainScrollView = 0,
    CRGestureForBothScrollView = 1,
} CRGestureType;


#pragma mark - CRBounceType
typedef enum : NSUInteger {
    /// 只允许mainScrollview上拉/下拉加载更多
    CRBounceForMain,
    /// 只允许childScrollview上拉/下拉加载更多
    CRBounceForChild,
} CRBounceType;


#pragma mark - CRScrollDir
typedef enum : NSUInteger {
    // 不变
    CRScrollDir_Hold,
    // 向上滑
    CRScrollDir_Up,
    // 向下滑
    CRScrollDir_Down,
} CRScrollDir;


#pragma mark - CRLinkageScrollStatus
typedef enum : NSUInteger {
    CRLinkageScrollStatus_Idle = 0,
    
    // default: main可以滑动，child不能滑
    //
    // InMain
    // main.canscroll = YES; value=0;
    // child.canscroll = NO; hold=0;
    // next = mainScroll;
    // main.canscroll = YES;
    // child.canscroll = NO; hold=0;
//    CRLinkageScrollStatus_MainDefault,
    
    // mainScroll: main可以滑动，child不能滑
    //
    // InMain
    // 1,区域内可滑:（0<=value<mainOffsetY）
    //  nil
    // 2,继续上滑，滑到顶了，child即将允许滑动：(value>=mainOffsetY)
    //  next = childScroll
    //  main.canscroll = NO; hold=mainOffsetY;
    //  child.canscroll = YES;
    // 3,还在下拉，两个scrollView都拉到顶了，判断谁能刷新:(value<0)
    //  根据条件判断
    //  3.1,next=mainRefresh
    //      main.canscroll = YES;
    //      child.canscroll = NO; hold=0;
    //  3.2,next=childRefresh
    //      main.canscroll = NO; hold=0;
    //      child.canscroll = YES;
    CRLinkageScrollStatus_MainScroll,
    
    // childScroll: main不能滑，child可以滑动
    //
    // InChild
    // 1,区域内可滑:（value>=0）
    //  nil
    // 2,拉到头了，切换为main滑动:(value<0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    CRLinkageScrollStatus_ChildScroll,
    
    // mainRefresh: main可以滑动，child不能滑
    //
    // InMain
    // 1,区域内可滑:（value<0）
    // nil
    // 2,又开始往上滑了:(value>=0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    CRLinkageScrollStatus_MainRefresh,
    
    // childRefresh: main不能滑，child可以滑动
    //
    // InChild
    // 1,区域内可滑:（value<0）
    // nil
    // 2,又开始往上滑了:(value>=0)
    //  next = mainScroll;
    //  main.canscroll = YES;
    //  child.canscroll = NO; hold=0;
    CRLinkageScrollStatus_ChildRefresh,
} CRLinkageScrollStatus;

@end

NS_ASSUME_NONNULL_END
