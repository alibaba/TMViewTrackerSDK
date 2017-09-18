//
//  UIView+EventTrackingFilter.m
//  Pods
//
//  Created by philip on 2016/10/21.
//
//

#import "UIView+EventTrackingFilter.h"
#import "Swizzler.h"

#import "TMEventManager.h"
#import "UIView+TMViewTracker.h"
#import "UIView+PageName.h"
#import "TMViewTrackerManager+ProjectPrivateMethods.h"

@implementation UIView (EventTrackingFilter)
+ (void)doSwizzleForEventTrackingFilter
{
    [self swizzleInstanceMethod:@selector(willMoveToSuperview:) withSelector:@selector(swizzle_etf_willMoveToSuperview:)];
    [self swizzleInstanceMethod:@selector(didMoveToWindow) withSelector:@selector(swizzle_etf_didMoveToWindow)];
}

- (void)swizzle_etf_willMoveToSuperview:(UIView *)newSuperview
{
    [self swizzle_etf_willMoveToSuperview:newSuperview];
    
    if ([[TMViewTrackerManager sharedManager] clickNeedUpload:newSuperview]) {
        if (newSuperview.controlName) {
            self.minorControlName = newSuperview.controlName;
        }else if (newSuperview.minorControlName)
        {
            self.minorControlName = newSuperview.minorControlName;
        }
    }
}

- (void)setMinorControlNameForSubviews:(NSString *)minorControlName
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.minorControlName) {
            obj.minorControlName = minorControlName;
        }
        [obj setMinorControlNameForSubviews:minorControlName];
    }];
}

- (void)swizzle_etf_didMoveToWindow
{
    [self swizzle_etf_didMoveToWindow];
    
    if (self.window) {
        if ([[TMViewTrackerManager sharedManager] clickNeedUpload:self]) {
            if (self.controlName) {
                [self setMinorControlNameForSubviews:self.controlName];
            }else if (self.minorControlName)
            {
                [self setMinorControlNameForSubviews:self.minorControlName];
            }
            
            [TMEventManager registerFilterHandlerForView:self];
        }

    }else{
//        self.minorControlName = nil;
        
        //remove pageName
//        [self resetPageName];
    }
}

@end
