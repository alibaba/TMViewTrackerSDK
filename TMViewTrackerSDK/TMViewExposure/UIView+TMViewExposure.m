//
//  UIView+TMViewExposure.m
//  TMViewTrackerSDK
//
//  Created by philip on 16/6/14.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "UIView+TMViewExposure.h"

#import <objc/runtime.h>
#import <sys/time.h>

#import "UIView+TMViewTracker.h"
#import "Swizzler.h"

#import "TMViewTrackerManager+ProjectPrivateMethods.h"
#import "UIViewController+TMViewTracker.h"
#import "UIView+PageName.h"

static const char* kShowing = "showing";
//static const char* kLastLayoutDate = "lastLayoutDate";

@implementation UIView (TMViewExposure)
@dynamic showing;

+ (void)doSwizzleForTMViewExposure
{
    //for UIView's position and rect
    //no need to hook layoutSubviews, hook UIScrollView's setContentOffset instead
//    [self swizzleInstanceMethod:@selector(layoutSubviews) withSelector:@selector(swizzle_layoutSubviews)];
    
    //for UIView's hidden
    [self swizzleInstanceMethod:@selector(setHidden:) withSelector:@selector(swizzle_setHidden:)];
    
    //for UIView's alpha
    [self swizzleInstanceMethod:@selector(setAlpha:) withSelector:@selector(swizzle_setAlpha:)];
    
    //for UIViewController's switch
    [self swizzleInstanceMethod:@selector(didMoveToWindow) withSelector:@selector(swizzle_didMoveToWindow)];
//    [self swizzleInstanceMethod:@selector(willMoveToWindow:) withSelector:@selector(swizzle_willMoveToWindow:)];
}

#pragma mark - getter and setter for extra properties
//-(NSDate*)lastLayoutDate
//{
//    return objc_getAssociatedObject(self, kLastLayoutDate);
//}
//
//-(void)setLastLayoutDate:(NSDate*)date
//{
//    objc_setAssociatedObject(self, kLastLayoutDate, date, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

-(TMViewVisibleType)showing
{
    if (([self respondsToSelector:@selector(controlName)] && self.controlName)) {
        return [objc_getAssociatedObject(self, kShowing) integerValue];
    }
    
    return TMViewVisibleTypeUndefined;
}
-(void)setShowing:(TMViewVisibleType)showing
{
    if (showing == self.showing) return;

    if (([self respondsToSelector:@selector(controlName)] && self.controlName)) {
        // end show
        if( self.showing == TMViewVisibleTypeVisible && showing == TMViewVisibleTypeInvisible)
        {
            // remove observer.
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        //begin show
        else if(self.showing != TMViewVisibleTypeVisible && showing == TMViewVisibleTypeVisible)
        {
            // add observer.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVE_handlerNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
        
        objc_setAssociatedObject(self, kShowing, @(showing), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)TMVE_handlerNotification:(NSNotification*)notify
{
    if ([notify.name isEqualToString:UIApplicationDidEnterBackgroundNotification] ) {
        [TMExposureManager setState:TMViewVisibleTypeInvisible forView:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(TMVE_handlerNotification:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    else if ([notify.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [TMExposureManager setState:TMViewVisibleTypeVisible forView:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}

#pragma mark - swizzle method
-(void)swizzle_setHidden:(BOOL)hidden
{
    BOOL orig = self.hidden;
    [self swizzle_setHidden:hidden];
    
    if (orig != hidden) {
        [TMExposureManager adjustStateForView:self forType:TMViewTrackerAdjustTypeUIViewSetHidden];
    }
}

-(void)swizzle_setAlpha:(CGFloat)alpha
{
    CGFloat orig = self.alpha;
    [self swizzle_setAlpha:alpha];
    if (!(orig == alpha || (orig > 0.f && alpha >0.f))) {
        [TMExposureManager adjustStateForView:self forType:TMViewTrackerAdjustTypeUIViewSetAlpha];
    }
}

//- (void)swizzle_willMoveToWindow:(UIWindow *)newWindow
//{
//    [self swizzle_willMoveToWindow:newWindow];
//}

/**
 * do things in didMoveToWindow:  not willMoveToWindow:
 */
-(void)swizzle_didMoveToWindow
{
    [self swizzle_didMoveToWindow];
    
    if (!self.window) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
    [TMExposureManager adjustStateForView:self forType:TMViewTrackerAdjustTypeUIViewDidMoveToWindow];
}

//-(void)swizzle_layoutSubviews
//{
//    [self swizzle_layoutSubviews];
//    
//    //just for UIScrollView
//    if ([self isKindOfClass:[UIScrollView class]] ) {
//        if ([self lastLayoutDate] && ([[NSDate date] timeIntervalSince1970] - [[self lastLayoutDate] timeIntervalSince1970])*1000 < [TMViewTrackerManager sharedManager].exposureTimeThreshold) {
//            return;
//        }
//        
//        [self setLastLayoutDate:[NSDate date]];
//        
//        [TMExposureManager adjustStateForView:self];
//    }
//}

@end
