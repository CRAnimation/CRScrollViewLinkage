//
//  UIScrollView+LBLinkage.m
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import "UIScrollView+LBLinkage.h"
#import <objc/runtime.h>
#import "LBLinkageConfig.h"

@interface UIScrollView ()
@end

@implementation UIScrollView (LBLinkage)

- (LBLinkageConfig *)linkageConfig {
    LBLinkageConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [LBLinkageConfig new];
        self.linkageConfig = config;
    }
    return config;
}

- (void)setLinkageConfig:(LBLinkageConfig *)linkageConfig {
    objc_setAssociatedObject(self, @selector(linkageConfig), linkageConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
