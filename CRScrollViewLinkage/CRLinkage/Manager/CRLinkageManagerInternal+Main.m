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
    CGFloat bestOffSetY = self.childConfig.bestContentOffSet.y;
    CGFloat mainOffSetY = mainScrollView.contentOffset.y;
    CGFloat childOffSetY = self.childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
        
        case CRLinkageScrollStatus_Idle:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_Idle"];
            [self mainHold];
        }
            break;
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
            [self mainHoldNeedRelax:YES];
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
                                                     scrollViewType:CRScrollViewForMain
                                                  bouncePostionType:CRBouncePositionToHeaderLimit];
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
            switch (scrollDir) {
                case CRScrollDir_Hold: { nil; } break;
                case CRScrollDir_Up:
                {
#warning Bear 这里要结合child一起处理
                }
                    break;
                case CRScrollDir_Down:
                {
                    /// 下拉不再处理。固定在这个位置
                    [self mainHold];
                }
                    break;
            }
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
            if (self.childConfig.gestureType == CRGestureForMainScrollView && childOffSetY == 0) {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            } else {
                [self mainHold];
            }
        }
            break;
        case CRLinkageScrollStatus_ChildRefreshToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildRefreshToLimit"];
        }
            break;
        case CRLinkageScrollStatus_ChildLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildLoadMore"];
        }
            break;
        case CRLinkageScrollStatus_ChildLoadMoreToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:YES log:@"CRLinkageScrollStatus_ChildLoadMoreToLimit"];
        }
            break;
    }
}

#pragma mark ProcessMainScroll Detail
- (void)_processMainScrollWithMainScrollView:(UIScrollView *)mainScrollView
                                   oldOffset:(CGFloat)oldOffset
                                   newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
    CGFloat bestOffSetY = self.childConfig.bestContentOffSet.y;
    CGFloat currentOffSetY = mainScrollView.contentOffset.y;
    BOOL isScrollToChild = NO;
    switch (scrollDir) {
        case CRScrollDir_Hold: { nil; } break;
            
        /// 往上滑
        case CRScrollDir_Up: {
            if (currentOffSetY >= bestOffSetY) {
                isScrollToChild = YES;
                switch (self.childConfig.gestureType) {
                    case CRGestureForMainScrollView: {
                        // 只滑了main的私有区域，即使到顶了，也不能切换为childScroll。
                        // 继续保持为mainScroll
                        
                        nil;
                    } break;
                    case CRGestureForBothScrollView:
                    {
                        // 切换为child滑动
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                    } break;
                }
            } else {
                // 继续保持为mainScroll
                nil;
            }
        }
            break;
            
        /// 往下滑
        case CRScrollDir_Down: {
            if (currentOffSetY <= bestOffSetY) {
                isScrollToChild = YES;
                switch (self.childConfig.gestureType) {
                    case CRGestureForMainScrollView: {
                        // 只滑了main的私有区域，即使到底了，也不能切换为childScroll。
                        if (self.mainConfig.footerBounceLimit && newOffset > -self.mainConfig.footerBounceLimit.floatValue) {
                            // 超过极限了
                            self.linkageScrollStatus = CRLinkageScrollStatus_MainRefreshToLimit;
                        } else {
                            // 继续保持为mainScroll
                            nil;
                        }
                        nil;
                    } break;
                    case CRGestureForBothScrollView:
                    {
                        // 切换为child滑动
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                    } break;
                }
            } else {
                // 继续保持为mainScroll
                nil;
            }
        }
            break;
    }
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
                                             scrollViewType:CRScrollViewForMain
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

@end
