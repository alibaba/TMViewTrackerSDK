# ViewTracker - iOS

ViewTracker is a tool to automatically collect exposure and click event data.

Now just support Objective-C, not swift support.

The system requirement for ViewTracker is iOS 7.0+

[中文文档](README_CN.md)

## Feature

- Two platform support (iOS & Android, See ViewTracker-Android in Github for Android Version)
- Automated Data Collection for exposure and click event.
- Covering a variety of scenes , such as Tab、ScrollView、UIControlEventTouchUpInside、Page or App switch.
- A good performance on Page FPS.
- Compact API.

## Performance

- Move to [Performance Test](Docs/viewtrack_performance.md)

## Install

Use Cocoapods to Get latest version of ViewTracker

```ruby
pod 'ViewTracker'
```

## Getting Started

##### Set a Delegate to respond to processing exposure and click events.

> feature/viewtrack-opensource

```objc
#import "ViewTrackerProxy.h"
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
    [[TMViewTrackerManager sharedManager] setCommitProtocol:[ViewTrackerProxy new]];
...
```

ViewTrackerProxy.h

```objc
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>
@interface ViewTrackerProxy : NSObject <TMViewTrackerCommitProtocol>
@end
```

ViewTrackerProxy.m

```objc
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

##### Add the tag 'controlName' to the view

```objc
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
    view.controlName=@"banner-0";
    view.args=@{@"picName":@"pic1"};
...
```

##### Set pageName in viewDidAppear.It is recommended to set it in the base class。

```objc
#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

...
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [TMViewTrackerManager setCurrentPageName:@"Tab-1"];
}
...
```

## Author

- @圆寸
- @子央

## LICENSE

ViewTracker is available under the Apache2.0 license. See the LICENSE file for more info.
