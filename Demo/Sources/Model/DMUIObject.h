//
//
//  DMUIObject.h
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

@import Foundation;
@import CoreGraphics;
#import "DMAppearance.h"

@interface DMUIObject : NSObject <DMAppearance>

- (instancetype)initWithCGFrame:(CGRect)aFrame NS_DESIGNATED_INITIALIZER;
- (void)renderInContext:(CGContextRef)aContext;

+ (CGRect)convertFromParentRect:(CGRect)aRect toUIObject:(DMUIObject *)anObject;
- (BOOL)intersectWithRect:(CGRect)aRect;

@property (atomic, assign) CGRect frame;
@property (atomic, assign, readonly) CGRect bounds;

@property (atomic, weak, readonly) DMUIObject *parent;
@property (atomic, copy, readonly) NSArray *children;
- (void)addChild:(DMUIObject *)aChild;
- (void)removeFromParent;

- (void)willMoveToRenderer;

@end
