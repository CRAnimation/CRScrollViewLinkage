//
//  CRLinkageConfig.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import "CRLinkageDefine.h"
@class CRLinkageManagerInternal;

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageConfig : NSObject

// main专用
@property (nonatomic, assign) CRGestureType mainGestureType;
@property (nonatomic, weak) CRLinkageManagerInternal *mainLinkageInternal;

// child专用
@property (nonatomic, strong) NSNumber *childTopFixHeight;
@property (nonatomic, assign) CGFloat childHeight;
@property (nonatomic, assign) CRBounceType headerBounceType;
@property (nonatomic, assign) CRBounceType footerBounceType;

// main，child共用
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL isCanScroll;
@property (nonatomic, assign) CGFloat holdOffSetY;

@end

NS_ASSUME_NONNULL_END
