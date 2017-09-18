//
//  TMViewTrackerConfigModel.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/12/28.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "TMViewTrackerConfigModel.h"

#import <objc/runtime.h>

@interface ViewTrackerPropertyModel : NSObject
@property (nonatomic, strong) NSString * typeInfo;
@property (nonatomic, strong) Class propertyCls;
@property (nonatomic, strong) NSString * name;
@end

@implementation ViewTrackerPropertyModel
@end

@interface TMViewTrackerConfigModel ()
@property (nonatomic, strong) NSDictionary * propertyMap;
@end

@implementation TMViewTrackerConfigModel


- (instancetype)init
{
    if (self = [super init]) {
        _exposureUploadMode = TMExposureDataUploadModeNormal;
        
        _clickSwitch = NO;
        _clickWhiteList = nil;
        _clickSampling = 10000;
        
        _exposureSwitch =  NO; //Default NO
        _exposureTimeThreshold = 100; //ms
        _exposureDimThreshold = 0.8f;
        _exposureWhiteList = nil;
        _exposureSampling = 10000;
        
        _exposureModifyTagList = @[
                                   @{
                                       @"pageName" : @"Page_SearchResult",
                                       @"argsId": @"item_id"
                                       }
                                   ];
        
        [self _initPropertyMap];
    }
    return self;
}

- (void)updateWithJSONDictionary:(NSDictionary *)dict
{
    //对JSON所有字段进行遍历，到 keyMapper 中查看是否有映射的属性名，然后再对属性进行设置
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *jsonKey, id jsonValue, BOOL *stop) {
        ViewTrackerPropertyModel *propertyModel = [self.propertyMap valueForKey:jsonKey];
        
        if (propertyModel) {
            if (propertyModel.propertyCls && ![jsonValue isKindOfClass:propertyModel.propertyCls]) {
                
            }else{
                [self setValue:jsonValue forKey:jsonKey];
            }
        }
    }];
}

- (void)_initPropertyMap
{
    self.propertyMap = [NSMutableDictionary dictionary];
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        
        objc_property_t property = properties[i];
        const char *cPropertyName = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:cPropertyName];
        
        if (propertyName && propertyName.length ) {
            //属性的相关属性都在propertyAttrs中，包括其类型，protocol，存取修饰符等信息
            const char *propertyAttrs = property_getAttributes(property);
            NSString *typeString = [NSString stringWithUTF8String:propertyAttrs];
            
            ViewTrackerPropertyModel *model = [TMViewTrackerConfigModel _getClassInfoFromTypeString:typeString forPropertyName:propertyName];
            
            if (model) {
                [self.propertyMap setValue:model forKey:propertyName];
            }
        }
    }
    free(properties);
}

+ (ViewTrackerPropertyModel*)_getClassInfoFromTypeString:(NSString*)typeString forPropertyName:(NSString*)propertyName
{
    if (!typeString || !typeString.length) {
        return nil;
    }
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:0];
    NSString * propertyType = [typeAttribute substringFromIndex:1];
    const char * rawPropertyType = [propertyType UTF8String];
    if (rawPropertyType == NULL) {
        return nil;
    }
    
    NSLog(@"propertyType : %s", rawPropertyType);
    
//    Q NSUInteger
//  B BOOL
//    d double/CGFloat
//    f float
    
    ViewTrackerPropertyModel * model = [ViewTrackerPropertyModel new];
    model.name = propertyName;
    NSString *propertyTypeString = [NSString stringWithUTF8String:rawPropertyType];
    char t = rawPropertyType[0];
    switch (t) {
        case 'Q':
            model.typeInfo = propertyTypeString;
            break;
        case 'B':
            model.typeInfo = propertyTypeString;
            break;
        case 'd':
            model.typeInfo = propertyTypeString;
            break;
        case 'f':
            model.typeInfo = propertyTypeString;
            break;
        case '@':
            model.typeInfo = propertyTypeString;
            if (strlen(rawPropertyType) != 1) {
                NSString *cls = [propertyTypeString substringWithRange:NSMakeRange(2, propertyTypeString.length-3)];
                
                model.propertyCls = NSClassFromString(cls);
            }
            break;
            
        default:
            break;
    }
    
    return model;
}
@end
