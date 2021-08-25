//
//  UIScrollView+LBLinkage.h
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import <UIKit/UIKit.h>
@class LBLinkageConfig;

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (LBLinkage)

@property (nonatomic, strong) LBLinkageConfig *oldlinkageConfig;

@end

NS_ASSUME_NONNULL_END
