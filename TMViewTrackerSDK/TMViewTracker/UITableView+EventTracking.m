//
//  UITableView+EventTracking.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/31.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "UITableView+EventTracking.h"
#import "Swizzler.h"

#import "Swizzler.h"
#import "TMEventManager.h"
#import "TMViewTrackerManager+ProjectPrivateMethods.h"

@implementation UITableView (EventTracking)
+ (void)doSwizzle
{
    [self swizzleInstanceMethod:@selector(setDelegate:) withSelector:@selector(swizzle_etf_setDelegate:)];
}

- (void)swizzle_etf_setDelegate:(id<UITableViewDelegate>)delegate
{
    if (delegate && ![delegate isProxy] && [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        __weak UIView *weakSelf = self;
        [delegate.class swizzleInstanceMethod:@selector(tableView:didSelectRowAtIndexPath:)
                              withReplacement:^id(IMP original, __unsafe_unretained Class swizzledClass, SEL selector) {
                                  return MethodSwizzlerReplacement(void, id, UITableView *tableView, NSIndexPath *indexPath){
                                      MethodSwizzlerOriginalImplementation(void(*)(id, SEL, id, id), tableView, indexPath);
                                      __strong UIView *strongSelf = weakSelf;
                                      if ([[TMViewTrackerManager sharedManager] clickNeedUploadWithWhiteList:strongSelf]) {
                                          
                                          if (indexPath.section < [tableView numberOfSections] &&
                                              indexPath.row < [tableView numberOfRowsInSection:indexPath.section]) {
                                              UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                              UIView *view = [TMEventManager targetViewForUITableViewCell:cell];
                                              [TMEventManager uploadEventTrackingInfoForView:view];
                                          }
                                      }
                                  };
                              }];
        
    }
    
    [self swizzle_etf_setDelegate:delegate];
}
@end
