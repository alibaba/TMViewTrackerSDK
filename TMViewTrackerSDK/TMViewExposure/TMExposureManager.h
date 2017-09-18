//
//  TMViewExposureManager.h
//  TMViewTrackerSDK-Exposure
//
//  Created by philip on 2017/3/8.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TMViewVisibleType){
    TMViewVisibleTypeUndefined = 0,
    TMViewVisibleTypeVisible,   //1
    TMViewVisibleTypeInvisible  //2
};


typedef enum : NSUInteger {
    TMViewTrackerAdjustTypeCALayerSetHidden = 0,
    TMViewTrackerAdjustTypeUIViewSetHidden,
    TMViewTrackerAdjustTypeUIViewSetAlpha,
    TMViewTrackerAdjustTypeUIViewDidMoveToWindow,
    TMViewTrackerAdjustTypeUIScrollViewSetContentOffset,
    TMViewTrackerAdjustTypeForceExposure
} TMViewTrackerAdjustType;

@interface TMExposureManager : NSObject

+ (void)commitPolymerInfoForAllPage;
+ (void)commitPolymerInfoForPage:(NSString*)page;

/**
 auto calc State and set for tagged view with controlName.

 if the given view doesn't have controlName, find in subviews and do setState.
 
 @param view  given view
 @param type  who calls the method
 */
+ (void)adjustStateForView:(UIView*)view forType:(TMViewTrackerAdjustType)type;

/**
 set State for tagged view with controlName

 @param state newState
 @param view  given View
 */
+ (void)setState:(NSUInteger)state forView:(UIView*)view;

//call this method to set the stored index of control to zero.
// the timing is ,
// 1. when the destViewController called viewDidAppear:, new appear, should reset index
// 2. when the destViewController come back from Back, viewDidAppear: may not be called, here we should do it
// 3. when the destViewController will relayout according an url's response, life cycle cant catch it, should call it.
+ (void)resetPageIndexForPage:(NSString*)pageName;
@end
