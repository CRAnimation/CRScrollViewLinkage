//
//  CRLinkageManagerInternal+Child.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageManagerInternal.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageManagerInternal (Child)

- (void)_processChild:(UIScrollView *)childScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset;

@end

NS_ASSUME_NONNULL_END
