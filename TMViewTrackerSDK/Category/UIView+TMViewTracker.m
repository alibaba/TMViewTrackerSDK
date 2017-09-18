//
//  UIView+TMViewTracker.m
//  TMViewTrackerSDK
//
//  Created by philip on 2017/2/8.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import "UIView+TMViewTracker.h"

#import <objc/runtime.h>

@implementation UIView (TMViewTracker)

static const char *dataCollectionControlName = "controlName";
static const char *dataCollectionMinorControlName = "minorControlName";
static const char *dataCollectionArgs = "dataCollectionArgs";
static const char *dataCollectionCommitType = "commitType";

#pragma mark - Setter And Getters
- (void)setControlName:(NSString *)controlName
{
    if ([controlName isKindOfClass:[NSString class]]) {
        objc_setAssociatedObject(self, dataCollectionControlName, controlName, OBJC_ASSOCIATION_RETAIN);
    }
}
- (NSString *)controlName
{
    return objc_getAssociatedObject(self, dataCollectionControlName);
}

- (void)setMinorControlName:(NSString *)minorControlName
{
    if ([minorControlName isKindOfClass:[NSString class]]) {
        objc_setAssociatedObject(self, dataCollectionMinorControlName, minorControlName, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSString *)minorControlName
{
    return objc_getAssociatedObject(self, dataCollectionMinorControlName);
}
- (void)setArgs:(NSDictionary *)args
{
    if ([args isKindOfClass:[NSDictionary class]]) {
        objc_setAssociatedObject(self, dataCollectionArgs, args, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSDictionary *)args
{
    return objc_getAssociatedObject(self, dataCollectionArgs);
}

- (ECommitType)commitType
{
    return [objc_getAssociatedObject(self, dataCollectionCommitType) unsignedIntegerValue];
}

- (void)setCommitType:(ECommitType)type
{
    objc_setAssociatedObject(self, dataCollectionCommitType, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
