//
//  CRLinkageManager.h
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/25.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRLinkageManager : NSObject

@property (nonatomic, strong, readonly) UIScrollView *mainScrollView;

/// 配置mainScrollView
/// @param mainScrollView mainScrollView
- (void)configMainScrollView:(UIScrollView *)mainScrollView;
/// 配置childScrollView
- (void)configCurrentChildScrollView:(UIScrollView *)childScrollView;

/// 添加/删除/重置childScrollView
- (void)addChildScrollView:(UIScrollView *)childScrollView;
- (void)removeChildScrollView:(UIScrollView *)childScrollView;
- (void)resetChildScrollViews:(NSArray <UIScrollView *> *)childScrollViews;
- (void)clearChildScrollViews;
- (NSArray <UIScrollView *> *)getChildScrollViews;

@end

NS_ASSUME_NONNULL_END
