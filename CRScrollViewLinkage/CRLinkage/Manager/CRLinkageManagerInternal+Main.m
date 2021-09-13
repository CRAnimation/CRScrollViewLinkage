//
//  CRLinkageManagerInternal+Main.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageManagerInternal+Main.h"
#import "CRLinkageTool.h"

@implementation CRLinkageManagerInternal (Main)

#pragma mark ProcessMainScroll
- (void)_processMain:(UIScrollView *)mainScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
    CGFloat bestOffSetY = self.childConfig.bestMainAnchorOffset.y;
    CGFloat mainOffSetY = mainScrollView.contentOffset.y;
    CGFloat childOffSetY = self.childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
        
        case CRLinkageScrollStatus_Idle:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_Idle"];
            [self mainHold];
        }
            break;
            
#pragma mark 处理main滑动
        case CRLinkageScrollStatus_MainScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainScroll"];
            [self _processMainScrollWithMainScrollView:mainScrollView oldOffset:oldOffset newOffset:newOffset];
        }
            break;
        case CRLinkageScrollStatus_ChildScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildScroll"];
            // childScroll: main不能滑，child可以滑动
            [self mainHold];
        }
            break;
        case CRLinkageScrollStatus_MainRefresh:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainRefresh"];
            if (mainOffSetY < bestOffSetY) {
                // 这个区域，mainRefresh: main可以滑动，child不能滑
                nil;
            } else {
                // 又开始往上滑了
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
        }
            break;
        case CRLinkageScrollStatus_MainRefreshToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainRefreshToLimit"];
            /// 下拉刷新到极限
            if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [self.delegate scrollViewTriggerLimitWithScrollView:self.mainScrollView
                                                     scrollViewType:CRScrollViewType_Main
                                                  bouncePostionType:CRBouncePositionOverHeaderLimit];
            }
            
            /// 头部允许下拉到负一楼
            if (self.mainConfig.headerAllowToFirstFloor) {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainHoldOnFirstFloor;
                [self autoScrollToFirstFloor];
            }
            /// 头部不允许下拉到负一楼
            else {
                /// 状态重置到初始状态
                self.linkageScrollStatus = CRLinkageScrollStatus_Idle;
            }
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnFirstFloor:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainHoldOnFirstFloor"];
            [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
#warning Bear 这里要结合child一起处理
            } downBlock:^{
                /// 下拉不再处理。固定在这个位置
                [self mainHold];
            }];
        }
            break;
        case CRLinkageScrollStatus_MainLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainLoadMore"];
            if (mainOffSetY < bestOffSetY) {
                // 这个区域，mainRefresh: main可以滑动，child不能滑
                nil;
            } else {
                // 又开始往上滑了
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
        }
            break;
        case CRLinkageScrollStatus_MainLoadMoreToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainLoadMoreToLimit"];
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnLoft:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_MainHoldOnLoft"];
        }
            break;
        case CRLinkageScrollStatus_ChildRefresh:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildRefresh"];
            
#warning Bear 这里临时解决那种特殊的问题。
            if (childOffSetY == 0) {
                [self.childScrollView setContentOffset:CGPointMake(0, 1) animated:NO];
            }
#warning Bear 这里后面检查下有没有问题
            BOOL status1 = self.childConfig.gestureType == CRGestureType_Main && childOffSetY == 0;
            BOOL status2 = [self.childConfig _getHaveTriggeredHeaderLimit];
            if (status1 || status2) {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            } else {
                [self mainHold];
            }
        }
            break;
        case CRLinkageScrollStatus_ChildLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildLoadMore"];
        }
            break;
    }
}

#pragma mark ProcessMainScroll Detail
- (void)_processMainScrollWithMainScrollView:(UIScrollView *)mainScrollView
                                   oldOffset:(CGFloat)oldOffset
                                   newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
    CGFloat bestOffSetY = self.childConfig.bestMainAnchorOffset.y;
    CGFloat currentOffSetY = mainScrollView.contentOffset.y;
    [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
        /// 往上滑
        
        /// 当前offset超过预期
        if (currentOffSetY >= bestOffSetY) {
            switch (self.childConfig.gestureType) {
                case CRGestureType_Main: {
                    // 只滑了main的私有区域，即使到顶了，也不能切换为childScroll。
                    // 继续保持为mainScroll
                    
                    nil;
                } break;
                case CRGestureType_BothScrollView:
                {
                    // 切换为child滑动
                    self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                } break;
            }
        } else {
            // 继续保持为mainScroll
            nil;
        }
        
#warning Bear 这里到时候记得补一下类似这样的逻辑（参考下面的即可）
//        if (self.childConfig._haveTriggeredHeaderLimit == YES) {
//            /// 已经触发了childConfig的haveTriggered的配置，则让main正常处理
//            nil;
//        }
        
    } downBlock:^{
        /// 往下滑
        
        if (currentOffSetY <= bestOffSetY) {
            switch (self.childConfig.gestureType) {
                case CRGestureType_Main: {
                    /// 只滑了main的私有区域，即使到底了，也不能切换为childScroll。
                    if (self.mainConfig.footerBounceLimit && newOffset > -self.mainConfig.footerBounceLimit.floatValue) {
                        /// 超过极限了
                        self.linkageScrollStatus = CRLinkageScrollStatus_MainRefreshToLimit;
                    } else {
                        /// 继续保持为mainScroll
                        nil;
                    }
                    nil;
                } break;
                case CRGestureType_BothScrollView:
                {
                    /// 两个scrollView都可以滑动
                    switch (self.childConfig.headerBounceType) {
                        /// child不允许下拉刷新
                        case CRBounceType_Main:
                        {
                            /// 不做处理，main继续滑动
                            nil;
                        }
                            break;
                            
                        /// child允许下拉刷新
                        case CRBounceType_Child:
                        {
                            if ([self.childConfig _getHaveTriggeredHeaderLimit]) {
                                /// 已经触发了childConfig的haveTriggered的配置，则让main正常处理
                                nil;
                            } else {
                                /// 切换为child滑动
                                self.linkageScrollStatus = CRLinkageScrollStatus_ChildRefresh;
                            }
                        }
                            break;
                    }
                } break;
            }
        } else {
            // 继续保持为mainScroll
            nil;
        }
    }];
}

#pragma mark 自动滑到负1楼
/// main下拉超过极限，自动滑到负1楼
- (void)autoScrollToLoft {
    CGFloat bestMainOffSetY = 0 - CGRectGetHeight(self.mainScrollView.frame);
    [self autoScrollToContentOffSetY:bestMainOffSetY];
}

#pragma mark 自动滑到阁楼
/// main上拉超过极限，自动滑到阁楼
- (void)autoScrollToFirstFloor {
    CGFloat bestMainOffSetY = self.mainScrollView.contentSize.height;
    [self autoScrollToContentOffSetY:bestMainOffSetY];
    if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
        [self.delegate scrollViewTriggerLimitWithScrollView:self.mainScrollView
                                             scrollViewType:CRScrollViewType_Main
                                          bouncePostionType:CRBouncePositionOverHeaderLimit];
    }
}

- (void)autoScrollToContentOffSetY:(CGFloat)contentOffSetY {
    CGFloat bestMainOffSetY = contentOffSetY;
    CGFloat currentMainOffSetY = self.mainScrollView.contentOffset.y;
    if (currentMainOffSetY != bestMainOffSetY) {
        CGPoint tmpContentOffSet = self.mainScrollView.contentOffset;
        tmpContentOffSet.y = bestMainOffSetY;
        [self.mainScrollView setContentOffset:tmpContentOffSet animated:YES];
    }
}

#pragma mark Hold
- (void)mainHold {
    [CRLinkageTool holdScrollView:self.mainScrollView offSet:self.childConfig.bestMainAnchorOffset];
}

@end
