//
//  UIScrollView+CRLinkage.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
@class CRLinkageChildConfig;
NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (CRLinkage)

@property (nonatomic, strong) CRLinkageChildConfig *linkageConfig;

@end

NS_ASSUME_NONNULL_END
