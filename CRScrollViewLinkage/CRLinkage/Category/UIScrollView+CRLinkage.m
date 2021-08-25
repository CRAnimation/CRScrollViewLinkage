//
//  UIScrollView+CRLinkage.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "UIScrollView+CRLinkage.h"
#import <objc/runtime.h>
#import "CRLinkageConfig.h"

@implementation UIScrollView (CRLinkage)

- (CRLinkageConfig *)linkageConfig {
    CRLinkageConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [CRLinkageConfig new];
        self.linkageConfig = config;
    }
    return config;
}

- (void)setLinkageConfig:(CRLinkageConfig *)linkageConfig {
    objc_setAssociatedObject(self, @selector(linkageConfig), linkageConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
