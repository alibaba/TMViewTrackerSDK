# ViewTracker - iOS

`ViewTracker`是用于自动化的采集用户UI交互过程中的曝光和点击事件。

目前仅支持Objective-C，不支持swift。

系统要求：iOS 7.0以上

[English Document](README.md)

## 特性

- 支持两个平台 (iOS & Android, Android版本可以在Github中搜索ViewTracker-Android)
- 曝光和点击事件的无痕采集
- 覆盖多种场景, 例如 Tab、ScrollView、UIControlEventTouchUpInside、页面和APP的切换
- 页面FPS这块性能良好，基本没有帧率影响
- 简单易用的API


## 性能

- 移步 [性能测试](Docs/viewtrack_performance_CN.md)

## 安装

使用 Cocoapods 来获取最新的 ViewTracker 版本

```
pod 'ViewTracker'
```


## 接入

##### 设置代理，初始化开关和配置
 
    
```
#import "ViewTrackerProxy.h"
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
    [[TMViewTrackerManager sharedManager] setCommitProtocol:[ViewTrackerProxy new]];
...
```

ViewTrackerProxy.h

```
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>
@interface ViewTrackerProxy : NSObject <TMViewTrackerCommitProtocol>
@end
```

ViewTrackerProxy.m

```
#import "ViewTrackerProxy.h"

@implementation ViewTrackerProxy
- (instancetype)init
{
    if (self = [super init]) {
        //init ViewTrack Config
        NSDictionary * dictionary = @{kExposureSwitch:@(1),
                                      kClickSwitch:@(1)};

        [[TMViewTrackerManager sharedManager] setViewTrackerConfig:dictionary];

        //register notification to handle changes of config from server.
    }
    return self;
}
- (void)ctrlClicked:(NSString*)controlName
             onPage:(NSString*)pageName
               args:(NSDictionary*)args
{
    NSLog(@"Clicked on Page(%@), controlName(%@), with args(%@)", pageName, controlName, args);
}

- (void)module:(NSString*)moduleName
  showedOnPage:(NSString*)pageName
      duration:(NSUInteger)duration
          args:(NSDictionary *)args
{

    NSLog(@"module on Page(%@), controlName(%@), duration(%lu), with args(%@)", pageName, moduleName, (unsigned long)duration, args);
}
@end
```

##### 给View 打tag 'controlName' 

```
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
    view.controlName=@"banner-0";
    view.args=@{@"picName":@"pic1"};
...
```

##### 在 viewDidAppear 设置 pageName，建议在UIViewController的基类里设置。

```
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [TMViewTrackerManager setCurrentPageName:@"Tab-1"];
}
...
```

## 原理
- 详见 [ViewTracker原理](Docs/viewtrack_principle_CN.md)

## 作者
@圆寸

@子央


## License 

ViewTracker 采用 Apache2.0 协议。 详情请见 LICENSE 文件。
