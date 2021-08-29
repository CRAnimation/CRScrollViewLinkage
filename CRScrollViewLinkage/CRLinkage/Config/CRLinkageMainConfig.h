//
//  CRLinkageMainConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/29.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageMainConfig : NSObject

/// main专用
@property (nonatomic, weak) UIScrollView *mainScrollView;
@property (nonatomic, assign) CRGestureType mainGestureType;
@property (nonatomic, weak) CRLinkageManagerInternal *mainLinkageInternal;

// main，child共用
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
