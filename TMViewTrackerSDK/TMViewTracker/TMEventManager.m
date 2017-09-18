//
//  TMEventManager.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/21.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "TMEventManager.h"

#import <objc/runtime.h>
#import "TMViewTrackerManager+ProjectPrivateMethods.h"

#import "UIViewController+TMViewTracker.h"
#import "UIView+TMViewTracker.h"
#import "UIView+EventTrackingFilter.m"

#import "UIView+PageName.h"

@interface TMEventManager ()
@end

@implementation TMEventManager
// add register handler for view(controlName is not nil,or minorControlName is not nil)
+ (void)registerFilterHandlerForView:(UIView *)view
{
    if ([TMEventManager isTagetView:view]) {
        if (view.userInteractionEnabled) {
            // if view is UIControl,add target to intercept events.
            if ([view isKindOfClass:[UIControl class]]) {
                [self addFilterTargetsForControl:(UIControl*)view];
            }
            
            // add extra gesture event.
            [self addFilterTargetForGestureView:view];
        }
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self registerFilterHandlerForView:obj];
        }];
    }
}

+ (UIView*) targetViewForUITableViewCell:(UITableViewCell*)cell
{
    if ([TMEventManager targetViewForView:cell]) {
        return cell;
    }
    
    if ([TMEventManager targetViewForView:cell.contentView]) {
        return cell.contentView;
    }
    
    return nil;
}
+ (UIView*) targetViewForUICollectionViewCell:(UICollectionViewCell*)cell
{
    if ([TMEventManager targetViewForView:cell]) {
        return cell;
    }
    
    if ([TMEventManager targetViewForView:cell.contentView]) {
        return cell.contentView;
    }
    
    return nil;
}
#pragma mark - determine if need to add filter for view
+ (BOOL)isTagetView:(UIView *)view
{
    return ([self targetViewForView:view] != nil);
}

+ (BOOL)isTargetViewForClick:(UIView*)view
{
    if ([view respondsToSelector:@selector(controlName)] && view.controlName)
    {
        if ([view respondsToSelector:@selector(commitType)]) {
            return (view.commitType == ECommitTypeBoth || view.commitType == ECommitTypeClick);
        }
        return YES;
    }
    return NO;
}

// if view's controlName is not nil,return the controlName;
// otherwise,traversal super view's controlName,return the controlName;
+ (UIView*)targetViewForView:(UIView*)view
{
    if (view) {
        if ([TMEventManager isTargetViewForClick:view]) {
            return view;
        }
        
        if ([view respondsToSelector:@selector(minorControlName)] && view.minorControlName) {
            return view;
        }
    }
    
    return nil;
}

+ (NSString*)controlNameForView:(UIView*)view
{
    
    if (view) {
        if ([TMEventManager isTargetViewForClick:view]) {
            return view.controlName;
        }
        
        if ([view respondsToSelector:@selector(minorControlName)] && view.minorControlName) {
            return view.minorControlName;
        }
    }
    
    return nil;
}
#pragma mark - add filter for view
+ (void)addFilterTargetForGestureView:(UIView*)view
{
    // now just support UITapGestureRecognizer
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UITapGestureRecognizer class]] && ![obj.view isKindOfClass:[UIWindow class]]) {
            [obj addTarget:self action:@selector(uploadEventTrackingInfoForGestureRecognizer:)];
        }
    }];
}


+ (void)addFilterTargetsForControl:(UIControl*)ctrl
{
    // now just support UIControlEventTouchUpInside
    UIControlEvents currentEvents = ctrl.allControlEvents;
    if (currentEvents & UIControlEventTouchUpInside) {
        // directly invoke addTarget:action:forControlEvents:  , avoid subclass overwrite the method.
        IMP aMethodImp = (IMP)class_getMethodImplementation([UIControl class], @selector(addTarget:action:forControlEvents:));
        ((void(*)(id, SEL, id, SEL, UIControlEvents))aMethodImp)(ctrl, @selector(addTarget:action:forControlEvents:), self, @selector(_uploadEventTrackingInfo:), UIControlEventTouchUpInside);
    }
}

#pragma mark - upload method
//UITapGestureRecognizer's action
+ (void)uploadEventTrackingInfoForGestureRecognizer:(UIGestureRecognizer*)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        [self _uploadEventTrackingInfo:sender.view];
    }
}

//UIControl's action
+ (void)_uploadEventTrackingInfo:(UIView *)view
{
    if ([[TMViewTrackerManager sharedManager] clickNeedUploadWithWhiteList:view]) {
        [self uploadEventTrackingInfoForView:view];
    }
}

//read upload selector for UIControl、TapGesture、[TableView & CollectionView's didSelected]
+ (void)uploadEventTrackingInfoForView:(UIView*)view
{
    if (![TMEventManager isTagetView:view]) {
        return;
    }
    // downgrade switch.
    if ([[TMViewTrackerManager sharedManager] isClickHitSampling]) {
        id protocol = [TMViewTrackerManager sharedManager].commitProtocol;
        if (protocol && [protocol respondsToSelector:@selector(ctrlClicked:onPage:args:)]) {
            UIView* targetView = [TMEventManager targetViewForView:view];
            
            NSString *controlName = [TMEventManager controlNameForView:targetView];
            if (!controlName) {
                return;
            }

            NSMutableDictionary *args = [NSMutableDictionary dictionary];
            
            // add pageCommonArgs
            UIViewController *vc = targetView.ownerViewController;
            if ([vc respondsToSelector:@selector(pageCommonArgs)]) {
                id extPageArgs = vc.pageCommonArgs;
                if (extPageArgs) {
                    [args addEntriesFromDictionary:extPageArgs];
                }
            }
            
            // add args
            if (args) {
                NSDictionary *oriArgs = nil;
                if (targetView.controlName) {
                    oriArgs = targetView.args;
                }else if (targetView.minorControlName)
                {
                    oriArgs = targetView.args;
                    if (!oriArgs) {
                        UIView *superView = targetView.superview;
                        while (superView) {
                            if (superView.controlName) {
                                oriArgs = superView.args;
                                break;
                            }
                            
                            superView = superView.superview;
                        }
                    }
                }
                
                [args addEntriesFromDictionary:oriArgs];
            }
            
            // add viewTracker's sign.
            [args addEntriesFromDictionary:@{@"isFromViewTracker":@(1)}];
            
            [protocol ctrlClicked:controlName
                           onPage:[view pageName]
                             args:[NSDictionary dictionaryWithDictionary:args]];
        }
    }
}
@end
