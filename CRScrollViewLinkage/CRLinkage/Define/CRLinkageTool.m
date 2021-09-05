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

@end
