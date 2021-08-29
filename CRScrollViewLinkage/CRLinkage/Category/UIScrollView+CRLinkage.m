//
//  UIScrollView+CRLinkage.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "UIScrollView+CRLinkage.h"
#import <objc/runtime.h>
#import "CRLinkageChildConfig.h"

@implementation UIScrollView (CRLinkage)

- (CRLinkageChildConfig *)linkageConfig {
    CRLinkageChildConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [CRLinkageChildConfig new];
        self.linkageConfig = config;
    }
    return config;
}

- (void)setLinkageConfig:(CRLinkageChildConfig *)linkageConfig {
    objc_setAssociatedObject(self, @selector(linkageConfig), linkageConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
