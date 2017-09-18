//
//  CycleScrollView.h
//  ViewTrackerSDKDemo
//
//  Created by philip on 2017/4/10.
//  Copyright © 2017年 ViewTracker. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//    SDCycleScrollViewPageContolAlimentRight,
//    SDCycleScrollViewPageContolAlimentCenter
//} SDCycleScrollViewPageContolAliment;
//
//typedef enum {
//    SDCycleScrollViewPageContolStyleClassic,        // 系统自带经典样式
//    SDCycleScrollViewPageContolStyleAnimated,       // 动画效果pagecontrol
//    SDCycleScrollViewPageContolStyleNone            // 不显示pagecontrol
//} SDCycleScrollViewPageContolStyle;

@class CycleScrollView;

@protocol CycleScrollViewDelegate <NSObject>

@optional

/** 点击图片回调 */
- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

/** 图片滚动回调 */
- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end

@interface CycleScrollView : UIView

/** 本地图片轮播初始化方式 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageNamesGroup:(NSArray *)imageNamesGroup;

/** 本地图片轮播初始化方式2,infiniteLoop:是否无限循环 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame shouldInfiniteLoop:(BOOL)infiniteLoop imageNamesGroup:(NSArray *)imageNamesGroup;

/** 本地图片数组 */
@property (nonatomic, strong) NSArray *localizationImageNamesGroup;

/** 自动滚动间隔时间,默认2s */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/** 是否无限循环,默认Yes */
@property (nonatomic,assign) BOOL infiniteLoop;

/** 是否自动滚动,默认Yes */
@property (nonatomic,assign) BOOL autoScroll;

/** 图片滚动方向，默认为水平滚动 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, weak) id<CycleScrollViewDelegate> delegate;

/** 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法 */
- (void)adjustWhenControllerViewWillAppera;

@end
