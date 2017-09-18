//
//  TMSwizzler.h
//  TMViewTrackerSDK
//
//  Created by philip on 2016/10/31.
//  Copyright （C）2010-2017 Alibaba Group Holding Limited
//

#import <Foundation/Foundation.h>



/*
 * This File Provide two ways to swizzle a selector :
 *      One is swizzle a method with another selector ;
 *      The Other One is swizzle a method with a block wrapped by the provider block typed with MethodSwizzlerProvider.
 *
 * Both of the two ways support instance method and class method.
 *
 * In addition, use deswizzle to restore all swizzlers
 */

//-------------
/* typedefs */
//-------------
typedef id (^MethodSwizzlerProvider)(IMP original, __unsafe_unretained Class swizzledClass, SEL selector);

//----------------
/* Deswizzling */
//----------------

/**
 Deswizzle all methods.
 
 @return \c YES if any methods have been deswizzled successfully.
 */

OBJC_EXTERN BOOL deswizzleAll(void);


//-----------------
/* Helper macros */
//-----------------

#define MethodSwizzlerReplacement(returntype, selftype, ...) ^ returntype (__unsafe_unretained selftype self, ##__VA_ARGS__)
#define MethodSwizzlerReplacementProviderBlock ^ id (IMP original, __unsafe_unretained Class swizzledClass, SEL _cmd)
#define MethodSwizzlerOriginalImplementation(functype, ...) do{\
                                                                if (original)\
                                                                    ((functype)original)(self, _cmd, ##__VA_ARGS__);\
                                                            }while(0);



//---------------------------------------
/** @name Super easy method swizzling */
//---------------------------------------

@interface NSObject (MethodSwizzler)


/**
 Swizzle the specified class method with a block.
 
 @param selector Selector of the method to swizzle.
 @param replacement The replacement block to use for swizzling the method. Its signature needs to be: return_type ^(id self, ...).
 
 */

+ (void)swizzleClassMethod:(SEL)selector withReplacement:(MethodSwizzlerProvider)replacementProvider;


/**
 Swizzle the specified instance method with a block.
 
 @param selector Selector of the method to swizzle.
 @param replacement The replacement block to use for swizzling the method. Its signature needs to be: return_type ^(id self, ...).
 
 */

+ (void)swizzleInstanceMethod:(SEL)selector withReplacement:(MethodSwizzlerProvider)replacementProvider;


/**
 Swizzle the specified instance method with another selector

 @param selector         Selector of the method to swizzle.
 @param swizzledSelector Selector of the new method will be swizzled.
 */
+ (void)swizzleInstanceMethod:(SEL)selector withSelector:(SEL)swizzledSelector;

/**
 Swizzle the specified class method with another selector
 
 @param selector         Selector of the method to swizzle.
 @param swizzledSelector Selector of the new method will be swizzled.
 */
+ (void)swizzleClassMethod:(SEL)selector withSelector:(SEL)swizzledSelector;
@end




//---------------------------------------
/** @name Super easy method swizzling */
//---------------------------------------

@interface NSObject (MethodDeSwizzler)

/**
 Restore the specified class method by removing all swizzles.
 
 @param selector Selector of the swizzled method.
 
 @return \c YES if the method was successfully restored, \c NO if the method has never been swizzled.
 
 */

+ (BOOL)deswizzleClassMethod:(SEL)selector;




/**
 Restore the specified class method by removing all swizzles.
 
 @param selector Selector of the swizzled method.
 
 @return \c YES if the method was successfully restored, \c NO if the method has never been swizzled.
 
 */

+ (BOOL)deswizzleInstanceMethod:(SEL)selector;





/**
 Restore all swizzled class methods.
 
 @return \c YES if the method was successfully restored, \c NO if no method has never been swizzled
 
 */

+ (BOOL)deswizzleAllClassMethods;



/**
 Restore all swizzled instance methods.
 
 @return \c YES if the method was successfully restored, \c NO if no method has never been swizzled.
 
 */

+ (BOOL)deswizzleAllInstanceMethods;




/**
 Restore all swizzled class and instance methods.
 
 @return \c YES if the method was successfully restored, \c NO if no method has never been swizzled.
 
 */

+ (BOOL)deswizzleAllMethods;

@end



