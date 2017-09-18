//
//  TMViewExposureManager.m
//  TMViewTrackerSDK-Exposure
//
//  Created by philip on 2017/3/8.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import "TMExposureManager.h"
#import "UIView+TMViewTracker.h"
#import "TMViewTrackerManager+ProjectPrivateMethods.h"
#import "UIView+PageName.h"
#import "UIViewController+TMViewTracker.h"


#import "UIView+TMViewExposure.h"

@interface TMUTExposureItem : NSObject
@property (nonatomic, strong) NSString * pageName;    // Page Name.
@property (nonatomic, strong) NSString * uniqueControlName; // Control Name use to mark the unique view.
                                                            // some special items need suffix.
@property (nonatomic, strong) NSString * controlName; // Control Name.
@property (nonatomic, strong) NSDictionary * args;    // Control's extra args.

@property (nonatomic, assign) NSUInteger times;             // JionModel Exposure times.
@property (nonatomic, assign) NSUInteger totalExposureTime; // total time of JionModel Exposure,ms.

@property (nonatomic, assign) NSUInteger indexInApp;        // current control exposure times in app.
@property (nonatomic, assign) NSUInteger indexInPage;       // current control exposure times in page.
@end

@implementation TMUTExposureItem
@end

@interface TMUTExposingItem : NSObject
@property (nonatomic, strong) NSString * exposingControlName; // current control name, with view's ptr.

@property (nonatomic, assign) BOOL visible;           // current control visibility.
@property (nonatomic ,strong) NSDate * beginTime;     // the exposure beginTime of curren control.
@end

@implementation TMUTExposingItem
@end

//<pageName, <controlName, model>>
typedef NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, TMUTExposureItem*>*> TMUTExposureInfos;

//<controlName, model>
typedef NSMutableDictionary<NSString*, TMUTExposingItem*> TMUTExposingInfos;

@interface TMExposureManager ()
{
    dispatch_queue_t _exposureSerialQueue;
}

// store all data.
@property (nonatomic, strong) TMUTExposureInfos *datas;
// store exposuring data.
@property (nonatomic, strong) TMUTExposingInfos *exposingDatas;
@end

@implementation TMExposureManager
+ (instancetype)shareInstance
{
    static TMExposureManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMExposureManager alloc] init];
    });
    
    return instance;
}

+ (BOOL)isTargetViewForExposure:(UIView*)view
{
    if ([view respondsToSelector:@selector(controlName)] && view.controlName)
    {
        if ([view respondsToSelector:@selector(commitType)]) {
            return (view.commitType == ECommitTypeBoth || view.commitType == ECommitTypeExposure);
        }
        return YES;
    }
    return NO;
}
#pragma mark - public class method

/**
 * joinMode occasion :
 1. page switch
 2. app switch
 3. sdk switch update.
 4. user invoke.
 */
/**
 * commit joinMode data.
 */
+ (void)commitPolymerInfoForAllPage
{
    dispatch_async([[TMExposureManager shareInstance] getSerialQueue], ^{
        if ([TMExposureManager isPolymerModeOn]) {
            NSArray *items = [[TMExposureManager shareInstance] _itemsForAllPage];
            
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[TMUTExposureItem class]]) {
                    [self _commitItem:obj];
                }
            }];
        }
    });
}


/**
 * commit joinMode data of page.

 @param page Page Name
 */
+ (void)commitPolymerInfoForPage:(NSString*)page
{
    dispatch_async([[TMExposureManager shareInstance] getSerialQueue], ^{
        if ([TMExposureManager isPolymerModeOn]) {
            NSArray *items = [[TMExposureManager shareInstance] _itemsForPage:page];
            
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[TMUTExposureItem class]]) {
                    [self _commitItem:obj];
                }
            }];
        }
    });
}

+ (void)adjustStateForView:(UIView*)view forType:(TMViewTrackerAdjustType)type
{
    /**
     * only handle view changed in main thread,
     * if view changed not in main thread, maybe webview.
     */
    if (![NSThread isMainThread]) {
        return;
    }
    
    if (type == TMViewTrackerAdjustTypeForceExposure){
        [self findDestViewInSubviewsAndAdjustState:view recursive:YES];
        return;
    }
    
    if ([[TMViewTrackerManager sharedManager] exposureNeedUpload:view]) {
        [self findDestViewInSubviewsAndAdjustState:view
                                         recursive:type!=TMViewTrackerAdjustTypeUIViewDidMoveToWindow];
    }
}

+ (void)setState:(NSUInteger)state forView:(UIView*)view
{
    if (state == view.showing) return;
    
    // if view has controlName, recode to map.
    if ([TMExposureManager isTargetViewForExposure:view]) {
        // start visible,exposure begin.
        if (view.showing != TMViewVisibleTypeVisible && state == TMViewVisibleTypeVisible) {
            // get pageName after exposure end.
            [self view:view becomeVisible:view.controlName inPage:nil];
        }
        // exposure end.
        else if(view.showing == TMViewVisibleTypeVisible && state == TMViewVisibleTypeInvisible){
            [self view:view becomeInVisible:view.controlName inPage:[view pageName]];
        }
        
        view.showing = state;
    }
}

#pragma mark - class method of tools
+ (void)_commitItem:(TMUTExposureItem *)item
{
    id protocol = [TMViewTrackerManager sharedManager].commitProtocol;
    if (protocol && [protocol respondsToSelector:@selector(module:showedOnPage:duration:args:)]) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        // add view's args.
        if (item.args) {
            [args addEntriesFromDictionary:item.args];
        }
        
// add exposure args.
        if ([TMExposureManager isPolymerModeOn] && item.times) {
            [args setObject:@(item.times) forKey:@"exposureTimes"];
        }
        
        [args setObject:@(item.indexInApp) forKey:@"exposureIndex"];
        
        if ([[TMViewTrackerManager sharedManager] isPageNameInExposureWhiteList:item.pageName]) {
            [protocol module:item.controlName
                showedOnPage:item.pageName
                    duration:item.totalExposureTime
                        args:[NSDictionary dictionaryWithDictionary:args]];
        }
        
        [[TMExposureManager shareInstance] _clearItem:item];
    }
}

+ (void)findDestViewInSubviewsAndAdjustState:(UIView*)view recursive:(BOOL)recursive
{
    if ([TMExposureManager isTargetViewForExposure:view]){
        
        BOOL visible = [self isViewVisible:view];
        TMViewVisibleType state = visible ? TMViewVisibleTypeVisible : TMViewVisibleTypeInvisible;
        
        [self setState:state forView:view];
        //android端是一直遍历，找到所有打标controlName的view，去计算其曝光
        //之前在这里return是因为，为了节省效率，只要父view有congtrolName，就不去遍历子view了。
        //现在这里去掉return，如果当前view有controlName，仍然会向下遍历，直到找到所有设置了controlName的view。
//        return;
    }
    
    if (recursive) {
        for (UIView * subview in view.subviews) {
            [TMExposureManager findDestViewInSubviewsAndAdjustState:subview recursive:recursive];
        }
    }
}

+(BOOL)isViewVisible:(UIView*)view
{
    if (!view.window || view.hidden || view.layer.hidden || !view.alpha) {
        return NO;
    }
    
    UIView * current = view;
    while ([current isKindOfClass:[UIView class]]) {
        if (current.alpha <= 0 || current.hidden == YES) {
            return NO;
        }
        current = current.superview;
    }
    
    CGRect viewRectInWindow = [view convertRect:view.bounds toView:view.window];
    BOOL isIntersects = CGRectIntersectsRect(view.window.bounds, viewRectInWindow);
    
    if (isIntersects) {
        
        if (![TMExposureManager isTargetViewForExposure:view]) {
            return YES;
        }
        
        CGRect intersectRect = CGRectIntersection(view.window.bounds, viewRectInWindow);
        if (intersectRect.size.width != 0.f && intersectRect.size.height != 0.f) {
            // modify size threshold,80%
            CGFloat dimThreshold = [TMViewTrackerManager sharedManager].exposureDimThreshold;
            if (intersectRect.size.width / viewRectInWindow.size.width > dimThreshold &&
                intersectRect.size.height / viewRectInWindow.size.height > dimThreshold) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSString*)uniqueExposingControlName:(NSString*)controlName suffix:(NSString*)suffix
{
    return [NSString stringWithFormat:@"%@-%@", controlName, suffix];
}

+ (NSString*)uniqueControlName:(NSString*)controlName inPage:(NSString*)pageName withArgs:(NSDictionary*)args
{
    id list = [TMViewTrackerManager sharedManager].config.exposureModifyTagList;
    if ([list isKindOfClass:[NSArray class]]) {
        for (id item in list) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSString *destPageName = [item objectForKey:@"pageName"];
                if ([destPageName isKindOfClass:[NSString class]]) {
                    
                    NSString *destId = [item objectForKey:@"argsId"];
                    if ([destId isKindOfClass:[NSString class]])
                    {
                        if ([args isKindOfClass:[NSDictionary class]]) {
                            NSString *suffix = [args objectForKey:destId];
                            
                            if (suffix) {
                                return [NSString stringWithFormat:@"%@_%@", controlName, suffix];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return controlName;
}

+ (void)view:(UIView*)view becomeVisible:(NSString*)controlName inPage:(NSString*)pageName
{
    if (!view || !controlName.length){
        return;
    }

    __block NSDate* currentDate = [NSDate date];
    __block NSString *suffix = [NSString stringWithFormat:@"%p", view];
    
    dispatch_async([[TMExposureManager shareInstance] getSerialQueue], ^{
        NSString * exposingControlName = [TMExposureManager uniqueExposingControlName:controlName suffix:suffix];

        TMUTExposingItem *item = [[TMExposureManager shareInstance] _exposingItemForControlName:exposingControlName];
        if (!item) {
            item = [TMUTExposingItem new];
            item.exposingControlName = exposingControlName;
            [[TMExposureManager shareInstance] _addExposingItem:item];
        }
        item.visible = YES;
        item.beginTime = currentDate;
    });
}

+ (void)view:(UIView*)view becomeInVisible:(NSString*)controlName inPage:(NSString*)pageName
{
    if (!view || !controlName.length ) {//|| !pageName.length
        return;
    }
    
    __block NSDate* currentDate = [NSDate date];
    __block NSDictionary* args = [view.args copy];
    __block NSString *suffix = [NSString stringWithFormat:@"%p", view];
    
    dispatch_async([[TMExposureManager shareInstance] getSerialQueue], ^{
        NSString * exposingControlName = [TMExposureManager uniqueExposingControlName:controlName suffix:suffix];
        
        TMUTExposingItem *exposingItem = [[TMExposureManager shareInstance] _exposingItemForControlName:exposingControlName];
        if (exposingItem && exposingItem.beginTime && exposingItem.visible) {
            
            NSUInteger constMS = ([currentDate timeIntervalSince1970] - [exposingItem.beginTime timeIntervalSince1970]) * 1000;
            
            // remove item when exposuring.
            [[TMExposureManager shareInstance] _removeExposingItemByControlName:exposingControlName];
            
            if (pageName.length) {
                NSString *uniqueControlName = [TMExposureManager uniqueControlName:controlName inPage:pageName withArgs:args];
                
                // search joinMode data.
                TMUTExposureItem* item = [[TMExposureManager shareInstance] _itemForUniqueControlName:uniqueControlName inPage:pageName];
                
                // add item to joinMode data.
                if (!item) {
                    item = [TMUTExposureItem new];
                    item.pageName = pageName;
                    item.uniqueControlName = uniqueControlName;
                    item.controlName = controlName;
//                    item.args = args;
                    item.times = 0;
                    item.totalExposureTime = 0;
                    item.indexInApp = 0;
                    item.indexInPage = 0;
                    
                    [[TMExposureManager shareInstance] _addItem:item];
                }
                
                //rewrite args when new exposure occours
                item.args = args;
                
                // judge threshold and sampling rate
                if (constMS >= [TMViewTrackerManager sharedManager].exposureTimeThreshold // threshold
                    && [[TMViewTrackerManager sharedManager] isExposureHitSampling])// sampling rate
                {
                    item.indexInApp++;
                    item.indexInPage++;
                    
                    // commit upload right now.
                    if ([TMExposureManager isPolymerModeOn]) {
                        // modify item.
                        item.totalExposureTime += constMS;
                        item.times++;
                    }else
                    {
                        item.times++;
                        item.totalExposureTime = constMS;
                        
                        if ([TMExposureManager shouldUpload:item]) {// report once in page
                            [TMExposureManager _commitItem:item];
                        }
                    }
                }
            }
        }
    });
}

+ (void)resetPageIndexForPage:(NSString*)pageName
{
    dispatch_async([[TMExposureManager shareInstance] getSerialQueue], ^{
        TMExposureManager *mgr = [TMExposureManager shareInstance];
        NSArray * items = [mgr _itemsForPage:pageName];
        
        if ([items count]) {
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TMUTExposureItem* item = (TMUTExposureItem*)obj;
                item.indexInPage = 0;
            }];
            
        }
    });
}

#pragma mark - instance method
- (instancetype)init
{
    if (self =[super init]) {
        _exposureSerialQueue = dispatch_queue_create("exposure_handler_queue", DISPATCH_QUEUE_SERIAL);
        
        _datas = [NSMutableDictionary dictionary];
        _exposingDatas = [NSMutableDictionary dictionary];
        
        // register backgroud notification,to commit joinMode data.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVEM_handlerNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVEM_handlerNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

- (void)TMVEM_handlerNotification:(NSNotification*)notify
{
    if ([notify.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        if ([TMExposureManager isPolymerModeOn]) {
            [TMExposureManager commitPolymerInfoForAllPage];
        }
    }else if ([notify.name isEqualToString:UIApplicationWillEnterForegroundNotification])
    {
        //reset Page Index
        [TMExposureManager resetPageIndexForPage:[TMViewTrackerManager currentPageName]];
    }
}

+ (BOOL)isPolymerModeOn
{
    if ([TMViewTrackerManager sharedManager].isDebugModeOn) {
        return NO;
    }
    return [TMViewTrackerManager sharedManager].config.exposureUploadMode == TMExposureDataUploadModePolymer;
}

+ (BOOL) shouldUpload:(TMUTExposureItem*)item
{
    if ([TMViewTrackerManager sharedManager].config.exposureUploadMode == TMExposureDataUploadModeNormal) {
        return YES;
    }
    
    if ([TMViewTrackerManager sharedManager].config.exposureUploadMode == TMExposureDataUploadModeSingleInPage && item.indexInPage == 1) {
        return YES;
    }
    
    return NO;
}

- (dispatch_queue_t)getSerialQueue
{
    return _exposureSerialQueue;
}

#pragma mark - 以下函数，操作本地内存缓存，被commitPolymerInfoXXX和view:becomeXXX系列函数调用，异步串行队列。
#pragma mark - get & set item in exposingDatas
- (TMUTExposingItem*)_exposingItemForControlName:(NSString*)exposingControlName
{
    if (exposingControlName.length) {
        return [self.exposingDatas objectForKey:exposingControlName];
    }
    
    return nil;
}

- (void)_addExposingItem:(TMUTExposingItem*)item
{
    if (item && item.exposingControlName.length) {
        [self.exposingDatas setObject:item forKey:item.exposingControlName];
    }
}

- (void)_removeExposingItemByControlName:(NSString*)exposingControlName
{
    if (exposingControlName.length){
        [self.exposingDatas removeObjectForKey:exposingControlName];
    }
}

- (void)_clearExposingItem:(TMUTExposingItem*)item
{
    if (item && item.exposingControlName.length) {
        item.visible = NO;
        item.beginTime = nil;
    }
}
#pragma mark - get & set item in datas
- (NSArray<TMUTExposureItem*>*)_itemsForAllPage
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary * pageItem in self.datas.allValues) {
        [array arrayByAddingObjectsFromArray:pageItem.allValues];
    }
    
    return array;
}

- (NSArray<TMUTExposureItem*>*)_itemsForPage:(NSString*)pageName
{
    if (pageName.length) {
        NSDictionary * pageItem = [self.datas objectForKey:pageName];
        if (pageItem) {
            return [pageItem allValues];
        }
    }
    
    return nil;
}

- (TMUTExposureItem*)_itemForUniqueControlName:(NSString*)uniqueControlName inPage:(NSString*)pageName
{
    if (uniqueControlName.length && pageName.length) {
        NSDictionary * pageItem = [self.datas objectForKey:pageName];
        if (pageItem) {
            return [pageItem objectForKey:uniqueControlName];
        }
    }
    
    return nil;
}

- (void)_addItem:(TMUTExposureItem*)item
{
    if (item && item.pageName.length && item.uniqueControlName.length) {
        NSMutableDictionary * pageItem = [self.datas objectForKey:item.pageName];
        if (!pageItem) {
            pageItem = [NSMutableDictionary dictionary];
            [self.datas setObject:pageItem forKey:item.pageName];
        }
        
        [pageItem setObject:item forKey:item.uniqueControlName];
    }
}

//generally, dont need to remove any item, cause we need to record times in app.
- (void)_removeItem:(TMUTExposureItem*)item
{
    if (item && item.uniqueControlName.length && item.pageName.length) {
        NSMutableDictionary * pageItem = [self.datas objectForKey:item.pageName];
        if (pageItem) {
            [pageItem removeObjectForKey:item.uniqueControlName];
        }
    }
}

// clear item's status,after joinMode commit.
- (void)_clearItem:(TMUTExposureItem*)item
{
    if (item) {
        item.times = 0;
        item.totalExposureTime = 0;
    }
}

@end
