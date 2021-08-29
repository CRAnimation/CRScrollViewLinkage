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

#pragma mark - CRLinkageRelayStatus
typedef enum : NSUInteger {
    // 仍然是当前ScrollView
    CRLinkageRelayStatus_RemainCurrent,
    // 扭转给上方的scrollView
    CRLinkageRelayStatus_ToLastScrollView,
    // 扭转给下方的scrollView
    CRLinkageRelayStatus_ToNextScrollView,
} CRLinkageRelayStatus;

#pragma mark - CRLinkageScrollStatus
/**
 * main下拉到顶：main.contentOffSet <= child.minY - child.topFixHeight
 * main上拉到底：main.contentOffSet >=  child.maxY + child.bottomHeight - main.height
 * main真的到顶了：main.contentOffSet <= 0;
 * main真的到底了：main.contentOffSet >= main.contentSize-main.height;
 */
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
    
    /**
     * mainScroll: main可以滑动，child不能滑
     * InMain
     *  1,区域内可滑
     *      nil
     *  2,下拉/上拉
     *      2.1,main下拉到顶，并且有合适child，child即将允许滑动
     *          next = childScroll
     *          main.canscroll = NO; hold=mainOffsetY;
     *          child.canscroll = YES;
     *      2.2,child还在下拉，两个scrollView都拉到顶了，判断谁能刷新:(value<0)
     *          根据条件判断
     *          2.2.1main真的到顶了
     *              2.2.1.1,main下拉刷新
     *                  next=mainRefresh
     *                  main.canscroll = YES;
     *                  child.canscroll = NO; hold=0;
     *                  2.2.1.1.1main下拉到极限
     *                      next=mainRefreshToLimit
     *                      再根据条件判断是到-1楼，还是做自定义操作
     *              2.2.1.2,child下拉刷新
     *                  next=childRefresh
     *                  main.canscroll = NO; hold=0;
     *                  child.canscroll = YES;
     *                  2.2.1.2.2child下拉到极限
     *                      等同于（2.2.1.1.1main下拉到极限）
     *          2.2.2main上面还有空间
     *              next=mainScroll
     *              main.canscroll = YES;
     *              child.canscroll = NO; hold=0;
     *              (考虑交接给lastScrollView)
     */
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
    // main下拉滑到极限了
    CRLinkageScrollStatus_MainRefreshToLimit,///
    // main下拉停留在负1楼
    CRLinkageScrollStatus_MainHoldOnFirstFloor,///
    
    // main上拉
    CRLinkageScrollStatus_MainLoadMore,
    // main上拉到极限了
    CRLinkageScrollStatus_MainLoadMoreToLimit,
    // main上拉停留在阁楼了
    CRLinkageScrollStatus_MainHoldOnLoft,///
    
    
    
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
    // child下拉滑到极限了
    CRLinkageScrollStatus_ChildRefreshToLimit,
    
    // child上拉
    CRLinkageScrollStatus_ChildLoadMore,
    // child上拉到极限了
    CRLinkageScrollStatus_ChildLoadMoreToLimit,
} CRLinkageScrollStatus;

@end

NS_ASSUME_NONNULL_END
