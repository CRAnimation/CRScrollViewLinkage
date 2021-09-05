//
//  UIScrollView+CRLinkage.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import "UIScrollView+CRLinkage.h"
#import <objc/runtime.h>

@implementation UIScrollView (CRLinkage)

- (CRLinkageChildConfig *)linkageChildConfig {
    CRLinkageChildConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [CRLinkageChildConfig new];
        self.linkageChildConfig = config;
    }
    return config;
}

- (void)setLinkageChildConfig:(CRLinkageChildConfig *)linkageConfig {
    objc_setAssociatedObject(self, @selector(linkageChildConfig), linkageConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CRLinkageMainConfig *)linkageMainConfig {
    CRLinkageMainConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [CRLinkageMainConfig new];
        self.linkageMainConfig = config;
    }
    return config;
}

- (void)setLinkageMainConfig:(CRLinkageMainConfig *)linkageMainConfig {
    objc_setAssociatedObject(self, @selector(linkageMainConfig), linkageMainConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isLinkageMainScrollView {
    NSNumber *resValue = objc_getAssociatedObject(self, _cmd);
    if (!resValue) {
        resValue = @(NO);
        self.isLinkageMainScrollView = resValue;
    }
    
    return [resValue boolValue];
}

- (void)setIsLinkageMainScrollView:(BOOL)isLinkageMainScrollView {
    objc_setAssociatedObject(self, @selector(isLinkageMainScrollView), @(isLinkageMainScrollView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
