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
    CGFloat currentOffSetY = childScrollView.contentOffset.y;
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
            [self.childConfig processChildScrollDir:scrollDir isLimit:YES overHeaderOrLimitBlock:^(BOOL isOver) {
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
#pragma mark 处理child下拉到极限
        case CRLinkageScrollStatus_ChildRefreshToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildRefreshToLimit"];
        }
            break;
#pragma mark 处理child上拉加载更多
        case CRLinkageScrollStatus_ChildLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildLoadMore"];
            [self.childConfig processChildScrollDir:scrollDir isLimit:YES overHeaderOrLimitBlock:^(BOOL isOver) {
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
#pragma mark 处理child上拉到极限
        case CRLinkageScrollStatus_ChildLoadMoreToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildLoadMoreToLimit"];
        }
            break;
    }
    switch (self.linkageScrollStatus) {

        case CRLinkageScrollStatus_Idle:
            [self childHold];
            break;
            
            // mainScroll: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainScroll:
#warning Bear 这里的逻辑都再过一下
            if ([self headerBounceType] == CRBounceForChild) {
                // 刷新类型为child，mainContentOffset==0
                if (self.mainScrollView.contentOffset.y == 0) {
                    if (newOffset < 0) {
                        // 尝试向下滑，则切换为childRefresh
                        self.linkageScrollStatus = CRLinkageScrollStatus_ChildRefresh;
                    } else if (newOffset > 0) {
                        enum TmpScrollType {
                            TmpScrollTypeMain,
                            TmpScrollTypeChild,
                        };
                        enum TmpScrollType tmpScrollType = TmpScrollTypeMain;
                        BOOL mainScrollViewIsToBottom = [self checkScrollViewIsTopBottom:self.mainScrollView];
                        BOOL childScrollViewIsToBottom = [self checkScrollViewIsTopBottom:self.childScrollView];
                        
                        // 向上
                        if (self.mainScrollView.scrollEnabled == NO
                            || self.mainScrollView.userInteractionEnabled == NO) {
                            // main无法滑动，切换为childScroll
                            tmpScrollType = TmpScrollTypeChild;
                        } else if (self.childScrollView.scrollEnabled == NO
                                   || self.childScrollView.userInteractionEnabled == NO) {
                            // main可以滑动
                            tmpScrollType = TmpScrollTypeMain;
                        } else {
                            // main,child都滑倒底了
                            if (mainScrollViewIsToBottom && childScrollViewIsToBottom) {
                                switch ([self footerBounceType]) {
                                    case CRBounceForMain: { tmpScrollType = TmpScrollTypeMain; } break;
                                    case CRBounceForChild: { tmpScrollType = TmpScrollTypeChild; } break;
                                }
                            } else if (mainScrollViewIsToBottom) {
                                tmpScrollType = TmpScrollTypeChild;
                            } else {
                                tmpScrollType = TmpScrollTypeMain;
                            }
                        }
                        
                        switch (tmpScrollType) {
                            case TmpScrollTypeMain:
                                // main可以滑动
                                [self childHold];
                                break;
                            case TmpScrollTypeChild:
                                // main无法滑动，切换为childScroll
                                self.linkageScrollStatus = CRLinkageScrollStatus_ChildScroll;
                                break;
                        }
                    } else {
                        [self childHold];
                    }
                } else {
                    [self childHold];
                }
            } else {
                // 向下滑，此时为临界状态，继续保持为mainScroll
                [self childHold];
            }
            break;
            
            // childScroll: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildScroll:
            // 区域内可滑:（value>=0）
            if (currentOffSetY >= 0) {
                nil;
            }
            // 拉到头了，切换为main滑动:(value<0)
            else {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
            break;
            
            // mainRefresh: main可以滑动，child不能滑
        case CRLinkageScrollStatus_MainRefresh:
            [self childHold];
            break;
            
            // childRefresh: main不能滑，child可以滑动
        case CRLinkageScrollStatus_ChildRefresh:
            // 区域内可滑:（value<0）
            if (currentOffSetY < 0) {
                nil;
            }
            // 又开始往上滑了:(value>=0)
            else {
                self.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            }
            break;
    }
}

@end
