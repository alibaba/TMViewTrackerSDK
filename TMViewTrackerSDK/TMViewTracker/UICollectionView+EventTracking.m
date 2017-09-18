//
//  UICollectionView+EventTracking.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/31.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "UICollectionView+EventTracking.h"
#import "Swizzler.h"

#import "Swizzler.h"
#import "TMEventManager.h"
#import "TMViewTrackerManager+ProjectPrivateMethods.h"

@implementation UICollectionView (EventTracking)
+ (void)doSwizzle
{
    [self swizzleInstanceMethod:@selector(setDelegate:) withSelector:@selector(swizzle_etf_setDelegate:)];
}

- (void)swizzle_etf_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    if (delegate && ![delegate isProxy] && [delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        __weak UIView *weakSelf = self;
        [delegate.class swizzleInstanceMethod:@selector(collectionView:didSelectItemAtIndexPath:)
                              withReplacement:^id(IMP original, __unsafe_unretained Class swizzledClass, SEL selector) {
                                  return MethodSwizzlerReplacement(void, id, UICollectionView *collectionView, NSIndexPath *indexPath)
                                  {
                                      MethodSwizzlerOriginalImplementation(void(*)(id, SEL, id, id), collectionView, indexPath);
                                      __strong UIView *strongSelf = weakSelf;
                                      if ([[TMViewTrackerManager sharedManager] clickNeedUploadWithWhiteList:strongSelf]) {
                                          //fix bug 
                                          if (indexPath.section < [collectionView numberOfSections] &&
                                              indexPath.item < [collectionView numberOfItemsInSection:indexPath.section]) {
                                              UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                                              
                                              UIView *view = [TMEventManager targetViewForUICollectionViewCell:cell];
                                              [TMEventManager uploadEventTrackingInfoForView:view];
                                          }
                                      }
                                  };
                              }];
    }
    
    [self swizzle_etf_setDelegate:delegate];
}
@end
