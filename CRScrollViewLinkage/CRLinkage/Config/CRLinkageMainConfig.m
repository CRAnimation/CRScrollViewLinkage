//
//  CRLinkageMainConfig.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import "CRLinkageMainConfig.h"
#import "CRLinkageManager.h"
#import "UIScrollView+CRLinkage.h"
#import "CRLinkageManagerInternal.h"

@implementation CRLinkageMainConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        /// 头部允许下拉到负一楼
        self.headerAllowToFirstFloor = NO;
        /// 底部允许上拉到阁楼
        self.footerAllowToLoft = NO;
        
        self.isCanScroll = NO;
        self.holdOffSetY = 0;
    }
    return self;
}

- (CRLinkageChildConfig *)currentChildConfig {
    return self.currentChildScrollView.linkageChildConfig;
}

- (UIScrollView *)currentChildScrollView {
    return self.linkageInternal.childScrollView;
}

@end
