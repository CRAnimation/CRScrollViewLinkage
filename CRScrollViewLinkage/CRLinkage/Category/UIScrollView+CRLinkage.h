//
//  UIScrollView+CRLinkage.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
@class CRLinkageConfig;
NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (CRLinkage)

@property (nonatomic, strong) CRLinkageConfig *linkageConfig;

@end

NS_ASSUME_NONNULL_END
