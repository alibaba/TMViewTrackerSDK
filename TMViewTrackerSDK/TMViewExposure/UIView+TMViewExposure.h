//
//  UIView+TMViewExposure.h
//  TMViewTrackerSDK
//
//  Created by philip on 16/6/14.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <UIKit/UIKit.h>

#import "UIView+PageName.h"

#import "TMExposureManager.h"

@interface UIView (TMViewExposure)
// view's visible type.
@property (nonatomic) TMViewVisibleType showing;
+ (void)doSwizzleForTMViewExposure;
@end
