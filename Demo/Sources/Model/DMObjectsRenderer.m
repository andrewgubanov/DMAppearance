//
//
//  DMObjectsRenderer.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

#import "DMObjectsRenderer.h"
#import "DMUIObject.h"

@interface DMObjectsRenderer ()
@property (atomic, strong, readwrite) DMUIObject *root;
- (void)renderRecursivelyInContext:(CGContextRef)aContext rootObject:(DMUIObject *)aRoot clipFrame:(CGRect)aFrame;
@end

@implementation DMObjectsRenderer

- (id)initWithRootObject:(DMUIObject *)aRoot
{
    self = [super init];
    if (self != nil) {
        self.root = aRoot;
        [aRoot willMoveToRenderer];
    }
    return self;
}

- (void)renderInContex:(CGContextRef)aContext
{
    CGRect clipFrame = CGContextGetClipBoundingBox(aContext);
	CGRect rootClipFrame = [DMUIObject convertFromParentRect:clipFrame toUIObject:self.root];
    [self renderRecursivelyInContext:aContext rootObject:self.root clipFrame:rootClipFrame];
}

#pragma mark Private
- (void)renderRecursivelyInContext:(CGContextRef)aContext rootObject:(DMUIObject *)aRoot clipFrame:(CGRect)aFrame
{
    BOOL needRender = [aRoot intersectWithRect:aFrame];
    if (needRender) {
        CGContextSaveGState(aContext);
		CGContextTranslateCTM(aContext, aRoot.frame.origin.x, aRoot.frame.origin.y);
        [aRoot renderInContext:aContext];        
        for (DMUIObject *child in aRoot.children) {
			CGRect childClipFrame = [DMUIObject convertFromParentRect:aFrame toUIObject:child];
            [self renderRecursivelyInContext:aContext rootObject:child clipFrame:childClipFrame];            
        }
        CGContextRestoreGState(aContext);
    }
}

@end
