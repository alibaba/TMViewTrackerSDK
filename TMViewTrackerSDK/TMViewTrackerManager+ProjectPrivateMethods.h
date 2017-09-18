//
//  TMViewTrackerManager+ProjectPrivateMethods.h
//  TMViewTrackerSDK
//
//  Created by philip on 16/9/8.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//


#import "TMViewTrackerManager.h"
#import "TMViewTrackerConfigModel.h"

@interface TMViewTrackerManager (ProjectPrivateMethods)
@property (nonatomic, strong) TMViewTrackerConfigModel *config;
@property (nonatomic, assign) BOOL isDebugModeOn;

- (BOOL)clickNeedUpload:(UIView*)view;
- (BOOL)clickNeedUploadWithWhiteList:(UIView*)view;

- (BOOL)exposureNeedUpload:(UIView*)view;
- (BOOL)exposureNeedUploadWithWhiteList:(UIView*)view;
- (BOOL)isPageNameInExposureWhiteList:(NSString*)pageName;

- (NSUInteger)exposureTimeThreshold;
- (CGFloat)exposureDimThreshold;

- (BOOL)isClickHitSampling;
- (BOOL)isExposureHitSampling;

@end
