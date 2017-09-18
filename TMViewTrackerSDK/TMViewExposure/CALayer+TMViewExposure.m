//
//  CALayer+TMViewExposure.m
//  TMViewTrackerSDK
//
//  Created by philip on 16/6/14.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "CALayer+TMViewExposure.h"

#import "Swizzler.h"
#import "TMExposureManager.h"

@implementation CALayer (TMViewExposure)

+ (void)doSwizzle
{
    [self swizzleInstanceMethod:@selector(setHidden:) withSelector:@selector(swizzle_setHidden:)];
}

-(void)swizzle_setHidden:(BOOL)hidden
{
    BOOL orig = self.hidden;
    
    [self swizzle_setHidden:hidden];
    
    if (orig != hidden) {
        id delegate = self.delegate;
        if (delegate && [delegate isKindOfClass:[UIView class]]) {
            UIView *view = delegate;
            
            [TMExposureManager adjustStateForView:view forType:TMViewTrackerAdjustTypeCALayerSetHidden];
        }
    }
}
@end
