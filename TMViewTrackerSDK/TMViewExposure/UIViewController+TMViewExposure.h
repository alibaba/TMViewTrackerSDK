//
//  UIViewController+TMViewExposure.h
//  Pods
//
//  Created by philip on 2017/3/29.
//
//

#import <UIKit/UIKit.h>

/**
 * hook UIViewController's (viewDidDisappear:) and (viewDidAppear:).
 * two usage:
 *   1. on viewDidAppear:,commit page's 2201 joinMode data.
 *   2. before viewDidAppear:,didMoveToWindow's views, modify pageName.
 */
@interface UIViewController (TMViewExposure)
+ (void)doSwizzleForTMViewExposure;
@end
