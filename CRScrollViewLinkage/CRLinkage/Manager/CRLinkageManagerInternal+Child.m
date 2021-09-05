//
//  CRLinkageManagerInternal+Child.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageManagerInternal+Child.h"
#import "CRLinkageTool.h"

@implementation CRLinkageManagerInternal (Child)

- (void)_processChild:(UIScrollView *)childScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset {
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
//    CGFloat currentOffSetY = childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
        case CRLinkageScrollStatus_Idle:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_Idle"];
            [self childHold];
        }
            break;
            
        case CRLinkageScrollStatus_MainScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainScroll"];
            [self childHold];
        }
            break;
            
#pragma mark 处理child滑动
        case CRLinkageScrollStatus_ChildScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildScroll"];
            [self.childConfig processChildScrollDir:scrollDir isLimit:NO overHeaderOrLimitBlock:^(BOOL isOver) {
                if (isOver) {
                    // 拉过头了，切换为main滑动
                    self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
                } else {
                    // 区域内可滑
                    nil;
                }
            } overFooterOrLimitBlock:^(BOOL isOver) {
                if (isOver) {
                    // 拉过头了，切换为main滑动
                    self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
                } else {
                    // 区域内可滑
                    nil;
                }
            }];
        }
            break;
        case CRLinkageScrollStatus_MainRefresh:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainRefresh"];
            [self childHold];
        }
            break;
        case CRLinkageScrollStatus_MainRefreshToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainRefreshToLimit"];
            [self childHold];
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnFirstFloor:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainHoldOnFirstFloor"];
            [self childHold];
        }
            break;
        case CRLinkageScrollStatus_MainLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainLoadMore"];
            [self childHold];
        }
            break;
        case CRLinkageScrollStatus_MainLoadMoreToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainLoadMoreToLimit"];
            [self childHold];
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnLoft:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainHoldOnLoft"];
            [self childHold];
        }
            break;
            
#pragma mark 处理child下拉刷新
        case CRLinkageScrollStatus_ChildRefresh:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildRefresh"];
            [self _processChildRefreshAndLoadMoreScrollDir:scrollDir];
        }
            break;
#pragma mark 处理child上拉加载更多
        case CRLinkageScrollStatus_ChildLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildLoadMore"];
            [self _processChildRefreshAndLoadMoreScrollDir:scrollDir];
        }
            break;
    }
}

#pragma mark - 处理child下拉刷新/上拉加载更多
- (void)_processChildRefreshAndLoadMoreScrollDir:(CRScrollDir)scrollDir {
    [self.childConfig processChildScrollDir:scrollDir isLimit:YES overHeaderOrLimitBlock:^(BOOL isOver) {
        if (isOver) {
            // 拉过头了，切换为main滑动
            self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            // 通知代理
            if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [self.delegate scrollViewTriggerLimitWithScrollView:self.childScrollView
                                                     scrollViewType:CRScrollViewForChild
                                                  bouncePostionType:CRBouncePositionOverHeaderLimit];
            }
        } else {
            // 区域内可滑
            nil;
        }
    } overFooterOrLimitBlock:^(BOOL isOver) {
        if (isOver) {
            // 拉过头了，切换为main滑动
            self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            // 通知代理
            if ([self.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [self.delegate scrollViewTriggerLimitWithScrollView:self.childScrollView
                                                     scrollViewType:CRScrollViewForChild
                                                  bouncePostionType:CRBouncePositionOverFooterLimit];
            }
        } else {
            // 区域内可滑
            nil;
        }
    }];
}

@end
