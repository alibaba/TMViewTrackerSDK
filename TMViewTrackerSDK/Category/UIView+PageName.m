//
//  UIView+PageName.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/12/28.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "UIView+PageName.h"
#import <objc/runtime.h>

#import "UIViewController+TMViewTracker.h"
#import "TMViewTrackerManager.h"
#import "UIView+TMViewTracker.h"
#import "UIView+PageName.h"
#import "UIViewController+TMViewExposure.h"

//#import <UT/UT.h>

static const char* kPageName = "pageName";

@implementation UIView (PageName)
- (void)resetPageName
{
    objc_setAssociatedObject(self, kPageName, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pageName
{
    NSString *page = objc_getAssociatedObject(self, kPageName);
    if (!page) {
        page = [TMViewTrackerManager currentPageName];
        objc_setAssociatedObject(self, kPageName, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return page;
}

- (UIViewController*)ownerViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end

#ifdef DEBUG
@implementation UIView (EnumViews)
// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView
{
    NSMutableString *outstring = [[NSMutableString alloc] init];
    [self dumpView: aView.window atIndent:0 into:outstring];
    return outstring;
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void)dumpView:(UIView *)aView atIndent:(int)indent into:(NSMutableString *)outstring
{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] %@ (%@,%@)\n", indent, [[aView class] description], aView.controlName, aView.minorControlName];
    for (UIView *view in [aView subviews])
        [self dumpView:view atIndent:indent + 1 into:outstring];
}
@end
#endif
