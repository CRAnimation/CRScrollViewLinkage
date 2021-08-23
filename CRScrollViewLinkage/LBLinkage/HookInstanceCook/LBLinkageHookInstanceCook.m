//
//  HookInstanceCook.m
//  longbridge-ios-app
//
//  Created by apple on 2021/3/11.
//  Copyright © 2021 5th. All rights reserved.
//

#import "LBLinkageHookInstanceCook.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "LBLinkageScrollViewHook.h"

static NSMutableDictionary *newClassDict;

@interface LBLinkageHookInstanceCook() <UIGestureRecognizerDelegate, LBLinkageRuntimeMethodProtocol>
{
    dispatch_semaphore_t _lock;
}
@end

@implementation LBLinkageHookInstanceCook

+ (void)initialize
{
    if (self == [LBLinkageHookInstanceCook class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            newClassDict = [NSMutableDictionary new];
        });
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)hookScrollViewInstance:(id)instance {
    if (![instance isKindOfClass:[UIScrollView class]]) {
        NSLog(@"--必须提供UIScrollView或者其子类");
        return;
    }
    
    Class originClass = [instance class];
    
    // 生成名称
    NSString *originClassName = NSStringFromClass(originClass);
    NSString *newClassName = [NSString stringWithFormat:@"%@_%@", @"Linkage", originClassName];
    
    // 获取新类
    BOOL isNewClass = NO;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    Class newClass = [newClassDict objectForKey:newClassName];
    if (!newClass) {
        // 创建新类
        newClass = [self createClass:[newClassName UTF8String] inheritingFromClass:originClass];
        newClassDict[newClassName] = newClass;
        isNewClass = YES;
    }
    dispatch_semaphore_signal(_lock);
    
    // 新类初始化
    if (isNewClass) {
        // selector
        SEL simultaneouslySel = @selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:);
        SEL namualCallSuperOriginSel = @selector(manualCallSuperWithSel:defaultReturn:paras:);
        SEL linkageGestureCheckSel = @selector(linkageCheckGestureRecognizer:);
        SEL shouldBeginSel = @selector(gestureRecognizerShouldBegin:);
        SEL inBothAreaSel = @selector(gestureIsInBothArea:);
        
        // 添加新方法(如果当前类存在该方法，则不会添加)
        [self addInstanceMethodWithTargetClass:newClass fromClass:[LBLinkageScrollViewHook class] selector:simultaneouslySel];
        [self addInstanceMethodWithTargetClass:newClass fromClass:[LBLinkageScrollViewHook class] selector:namualCallSuperOriginSel];
        [self addInstanceMethodWithTargetClass:newClass fromClass:[LBLinkageScrollViewHook class] selector:linkageGestureCheckSel];
        [self addInstanceMethodWithTargetClass:newClass fromClass:[LBLinkageScrollViewHook class] selector:shouldBeginSel];
        [self addInstanceMethodWithTargetClass:newClass fromClass:[LBLinkageScrollViewHook class] selector:inBothAreaSel];
        
        // 注册类
        objc_registerClassPair(newClass);
    }
    
    // 修改isa指针
    object_setClass(instance, newClass);
}

- (BOOL)checkIsNativeScrollView:(Class)class {
    if (class == [UIScrollView class]
        || class == [UICollectionView class]
        || class == [UITableView class]) {
        return YES;
    }
    
    return NO;
}



/// 添加实例方法
- (void)addInstanceMethodWithTargetClass:(Class)targetClass
                               fromClass:(Class)fromClass
                                selector:(SEL)selector {
    [self addInstanceMethodWithTargetClass:targetClass
                                 targetSel:selector
                                 fromClass:fromClass
                              fromClassSel:selector];
}

/// 添加实例方法
/// @param targetClass 被添加方法的class
/// @param targetSel 被添加方法的class中要调用的sel名称
/// @param fromClass 提供Sel实现的Class
/// @param fromClassSel 提供的Sel实现
- (void)addInstanceMethodWithTargetClass:(Class)targetClass
                               targetSel:(SEL)targetSel
                               fromClass:(Class)fromClass
                            fromClassSel:(SEL)fromClassSel{
    Method tmpMethod = class_getInstanceMethod(fromClass, fromClassSel);
    IMP tmpIMP = method_getImplementation(tmpMethod);
    class_addMethod(targetClass, targetSel, tmpIMP, method_getTypeEncoding(tmpMethod));
//    BOOL didAddMethod = class_addMethod(targetClass, targetSel, tmpIMP, method_getTypeEncoding(tmpMethod));
//    NSLog(@"%@--add %@", NSStringFromSelector(targetSel), didAddMethod ? @"cuccess" : @"failure");
}

/// 添加类方法
- (void)addClassMethodWithTargetClass:(Class)targetClass fromClass:(Class)fromClass selector:(SEL)selector {
    Method tmpMethod = class_getClassMethod(fromClass, selector);
    IMP tmpIMP = method_getImplementation(tmpMethod);
    class_addMethod(targetClass, selector, tmpIMP, method_getTypeEncoding(tmpMethod));
//    BOOL didAddMethod = class_addMethod(targetClass, selector, tmpIMP, method_getTypeEncoding(tmpMethod));
//    NSLog(@"%@--add %@", NSStringFromSelector(selector), didAddMethod ? @"cuccess" : @"failure");
}
    
/// 获取LoadFunction类的所有实例方法
- (void)printAllInstanceMothed:(Class)class {
    unsigned int count; // 1
    Method *methods = class_copyMethodList(class, &count); // 2
    for (int i = 0; i < count; i++) { // 3
        Method method = methods[i];
//        NSString *methodName = [NSString stringWithCString:sel_getName(method_getName(method)) encoding:NSUTF8StringEncoding];
//        IMP lastImp = method_getImplementation(method);
//        SEL lastSel = method_getName(method);
////        NSLog(@"--lastImp:%@ lastSel:%@", lastImp, lastSel);
////        IMP imp = method_getImplementation(methods[i]);
////        NSLog(@"imp:%@", imp);
////        NSString *str =((id(*)(id, UIView*, id))imp)(self, [UIView new], @"DFD");
////        NSLog(@"--str:%@", str);
        NSLog(@"class---%s", sel_getName(method_getName(method))); // 4
    } // 5
    free(methods); // 6
}

- (Class)createClass:(const char *)className inheritingFromClass:(Class)superclass {
    return objc_allocateClassPair(superclass, className, 0);
}

//exchange implementation of two methods
- (void)swizzleMethods:(Class)class originalSelector:(SEL)origSel swizzledSelector:(SEL)swizSel
{
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method swizMethod = class_getInstanceMethod(class, swizSel);
    
    //class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        //origMethod and swizMethod already exist
        method_exchangeImplementations(origMethod, swizMethod);
    }
}

@end
