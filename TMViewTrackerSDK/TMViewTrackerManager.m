//
//  TMViewTrackerManager.m
//  TMViewTrackerSDK
//
//  Created by philip on 16/8/15.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "TMViewTrackerManager+ProjectPrivateMethods.h"

#import "UIView+PageName.h"
#import "TMViewTrackerConfigModel.h"

#import "CALayer+TMViewExposure.h"
#import "UITableView+EventTracking.h"
#import "UICollectionView+EventTracking.h"
#import "UIView+EventTrackingFilter.h"
#import "UIView+TMViewExposure.h"
#import "UIViewController+TMViewExposure.h"
#import "UIScrollView+TMViewTracker.h"

//default values
NSString *const TMViewTrackerInitSwitchesNotification = @"TMViewTrackerManagerInitSwitchsNotification";

NSString *const kExposureSwitch         = @"exposureSwitch";
NSString *const kExposureUploadMode     = @"exposureUploadMode";
NSString *const kExposureBatchOpen      = @"batchOpen";
NSString *const kExposureTimeThreshold  = @"exposureTimeThreshold";
NSString *const kExposureDimThreshold   = @"exposureDimThreshold";
NSString *const kExposureWhiteList      = @"exposureWhiteList";
NSString *const kExposureSampling       = @"exposureSampling";

NSString *const kClickSwitch            = @"clickSwitch";
NSString *const kClickWhiteList         = @"clickWhiteList";
NSString *const kClickSampling          = @"clickSampling";


static TMViewTrackerManager *manager = nil;
static id<TMViewTrackerCommitProtocol> defaultProtocol = nil;

@interface TMViewTrackerManager ()
@property (nonatomic, assign) BOOL isDebugModeOn;

@property (nonatomic, strong) TMViewTrackerConfigModel *config;
@property (nonatomic, strong) NSString *currentPageName;
@end

@implementation TMViewTrackerManager
+(instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TMViewTrackerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _config = [[TMViewTrackerConfigModel alloc] init];
        _isDebugModeOn = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(TMVTM_handlerNotification:)
                                                     name:TMViewTrackerInitSwitchesNotification
                                                   object:nil];
    }
    
    return self;
}

+ (void)turnOnDebugMode
{
    [TMViewTrackerManager sharedManager].isDebugModeOn = YES;
}

+ (void)turnOffDebugMode
{
    [TMViewTrackerManager sharedManager].isDebugModeOn = NO;
}

+ (void)setCurrentPageName:(NSString*)pageName
{
    [TMViewTrackerManager sharedManager].currentPageName = pageName;
}

+ (NSString*)currentPageName
{
    NSString *current = [TMViewTrackerManager sharedManager].currentPageName;
    if (!current) {
        id delegate = [TMViewTrackerManager sharedManager].commitProtocol;
        if ( delegate && [delegate respondsToSelector:@selector(currentPageName)]) {
            return [delegate currentPageName];
        }
    }
    
    return current;
}
#pragma mark - public methods
- (NSUInteger)exposureTimeThreshold
{
    return _config.exposureTimeThreshold;
}

- (CGFloat)exposureDimThreshold
{
    return _config.exposureDimThreshold;
}

- (BOOL)clickNeedUpload:(UIView*)view
{
    if (!view) return NO;
    return  _config.clickSwitch;
}

- (BOOL)clickNeedUploadWithWhiteList:(UIView*)view
{
    if (!view) return NO;
    if (_config.clickSwitch) {
        id obj = [_config.clickWhiteList objectForKey:[TMViewTrackerManager currentPageName]];
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [obj boolValue];
        }
    }
    
    return NO;
}

- (BOOL)exposureNeedUpload:(UIView*)view
{
    if (!view) return NO;
    
    return _config.exposureSwitch;
}
- (BOOL)exposureNeedUploadWithWhiteList:(UIView*)view
{
    if (!view) return NO;
    return [self isPageNameInExposureWhiteList:[TMViewTrackerManager currentPageName]];
}
- (BOOL)isPageNameInExposureWhiteList:(NSString*)pageName
{
    if (_config.exposureSwitch) {
        id obj = [_config.exposureWhiteList objectForKey:pageName];
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [obj boolValue];
        }
    }
    return NO;
}

- (BOOL)isClickHitSampling
{
    if (_config.clickSampling == 10000) {
        return YES;
    }
    
    NSUInteger rand = arc4random() % 10000;
    if (rand <= _config.clickSampling) {
        return YES;
    }
    
    return NO;
}
- (BOOL)isExposureHitSampling
{
    if (_config.exposureSampling == 10000) {
        return YES;
    }
    
    NSUInteger rand = arc4random() % 10000;
    if (rand <= _config.exposureSampling) {
        return YES;
    }
    
    return NO;
}

- (void)setViewTrackerConfig:(NSDictionary*)config
{
    if (config && config.count) {
        [self _setupTMViewTrackerSDK:config];
    }
}
#pragma mark - notification handler
- (void)TMVTM_handlerNotification:(NSNotification*)notify
{
    if ([notify.name isEqualToString:TMViewTrackerInitSwitchesNotification]) {
        [self _setupTMViewTrackerSDK:notify.userInfo];
    }
}

- (void)_setupTMViewTrackerSDK:(NSDictionary*)config
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //do hook
        [UIView doSwizzleForTMViewExposure];
        [UIView doSwizzleForEventTrackingFilter];
        [UITableView doSwizzle];
        [UICollectionView doSwizzle];
        [CALayer doSwizzle];
        [UIScrollView doSwizzleForTMViewExposure];
        
        [UIViewController doSwizzleForTMViewExposure];
    });
    
    // upload config.
    NSMutableDictionary *mutableConfig = [NSMutableDictionary dictionaryWithDictionary:config];
    
    id clickWhiteList = [config objectForKey:kClickWhiteList];
    if ([clickWhiteList isKindOfClass:[NSArray class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (id item in clickWhiteList) {
            if ([item isKindOfClass:[NSString class]]) {
                [dict setObject:[NSNumber numberWithBool:YES] forKey:item];
            }
        }
        [mutableConfig setObject:dict forKey:kClickWhiteList];
    }
    
    id exposureWhiteList = [config objectForKey:kExposureWhiteList];
    if ([exposureWhiteList isKindOfClass:[NSArray class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (id item in exposureWhiteList) {
            if ([item isKindOfClass:[NSString class]]) {
                [dict setObject:[NSNumber numberWithBool:YES] forKey:item];
            }
        }
        [mutableConfig setObject:dict forKey:kExposureWhiteList];
    }
    
    [self.config updateWithJSONDictionary:mutableConfig];
}
#pragma mark - addition method
+ (void)forceBeginExposureForView:(UIView*)view
{
    [TMExposureManager adjustStateForView:view forType:TMViewTrackerAdjustTypeForceExposure];
}

+ (void)resetPageIndexOnCurrentPage
{
    [TMExposureManager resetPageIndexForPage:[TMViewTrackerManager currentPageName]];
}
@end
