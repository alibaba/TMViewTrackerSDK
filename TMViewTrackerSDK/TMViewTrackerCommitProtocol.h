//
//  TMViewTrackerCommitProtocol.h
//  TMViewTrackerSDK
//
//  Created by philip on 2016/12/28.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TMViewTrackerCommitProtocol <NSObject>
@required
- (void)ctrlClicked:(NSString*)controlName
             onPage:(NSString*)pageName
               args:(NSDictionary*)args;

- (void)module:(NSString*)moduleName
  showedOnPage:(NSString*)pageName
      duration:(NSUInteger)duration
          args:(NSDictionary *)args;

@optional
- (NSString *)currentPageName;
@end
