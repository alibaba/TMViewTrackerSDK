//
//  TMEventManager.h
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/21.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <UIKit/UIKit.h>


/**
 点击事件的白名单判断，与曝光不同。
 
 1. 普通view(非TableView或CollectionView的cell), 能拦截到的生命周期为willMoveToSuperview:\didMoveToSuperview\willMoveToWindow\didMoveToWindow,
 这些事件，均发生在ViewController的 viewDidAppear之前。
 
 如果在viewDidAppear内设置页面名称，并判断其白名单，则此时拿到的pageName为上一页页面名称，并不能为按钮添加监听器。
 
 所以不能再添加target之前判断白名单，而应该在target的处理回调内判断页面名称是否在白名单。
 
 2. 非TableView或CollectionView的cell, 同样能拦截到生命周期willMoveToSuperview:\didMoveToSuperview\willMoveToWindow\didMoveToWindow,
 这些事件，均发生在ViewController的 viewDidAppear之前。
 
 但是可复用view的点击事件，在本案中是通过hook其Delegate的didSelect函数来实现的。
 
 综上，对于UIView，拦截时，不判断白名单，在上报时才去判断白名单。
 */
@interface TMEventManager : NSObject


+ (void)registerFilterHandlerForView:(UIView*)view;
+ (void)uploadEventTrackingInfoForView:(UIView*)view;

+ (UIView*) targetViewForUITableViewCell:(UITableViewCell*)cell;
+ (UIView*) targetViewForUICollectionViewCell:(UICollectionViewCell*)cell;
@end
