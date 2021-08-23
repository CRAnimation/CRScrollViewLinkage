//
//  LBLinkageConfig.m
//  InterLock
//
//  Created by apple on 2021/3/11.
//

#import "LBLinkageConfig.h"
#import "LBLinkageManager.h"

@implementation LBLinkageConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mainTopHeight = 0;
        self.mainGestureType = LKGestureForMainScrollView;
        self.mainLinkageManager = nil;
        
        self.isMain = NO;
        self.isCanScroll = NO;
        self.holdOffSetY = 0;
    }
    return self;
}

@end
