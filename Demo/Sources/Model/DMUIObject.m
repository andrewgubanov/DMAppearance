//
//
//  DMUIObject.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

#import "DMUIObject.h"
#import "DMAppearanceRecorder.h"

@interface DMUIObject ()
@property (atomic, strong) NSMutableArray *mutableChildren;
@property (atomic, weak, readwrite) DMUIObject *parent;
@end

@implementation DMUIObject

+ (instancetype)appearance
{
    return (id)[DMAppearanceRecorder appearanceRecorderForClass:self];
}

- (instancetype)initWithCGFrame:(CGRect)aFrame
{
    self = [super init];
    if (self != nil) {
        self.frame = aFrame;
        self.mutableChildren = [NSMutableArray array];
    }
    return self;
}

- (void)renderInContext:(CGContextRef)aContext
{
}

- (void)addChild:(DMUIObject *)aChild
{
    if (aChild != nil)
    {
        aChild.parent = self;
        [self.mutableChildren addObject:aChild];
    }
}

- (void)removeFromParent
{
    DMUIObject *parent = self.parent;
    [parent.mutableChildren removeObject:self];
    self.parent = nil;
}

- (BOOL)intersectWithRect:(CGRect)aRect
{
	return CGRectIntersectsRect(aRect, self.bounds);
}

- (NSArray *)children
{
    return [NSArray arrayWithArray:self.mutableChildren];
}

+ (CGRect)convertFromParentRect:(CGRect)aRect toUIObject:(DMUIObject *)anObject;
{
	CGRect childFrame = anObject.frame;
	CGRect result = CGRectMake(CGRectGetMinX(aRect) - CGRectGetMinX(childFrame), CGRectGetMinY(aRect) - CGRectGetMinY(childFrame),
			CGRectGetWidth(aRect), CGRectGetHeight(aRect));
	return result;
}

- (CGRect)bounds
{
   CGRect result = {{0,0}, self.frame.size};
   return result;
}

- (void)willMoveToRenderer
{
    [[DMAppearanceRecorder appearanceRecorderForClass:[self class]] applyAppearanceForTarget:self];
    [self.children makeObjectsPerformSelector:@selector(willMoveToRenderer)];
}
@end
