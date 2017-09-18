//
//  UIView+TMViewTracker.h
//  TMViewTrackerSDK
//
//  Created by philip on 2017/2/8.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ECommitTypeBoth,
    ECommitTypeClick,
    ECommitTypeExposure,
} ECommitType;

@interface UIView (TMViewTracker)
@property (nonatomic, strong) NSString *controlName;
@property (nonatomic, strong) NSDictionary *args;
@property (nonatomic, assign) ECommitType  commitType;

//特殊用途，用于处理曝光和点击事件不在同一view上的情况，请慎重使用，或联系@圆寸。
@property (nonatomic, strong) NSString *minorControlName;
@end
