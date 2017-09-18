//
//  ViewTrackerProxy.m
//  ViewTrackerSDKDemo
//
//  Created by philip on 2017/4/10.
//  Copyright © 2017年 ViewTracker. All rights reserved.
//

#import "ViewTrackerProxy.h"

@implementation ViewTrackerProxy
- (instancetype)init
{
    if (self = [super init]) {
        //init ViewTrack Config
        NSDictionary * dictionary = @{kExposureSwitch:@(1),
                                      kExposureWhiteList:@[@"Tab1",@"SubViewController"],
                                      kClickSwitch:@(1),
                                      kClickWhiteList:@[@"Tab1",@"SubViewController"]};
        
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
