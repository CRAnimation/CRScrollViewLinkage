//
//  CRLinkageManagerInternal+Child.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/9/5.
//

#import "CRLinkageManagerInternal.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageManagerInternal (Child)

@property (nonatomic, strong, readonly, nullable) UIView *childFrameObservedView;

- (void)_processChild:(UIScrollView *)childScrollView oldOffset:(CGFloat)oldOffset newOffset:(CGFloat)newOffset;

///  child生成需要被监听frame的view
- (void)childGenerateFrameObservedView;
///  child清除需要被监听frame的view
- (void)childClearFrameObservedView;

@end

NS_ASSUME_NONNULL_END
