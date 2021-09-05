//
//  CRLinkageManagerInternal+Main.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageManagerInternal.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageManagerInternal (Main)

- (void)_processMain:(UIScrollView *)mainScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset;

@end

NS_ASSUME_NONNULL_END
