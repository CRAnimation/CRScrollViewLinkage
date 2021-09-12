//
//  CRLinkageTool.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CRLinkageDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageTool : NSObject

+ (void)showStatusLogWithIsMain:(BOOL)isMain log:(NSString *)log;
+ (void)processScrollDir:(CRScrollDir)scrollDir
               holdBlock:(void (^ __nullable)(void))holdBlock
                 upBlock:(void (^)(void))upBlock
               downBlock:(void (^)(void))downBlock;

#pragma mark Hold
+ (void)holdScrollView:(UIScrollView *)scrollView offSet:(CGPoint)offSet;

@end

NS_ASSUME_NONNULL_END
