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
    __weak typeof(self) weakSelf = self;
    CRScrollDir scrollDir = [self _checkDirByOldOffset:oldOffset newOffset:newOffset];
//    CGFloat currentOffSetY = childScrollView.contentOffset.y;
    switch (self.linkageScrollStatus) {
        case CRLinkageScrollStatus_Idle:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_Idle"];
            [self childHoldOnTop];
        }
            break;
            
        case CRLinkageScrollStatus_MainScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainScroll"];
            if (self.childConfig.virtualLockOffSet) {
                [self childHoldOnCustom:self.childConfig.holdVirtualOffSet];
            }
//            return;
            
//            CGFloat bestMainAnchorOffsetY = self.childConfig.bestMainAnchorOffset.y;
//            CGFloat currentMainOffSetY = self.mainScrollView.contentOffset.y;
//            [CRLinkageTool processScrollDir:scrollDir holdBlock:nil upBlock:^{
//                /// 判断下，child有没有达到预定的位置，达到了，就怎么样。
//                /// 不过这个方法可以封装下，上滑的时候，有没有到预定位置。下滑的时候，有没有到预定位置，这些。
//
//                /// 往上滑过去了
//                if (currentMainOffSetY > bestMainAnchorOffsetY) {
//                    NSLog(@"---a1.1");
//                    [self childHoldOnBottom];
//                }
////                if ([self.childConfig _getHaveTriggeredFooterLimit]) {
////                    NSLog(@"---a1.1");
////                    [self childHoldOnBottom];
////                } else {
////                    NSLog(@"---a1.2");
////                    [self childHoldOnCustom:oldOffset];
////                }
//            } downBlock:^{
//                /// 往下滑过去了
//                if (currentMainOffSetY < bestMainAnchorOffsetY) {
//                    NSLog(@"---b1.1");
//                    [self childHoldOnTop];
//                }
//
////                if ([self.childConfig _getHaveTriggeredHeaderLimit]) {
////                    NSLog(@"---b1.1");
////                    [self childHoldOnTop];
////                } else {
////                    NSLog(@"---b1.2");
////                    [self childHoldOnCustom:oldOffset];
////                }
//            }];
        }
            break;
            
#pragma mark 处理child滑动
        case CRLinkageScrollStatus_ChildScroll:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_ChildScroll"];
            [self.childConfig processChildScrollDir:scrollDir isLimit:NO overHeaderOrLimitBlock:^(BOOL isOver) {
                if (isOver) {
                    // 拉过头了，切换为main滑动
                    weakSelf.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
                } else {
                    // 区域内可滑
                    nil;
                }
            } overFooterOrLimitBlock:^(BOOL isOver) {
                if (isOver) {
                    // 拉过头了，切换为main滑动
                    weakSelf.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
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
            [self childHoldOnTop];
        }
            break;
        case CRLinkageScrollStatus_MainRefreshToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainRefreshToLimit"];
            [self childHoldOnTop];
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnFirstFloor:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainHoldOnFirstFloor"];
            [self childHoldOnTop];
        }
            break;
        case CRLinkageScrollStatus_MainLoadMore:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainLoadMore"];
            [self childHoldOnTop];
        }
            break;
        case CRLinkageScrollStatus_MainLoadMoreToLimit:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainLoadMoreToLimit"];
            [self childHoldOnTop];
        }
            break;
        case CRLinkageScrollStatus_MainHoldOnLoft:
        {
            [CRLinkageTool showStatusLogWithIsMain:NO log:@"CRLinkageScrollStatus_MainHoldOnLoft"];
            [self childHoldOnTop];
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
    __weak typeof(self) weakSelf = self;
    [self.childConfig processChildScrollDir:scrollDir isLimit:YES overHeaderOrLimitBlock:^(BOOL isOver) {
        if (isOver) {
            [weakSelf.childConfig _configHaveTriggeredHeaderLimit];
            // 拉过头了，切换为main滑动
            weakSelf.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            // 通知代理
            if ([weakSelf.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [weakSelf.delegate scrollViewTriggerLimitWithScrollView:weakSelf.childScrollView
                                                     scrollViewType:CRScrollViewType_Child
                                                  bouncePostionType:CRBouncePositionOverHeaderLimit];
            }
        } else {
            // 区域内可滑
            nil;
        }
    } overFooterOrLimitBlock:^(BOOL isOver) {
        if (isOver) {
            [weakSelf.childConfig _configHaveTriggeredFooterLimit];
            // 拉过头了，切换为main滑动
            weakSelf.linkageScrollStatus = CRLinkageScrollStatus_MainScroll;
            // 通知代理
            if ([weakSelf.delegate respondsToSelector:@selector(scrollViewTriggerLimitWithScrollView:scrollViewType:bouncePostionType:)]) {
                [weakSelf.delegate scrollViewTriggerLimitWithScrollView:weakSelf.childScrollView
                                                     scrollViewType:CRScrollViewType_Child
                                                  bouncePostionType:CRBouncePositionOverFooterLimit];
            }
        } else {
            // 区域内可滑
            nil;
        }
    }];
}

#pragma mark - Tool
/// child的顶层容器view（child和main之间，离main最近的那个view。没有嵌套的话，就是childScrollView本身）
///  child生成需要被监听frame的view
- (void)childGenerateFrameObservedView {
    if (!self.childScrollView && !self.mainScrollView) {
        return;
    }
    
    switch (self.childConfig.frameObserveType) {
        case CRChildFrameObserveType_NearMain:
        {
            UIView *nearestMainView = [self _findNearestMainView];
            self.childConfig._frameObservedView = nearestMainView;
        }
            break;
        case CRChildFrameObserveType_Child:
        {
            self.childConfig._frameObservedView = self.childScrollView;
        }
            break;
        case CRChildFrameObserveType_CustomView:
        {
            self.childConfig._frameObservedView = self.childConfig.customframeObservedView;
        }
            break;
    }
}
/// 查找最接近main的view
- (UIView * _Nullable)_findNearestMainView {
    UIView *resultView = nil;
    if (!self.mainScrollView) {
        resultView = self.childScrollView;
        return resultView;
    }
    
    UIView *tmpView = self.childScrollView;
    UIResponder *tmpResponder = tmpView.nextResponder;
    while (tmpResponder != nil && ![tmpResponder isKindOfClass:[UIWindow class]] && tmpResponder != self.mainScrollView) {
        tmpView = (UIView *)tmpResponder;
        tmpResponder = tmpResponder.nextResponder;
    }
    if (tmpResponder == self.mainScrollView) {
        resultView = tmpView;
    } else {
        resultView = self.childScrollView;
    }
    return resultView;
}

///  child清除需要被监听frame的view
- (void)childClearFrameObservedView {
    [self.childConfig configFrameObservedView:nil];
}

- (UIView *)childFrameObservedView {
    return self.childConfig._frameObservedView;
}

#pragma mark Hold
- (void)childHoldOnTop {
    [self configChildContentOffSet:CGPointZero];
}

- (void)childHoldOnBottom {
    CGFloat tmpOffSet = self.childScrollView.contentSize.height - self.childScrollView.frame.size.height;
    [self configChildContentOffSet:CGPointMake(0, tmpOffSet)];
}

- (void)childHoldOnCustom:(CGFloat)offSetY {
    [self configChildContentOffSet:CGPointMake(0, offSetY)];
}

- (void)configChildContentOffSet:(CGPoint)offSet {
//    if ([self checkEqualLastChildHoldPoint:offSet]) {
//        return;
//    }
    
    [CRLinkageTool holdScrollView:self.childScrollView offSet:offSet];
    [self setLastChildHoldPoint:offSet];
}



@end
