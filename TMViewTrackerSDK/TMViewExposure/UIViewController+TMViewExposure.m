//
//  UIViewController+TMViewExposure.m
//  Pods
//
//  Created by philip on 2017/3/29.
//
//

#import "UIViewController+TMViewExposure.h"
#import "Swizzler.h"
#import "TMExposureManager.h"

#import "TMViewTrackerManager.h"
#import "UIViewController+TMViewTracker.h"
#import <objc/runtime.h>

@implementation UIViewController (TMViewExposure)
+ (void)doSwizzleForTMViewExposure
{
    [self swizzleInstanceMethod:@selector(viewDidDisappear:) withSelector:@selector(swizzle_viewDidDisappear:)];
    [self swizzleInstanceMethod:@selector(viewDidAppear:) withSelector:@selector(swizzle_viewDidAppear:)];
}

- (void)swizzle_viewDidDisappear:(BOOL)animated
{
//    [TMExposureManager commitPolymerInfoForPage:[TMViewTrackerManager currentPageName]];
    [TMExposureManager commitPolymerInfoForAllPage];
    
    [self swizzle_viewDidDisappear:animated];
}

- (void)swizzle_viewDidAppear:(BOOL)animated
{
    [self swizzle_viewDidAppear:animated];
    
    //reset Page Index
    [TMExposureManager resetPageIndexForPage:[TMViewTrackerManager currentPageName]];
}
@end
