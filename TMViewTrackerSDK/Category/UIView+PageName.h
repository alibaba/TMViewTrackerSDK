//
//  UIView+PageName.h
//  TMViewTrackerSDK
//
//  Created by philip on 2016/12/28.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <UIKit/UIKit.h>

@interface UIView (PageName)
- (void)resetPageName;
- (NSString*)pageName;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)ownerViewController;


@end

#pragma mark - debug funtions
#ifdef DEBUG
@interface UIView (EnumViews)
// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView;

// Recursively travel down the view tree, increasing the indentation level for children
- (void)dumpView:(UIView *)aView atIndent:(int)indent into:(NSMutableString *)outstring;
@end

#endif
