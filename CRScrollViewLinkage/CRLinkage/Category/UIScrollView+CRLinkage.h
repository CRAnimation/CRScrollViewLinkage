//
//  UIScrollView+CRLinkage.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import "CRLinkageChildConfig.h"
#import "CRLinkageMainConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (CRLinkage)

@property (nonatomic, strong) CRLinkageChildConfig *linkageChildConfig;
@property (nonatomic, strong) CRLinkageMainConfig *linkageMainConfig;
@property (nonatomic, assign) BOOL isLinkageMainScrollView;

@end

NS_ASSUME_NONNULL_END
