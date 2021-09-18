//
//  CRLinkageTool.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageTool.h"

@implementation CRLinkageTool

/// 粗的log
+ (void)showStatusLogWithIsMain:(BOOL)isMain log:(NSString *)log {
    if ([log containsString:@"CRLinkageScrollStatus_"]) {
        log = [log stringByReplacingOccurrencesOfString:@"CRLinkageScrollStatus_" withString:@""];
    }
//    NSLog(@"--- %@ %@", isMain ? @"main" : @"child", log);
}

/// 细节的log
+ (void)showDetailWithStatus:(CRLinkageScrollStatus)status isMain:(BOOL)isMain log:(NSString *)log {
    NSString *statusString;
    switch (status) {
        case CRLinkageScrollStatus_Idle: { statusString = @"Idle"; } break;
        case CRLinkageScrollStatus_MainScroll: { statusString = @"MainScroll"; } break;
        case CRLinkageScrollStatus_ChildScroll: { statusString = @"ChildScroll"; } break;
        case CRLinkageScrollStatus_MainRefresh: { statusString = @"MainRefresh"; } break;
        case CRLinkageScrollStatus_MainRefreshToLimit: { statusString = @"MainRefreshToLimit"; } break;
        case CRLinkageScrollStatus_MainHoldOnFirstFloor: { statusString = @"MainHoldOnFirstFloor"; } break;
        case CRLinkageScrollStatus_MainLoadMore: { statusString = @"MainLoadMore"; } break;
        case CRLinkageScrollStatus_MainLoadMoreToLimit: { statusString = @"MainLoadMoreToLimit"; } break;
        case CRLinkageScrollStatus_MainHoldOnLoft: { statusString = @"MainHoldOnLoft"; } break;
        case CRLinkageScrollStatus_ChildRefresh: { statusString = @"ChildRefresh"; } break;
        case CRLinkageScrollStatus_ChildLoadMore: { statusString = @"ChildLoadMore"; } break;
    }
    NSLog(@"--- process detail-%@-%@ log:%@", isMain ? @"main" : @"child", statusString, log);
}

+ (void)processScrollDir:(CRScrollDir)scrollDir
               holdBlock:(void (^ __nullable)(void))holdBlock
                 upBlock:(void (^)(void))upBlock
               downBlock:(void (^)(void))downBlock {
    switch (scrollDir) {
        case CRScrollDir_Hold: {
            if (holdBlock) {
                holdBlock();
            }
        } break;
        case CRScrollDir_Up:
        {
            if (upBlock) {
                upBlock();
            }
        }
            break;
        case CRScrollDir_Down:
        {
            if (downBlock) {
                downBlock();
            }
        }
            break;
    }
}

#pragma mark Hold
+ (void)holdScrollView:(UIScrollView *)scrollView offSet:(CGPoint)offSet {
    CGPoint currentOffset = scrollView.contentOffset;
    if (!CGPointEqualToPoint(currentOffset, offSet)) {
        [scrollView setContentOffset:offSet animated:NO];
    }
}

@end
