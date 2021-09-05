//
//  CRLinkageTool.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageTool.h"

@implementation CRLinkageTool

+ (void)showStatusLogWithIsMain:(BOOL)isMain log:(NSString *)log {
    if ([log containsString:@"CRLinkageScrollStatus_"]) {
        log = [log stringByReplacingOccurrencesOfString:@"CRLinkageScrollStatus_" withString:@""];
    }
    NSLog(@"--- %@ %@", isMain ? @"main" : @"child", log);
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

@end
