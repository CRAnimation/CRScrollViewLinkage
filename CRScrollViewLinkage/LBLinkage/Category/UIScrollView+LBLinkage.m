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

- (LBLinkageConfig *)oldlinkageConfig {
    LBLinkageConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [LBLinkageConfig new];
        self.oldlinkageConfig = config;
    }
    return config;
}

- (void)setOldLinkageConfig:(LBLinkageConfig *)oldlinkageConfig {
    objc_setAssociatedObject(self, @selector(oldlinkageConfig), oldlinkageConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
