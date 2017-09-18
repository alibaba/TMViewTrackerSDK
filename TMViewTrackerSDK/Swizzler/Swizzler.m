//
//  Swizzler.m
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/31.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import "Swizzler.h"

#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

NS_INLINE void classSwizzleMethod(Class cls, Method method, IMP newImp) {
    if (!class_addMethod(cls, method_getName(method), newImp, method_getTypeEncoding(method))) {
        // class already has implementation, swizzle it instead
        method_setImplementation(method, newImp);
    }
}

#pragma mark - Original Implementations

static OSSpinLock lock = OS_SPINLOCK_INIT;

static NSMutableDictionary *originalClassMethods;
static NSMutableDictionary *originalInstanceMethods;

NS_INLINE IMP originalClassMethodImplementation(__unsafe_unretained Class class, SEL selector, BOOL fetchOnly) {
    if (!originalClassMethods) {
        originalClassMethods = [[NSMutableDictionary alloc] init];
    }
    
    NSString *classKey = NSStringFromClass(class);
    NSString *selectorKey = NSStringFromSelector(selector);
    
    NSMutableDictionary *classSwizzles = originalClassMethods[classKey];
    
    NSValue *pointerValue = classSwizzles[selectorKey];
    
    if (!classSwizzles) {
        classSwizzles = [NSMutableDictionary dictionary];
        
        originalClassMethods[classKey] = classSwizzles;
    }
    
    IMP orig = NULL;
    
    if (pointerValue) {
        orig = [pointerValue pointerValue];
        
        if (fetchOnly) {
            if (classSwizzles.count == 1) {
                [originalClassMethods removeObjectForKey:classKey];
            }
            else {
                [classSwizzles removeObjectForKey:selectorKey];
            }
        }
    }
    else if (!fetchOnly) {
        orig = (IMP)[class methodForSelector:selector];
        
        classSwizzles[selectorKey] = [NSValue valueWithPointer:orig];
    }
    
    if (classSwizzles.count == 0) {
        [originalClassMethods removeObjectForKey:classKey];
    }
    
    if (originalClassMethods.count == 0) {
        originalClassMethods = nil;
    }
    
    return orig;
}

NS_INLINE IMP originalInstanceMethodImplementation(__unsafe_unretained Class class, SEL selector, BOOL fetchOnly) {
    if (!originalInstanceMethods) {
        originalInstanceMethods = [[NSMutableDictionary alloc] init];
    }
    
    NSString *classKey = NSStringFromClass(class);
    NSString *selectorKey = NSStringFromSelector(selector);
    
    NSMutableDictionary *classSwizzles = originalInstanceMethods[classKey];
    
    NSValue *pointerValue = classSwizzles[selectorKey];
    
    if (!classSwizzles) {
        classSwizzles = [NSMutableDictionary dictionary];
        
        originalInstanceMethods[classKey] = classSwizzles;
    }
    
    IMP orig = NULL;
    
    if (pointerValue) {
        orig = [pointerValue pointerValue];
        
        if (fetchOnly) {
            [classSwizzles removeObjectForKey:selectorKey];
            if (classSwizzles.count == 0) {
                [originalInstanceMethods removeObjectForKey:classKey];
            }
        }
    }
    else if (!fetchOnly) {
        orig = (IMP)[class instanceMethodForSelector:selector];
        
        classSwizzles[selectorKey] = [NSValue valueWithPointer:orig];
    }
    
    if (classSwizzles.count == 0) {
        [originalInstanceMethods removeObjectForKey:classKey];
    }
    
    if (originalInstanceMethods.count == 0) {
        originalInstanceMethods = nil;
    }
    
    return orig;
}

#pragma mark - Deswizzling Global Swizzles


NS_INLINE BOOL deswizzleClassMethod(__unsafe_unretained Class class, SEL selector) {
    OSSpinLockLock(&lock);
    
    IMP originalIMP = originalClassMethodImplementation(class, selector, YES);
    
    if (originalIMP) {
        method_setImplementation(class_getClassMethod(class, selector), (IMP)originalIMP);
        OSSpinLockUnlock(&lock);
        return YES;
    }
    else {
        OSSpinLockUnlock(&lock);
        return NO;
    }
}


NS_INLINE BOOL deswizzleInstanceMethod(__unsafe_unretained Class class, SEL selector) {
    OSSpinLockLock(&lock);
    
    IMP originalIMP = originalInstanceMethodImplementation(class, selector, YES);
    
    if (originalIMP) {
        method_setImplementation(class_getInstanceMethod(class, selector), (IMP)originalIMP);
        OSSpinLockUnlock(&lock);
        return YES;
    }
    else {
        OSSpinLockUnlock(&lock);
        return NO;
    }
}


NS_INLINE BOOL deswizzleAllClassMethods(__unsafe_unretained Class class) {
    OSSpinLockLock(&lock);
    BOOL success = NO;
    NSDictionary *d = [originalClassMethods[NSStringFromClass(class)] copy];
    for (NSString *sel in d) {
        OSSpinLockUnlock(&lock);
        if (deswizzleClassMethod(class, NSSelectorFromString(sel))) {
            success = YES;
        }
        OSSpinLockLock(&lock);
    }
    OSSpinLockUnlock(&lock);
    return success;
}


NS_INLINE BOOL deswizzleAllInstanceMethods(__unsafe_unretained Class class) {
    OSSpinLockLock(&lock);
    BOOL success = NO;
    NSDictionary *d = [originalInstanceMethods[NSStringFromClass(class)] copy];
    for (NSString *sel in d) {
        OSSpinLockUnlock(&lock);
        if (deswizzleInstanceMethod(class, NSSelectorFromString(sel))) {
            success = YES;
        }
        OSSpinLockLock(&lock);
    }
    OSSpinLockUnlock(&lock);
    return success;
}


#pragma mark - Global Swizzling

NS_INLINE void swizzleClassMethod(__unsafe_unretained Class class, SEL selector, MethodSwizzlerProvider replacement) {
    
    OSSpinLockLock(&lock);
    
    Method originalMethod = class_getClassMethod(class, selector);
    
    IMP orig = originalClassMethodImplementation(class, selector, NO);
    
    id replaceBlock = replacement(orig, class, selector);
    
    Class meta = object_getClass(class);
    
    classSwizzleMethod(meta, originalMethod, imp_implementationWithBlock(replaceBlock));
    
    OSSpinLockUnlock(&lock);
}


NS_INLINE void swizzleInstanceMethod(__unsafe_unretained Class class, SEL selector, MethodSwizzlerProvider replacement) {
   
    OSSpinLockLock(&lock);
    
    Method originalMethod = class_getInstanceMethod(class, selector);
    
    IMP orig = originalInstanceMethodImplementation(class, selector, NO);
    
    id replaceBlock = replacement(orig, class, selector);
    
    IMP replace = imp_implementationWithBlock(replaceBlock);
    
    classSwizzleMethod(class, originalMethod, replace);
    
    OSSpinLockUnlock(&lock);
}

#pragma mark - Public functions

BOOL deswizzleAll(void) {
    BOOL success = NO;
    OSSpinLockLock(&lock);
    NSDictionary *d = originalClassMethods.copy;
    for (NSString *classKey in d) {
        OSSpinLockUnlock(&lock);
        BOOL ok = [NSClassFromString(classKey) deswizzleAllMethods];
        OSSpinLockLock(&lock);
        if (success != ok) {
            success = YES;
        }
    }
    
    NSDictionary *d1 = originalInstanceMethods.copy;
    for (NSString *classKey in d1) {
        OSSpinLockUnlock(&lock);
        BOOL ok = [NSClassFromString(classKey) deswizzleAllMethods];
        OSSpinLockLock(&lock);
        if (success != ok) {
            success = YES;
        }
    }
    OSSpinLockUnlock(&lock);
    
    return success;
}

#pragma mark - Category Implementations

@implementation NSObject (MethodSwizzler)

+ (void)swizzleClassMethod:(SEL)selector withReplacement:(MethodSwizzlerProvider)replacementProvider {
    swizzleClassMethod(self, selector, replacementProvider);
}

+ (void)swizzleInstanceMethod:(SEL)selector withReplacement:(MethodSwizzlerProvider)replacementProvider {
    swizzleInstanceMethod(self, selector, replacementProvider);
}

+(void)swizzleInstanceMethod:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
    // ...
    // Method originalMethod = class_getClassMethod(class, originalSelector);
    // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+(void)swizzleClassMethod:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method swizzledMethod = class_getClassMethod(self, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end


@implementation NSObject (MethodDeSwizzler)

+ (BOOL)deswizzleClassMethod:(SEL)selector {
    if(! deswizzleClassMethod(self, selector))
    {
        
    }
    return YES;
}

+ (BOOL)deswizzleInstanceMethod:(SEL)selector {
    return deswizzleInstanceMethod(self, selector);
}

+ (BOOL)deswizzleAllClassMethods {
    return deswizzleAllClassMethods(self);
}

+ (BOOL)deswizzleAllInstanceMethods {
    return deswizzleAllInstanceMethods(self);
}

+ (BOOL)deswizzleAllMethods {
    BOOL c = [self deswizzleAllClassMethods];
    BOOL i = [self deswizzleAllInstanceMethods];
    return (c || i);
}

@end



