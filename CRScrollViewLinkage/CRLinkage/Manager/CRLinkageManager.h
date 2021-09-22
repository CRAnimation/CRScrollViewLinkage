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

/// init
/// @param useLinkageHook 是否使用默认hook方法（用来hook shouldRecognizeSimultaneouslyWithGestureRecognizer）
- (instancetype)initWithUseLinkageHook:(BOOL)useLinkageHook;

/// 配置mainScrollView
/// @param mainScrollView mainScrollView
#warning Bear 测试过程中，main后配
- (void)configMainScrollView:(UIScrollView *)mainScrollView;

#pragma mark 激活childScrollView
/// 激活childScrollView
- (void)activeCurrentChildScrollView:(UIScrollView *)childScrollView;

/// 添加/删除/重置childScrollView
//- (void)addChildScrollView:(UIScrollView *)childScrollView;
//- (void)removeChildScrollView:(UIScrollView *)childScrollView;
#warning Bear 测试过程中，child先配
- (void)configChildScrollViews:(NSArray <UIScrollView *> *)childScrollViews activeChildIndex:(NSInteger)activeChildIndex;
//- (void)clearChildScrollViews;
//- (NSArray <UIScrollView *> *)getChildScrollViews;

/// childScrollView发生添加/移除/移动时，需要调用该方法
- (void)childChanged;

/// 是否生效
- (void)active;
- (void)deactive;

- (void)updateConfig;

@end

NS_ASSUME_NONNULL_END
