//
//
//  DMAppearanceRecorder.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

@import CoreGraphics;
#import "DMAppearanceRecorder.h"
#import <objc/runtime.h>

static NSMutableDictionary *sDMClassRecorders = nil;

static void* DMReplacementMethod(id self, SEL _cmd, ...);

@interface NSString (DMAppearanceRecorderEncoding)
- (BOOL)dm_isEqualToOBJCEncodedType:(const char *)aType;
- (BOOL)dm_hasCaseInsensitivePrefix:(NSString *)aPrefix;
- (NSString *)dm_stringByRemovingEnodingQualifiers;
@end

@implementation NSString (Encoding)

- (BOOL)dm_isEqualToOBJCEncodedType:(const char *)aType
{
    NSString *encodingType = [[NSString stringWithUTF8String:aType] dm_stringByRemovingEnodingQualifiers];
    NSString *source = [self dm_stringByRemovingEnodingQualifiers];
    return [source isEqualToString:encodingType];
}

- (BOOL)dm_hasCaseInsensitivePrefix:(NSString *)aPrefix
{
    NSString *token = [aPrefix uppercaseString];
    NSString *sorce = [self uppercaseString];
    return [sorce hasPrefix:token];
}

- (NSString *)dm_stringByRemovingEnodingQualifiers
{
    if ( ([self dm_hasCaseInsensitivePrefix:@"n"]) ||
         ([self dm_hasCaseInsensitivePrefix:@"o"]) ||
         ([self dm_hasCaseInsensitivePrefix:@"r"]) ||
         ([self hasPrefix:@"V"]) ) {
        return [self substringFromIndex:1];
    } else {
        return self;
    }
}
@end


@interface DMAppearanceRecorder ()
@property (atomic, strong) Class targetClass;
@property (atomic, strong) NSMutableDictionary *originalIMPs;
@property (atomic, strong) NSMutableDictionary *invocations;
@property (atomic, strong) NSMutableDictionary *calledOriginals;
@end

@implementation DMAppearanceRecorder

+ (instancetype)appearanceRecorderForClass:(Class)aClass
{
    DMAppearanceRecorder *result = nil;
    @synchronized (self) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sDMClassRecorders = [[NSMutableDictionary alloc] init];
        });
        
        NSString *key = NSStringFromClass(aClass);
        if (key != nil) {
            result = sDMClassRecorders[key];
            if (result == nil) {
                result = [[self alloc] init];
                result.targetClass = aClass;
                sDMClassRecorders[key] = result;
            }
        }
    }
    return result;
}

- (instancetype)init
{
    self.invocations = [NSMutableDictionary dictionary];
    self.calledOriginals = [NSMutableDictionary dictionary];
    self.originalIMPs = [NSMutableDictionary dictionary];
    return self;
}

- (void)applyAppearanceForTarget:(id)aTarget
{
    NSArray *canceledRecords = nil;
    @synchronized (self.calledOriginals) {
        NSValue *key = [NSValue valueWithNonretainedObject:aTarget];
        canceledRecords = self.calledOriginals[key];
    }
    NSDictionary *invocations = nil;
    @synchronized (self.invocations) {
        invocations = self.invocations;
    }
    [invocations enumerateKeysAndObjectsUsingBlock:^(id aKey, id anObj, BOOL *stop) {
        //aKey = selector, anObj = NSInvocation
        if (![canceledRecords containsObject:aKey]) {
        
            NSInvocation *invocation = anObj;
            IMP originalIMP = NULL;
            @synchronized (self.originalIMPs) {
                originalIMP = [self.originalIMPs[NSStringFromSelector(invocation.selector)] pointerValue];
            }
            //swizzle back to original imp, so it could be correctly handleled in [invocation invoke];
            Method method = class_getInstanceMethod([aTarget class], invocation.selector);
            method_setImplementation(method, originalIMP);
            
            [invocation setTarget:aTarget];
            [invocation invoke];
            [invocation setTarget:nil];
            
            //swizzle back as we still want to keep track of any mehod custom calls
            method_setImplementation(method, (IMP)DMReplacementMethod);
        }
    }];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    @synchronized (self.invocations) {
        NSString *key = NSStringFromSelector(anInvocation.selector);
        if (key != nil) {
            if (self.invocations[key] == nil) {
                Method method = class_getInstanceMethod(self.targetClass, anInvocation.selector);
                IMP originalIMP = method_setImplementation(method, (IMP)DMReplacementMethod);
                @synchronized (self.originalIMPs) {
                    self.originalIMPs[key] = [NSValue valueWithPointer:originalIMP];
                }
            }
            [anInvocation setTarget:nil];
            [anInvocation retainArguments];
            self.invocations[key] = anInvocation;
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *result = nil;
    if (self.targetClass != nil) {
        result = [self.targetClass instanceMethodSignatureForSelector:aSelector];
    } else {
        result = [super methodSignatureForSelector:aSelector];
    }
    return result;
}
@end

static void* DMReplacementMethod(id self, SEL _cmd, ...)
{
    IMP originalIMP = NULL;
    DMAppearanceRecorder *recorder = [DMAppearanceRecorder appearanceRecorderForClass:[self class]];
    @synchronized (recorder.originalIMPs) {
        originalIMP = [recorder.originalIMPs[NSStringFromSelector(_cmd)] pointerValue];
    }
    //swizzle back to original imp, so it could be correctly handleled in [invocation invoke];
    Method method = class_getInstanceMethod([self class], _cmd);
    method_setImplementation(method, originalIMP);
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:_cmd];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = _cmd;
    invocation.target = self;
    va_list arguments;
    va_start(arguments, _cmd);
    
    NSUInteger count = [methodSignature numberOfArguments];
    for (NSUInteger index = 2; index < count; index++) {
        NSString *argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:index]];
        if ([argumentType dm_hasCaseInsensitivePrefix:@"@"]) {
            id token = va_arg(arguments, id);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(BOOL)]) {
            BOOL token = va_arg(arguments, int);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(NSInteger)]) {
            NSInteger token = va_arg(arguments, NSInteger);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(NSUInteger)]) {
            NSUInteger token = va_arg(arguments, NSUInteger);
            [invocation setArgument:&token atIndex:index];
        } else if ( ([argumentType dm_isEqualToOBJCEncodedType:@encode(double)]) && CGFLOAT_IS_DOUBLE) {
            CGFloat token = va_arg(arguments, double);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(CGPoint)]) {
            CGPoint token = va_arg(arguments, CGPoint);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(CGSize)]) {
            CGSize token = va_arg(arguments, CGSize);
            [invocation setArgument:&token atIndex:index];
        } else if ([argumentType dm_isEqualToOBJCEncodedType:@encode(CGRect)]) {
            CGRect token = va_arg(arguments, CGRect);
            [invocation setArgument:&token atIndex:index];
        } else {
            abort();
        }
    }
    va_end(arguments);
    
    @synchronized (recorder.calledOriginals) {
        NSValue *key = [NSValue valueWithNonretainedObject:self];
        NSMutableArray *records = recorder.calledOriginals[key];
        if (records == nil) {
            records = [NSMutableArray array];
            recorder.calledOriginals[key] = records;
        }
        NSString *record = NSStringFromSelector(_cmd);
        if (![records containsObject:record]) {
            [records addObject:record];
        }
    }
    
    [invocation invoke];
    
    //swizzle back as we still want to keep track of any mehod custom calls
    method_setImplementation(method, (IMP)DMReplacementMethod);
    
    void *returnValue = nil;
    if (methodSignature.methodReturnLength != 0) {
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}
