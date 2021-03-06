//
//  CRLinkageMainConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import "CRLinkageBaseConfig.h"
#import "CRLinkageDefine.h"
#import "CRLinkageChildConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageMainConfig : CRLinkageBaseConfig

@property (nonatomic, weak, readonly) CRLinkageChildConfig *currentChildConfig;
@property (nonatomic, weak, readonly) UIScrollView *currentChildScrollView;

/// 头部允许下拉到负一楼
@property (nonatomic, assign) BOOL headerAllowToFirstFloor;
/// 底部允许上拉到阁楼
@property (nonatomic, assign) BOOL footerAllowToLoft;

// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
