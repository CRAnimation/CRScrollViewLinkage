//
//  BearChildView.h
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import <UIKit/UIKit.h>
#import "BearChildTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BearChildView : UIView

+ (CGFloat)viewHeight;
@property (nonatomic, strong) BearChildTableView *myTableView;

@end

NS_ASSUME_NONNULL_END
