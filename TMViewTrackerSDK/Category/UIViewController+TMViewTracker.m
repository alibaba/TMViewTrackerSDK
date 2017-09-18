//
//  UIViewController+TMViewTracker.m
//  TMViewTrackerSDK
//
//  Created by philip on 16/8/10.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "UIViewController+TMViewTracker.h"

#import <objc/runtime.h>

static const char* kPageCommonArgs = "pageCommonArgs";
@implementation UIViewController (TMViewTracker)
- (NSDictionary *)pageCommonArgs
{
    return objc_getAssociatedObject(self, kPageCommonArgs);
}

- (void)setPageCommonArgs:(NSDictionary *)extArgs
{
    if ([extArgs isKindOfClass:[NSDictionary class]]) {
        objc_setAssociatedObject(self, kPageCommonArgs, extArgs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end
