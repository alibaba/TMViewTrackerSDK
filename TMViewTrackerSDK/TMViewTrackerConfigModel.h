//
//  TMViewTrackerConfigModel.h
//  TMViewTrackerSDK
//
//  Created by philip on 2016/12/28.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TMExposureDataUploadModeNormal = 0,
    TMExposureDataUploadModePolymer = 1,
    TMExposureDataUploadModeSingleInPage = 2,
} TMExposureDataUploadMode;

@interface TMViewTrackerConfigModel : NSObject

/**
 * info upload mode,such as Common Mode, JoinMode.
 */
@property (nonatomic, assign) TMExposureDataUploadMode exposureUploadMode;

/**
 used to indicate the view, when multi Views has the same controlName
 current used in Page_SearchResult
 */
@property (nonatomic, strong) NSArray *exposureModifyTagList;

/**
 *  click switch.
 */
@property (nonatomic, assign) BOOL clickSwitch;

/**
 * click event whitelist, if pageName is in the whitelist,sdk will upload data.
 */
@property (nonatomic, strong) NSDictionary *clickWhiteList;

/**
 * click sampling rate (0-10000),default 10000
 */
@property (nonatomic, assign) NSUInteger clickSampling;

/**
 *  exposure switch.
 */
@property (nonatomic, assign) BOOL exposureSwitch;

/**
 * time of exposure , larger than the exposure time,sdk will upload data.
 */
@property (nonatomic, assign) NSUInteger exposureTimeThreshold;

/**
 * view's exposure area threshold. If it is large than the threshold,sdk will upload data.
 */
@property (nonatomic, assign) float exposureDimThreshold;

/**
 * exposure event whitelist.
 */
@property (nonatomic, strong) NSDictionary *exposureWhiteList;

/**
 *  exposure sampling rate (0-10000),default 10000(100%)
 */
@property (nonatomic, assign) NSUInteger exposureSampling;


/**
 * update ConfigModel With dict.
 *
 * @param dict
 */
- (void)updateWithJSONDictionary:(NSDictionary *)dict;
@end
