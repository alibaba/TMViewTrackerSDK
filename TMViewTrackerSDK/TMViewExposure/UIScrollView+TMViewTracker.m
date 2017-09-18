//
//  UIScrollView+TMViewTracker.m
//  Pods
//
//  Created by philip on 2017/5/11.
//
//

#import "UIScrollView+TMViewTracker.h"

#import <objc/runtime.h>
#import "Swizzler.h"
#import "TMViewTrackerManager+ProjectPrivateMethods.h"
#import "TMExposureManager.h"

static const char* kLastLayoutDate = "lastLayoutDate";
@implementation UIScrollView (TMViewTracker)

+ (void)doSwizzleForTMViewExposure
{
    //for UIView's position and rect
    [self swizzleInstanceMethod:@selector(setContentOffset:) withSelector:@selector(swizzle_setContentOffset:)];
}

-(NSDate*)lastLayoutDate
{
    return objc_getAssociatedObject(self, kLastLayoutDate);
}

-(void)setLastLayoutDate:(NSDate*)date
{
    objc_setAssociatedObject(self, kLastLayoutDate, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)swizzle_setContentOffset:(CGPoint)contentOffset
{
    [self swizzle_setContentOffset:contentOffset];
    
    //只有当应用在前台的时候才拦截setContentOffset
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        if ([self lastLayoutDate] && ([[NSDate date] timeIntervalSince1970] - [[self lastLayoutDate] timeIntervalSince1970])*1000 < [TMViewTrackerManager sharedManager].exposureTimeThreshold) {
            return;
        }
        
        [self setLastLayoutDate:[NSDate date]];
    
        [TMExposureManager adjustStateForView:self forType:TMViewTrackerAdjustTypeUIScrollViewSetContentOffset];
    }
}

@end
