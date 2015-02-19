//
//
//  DMObjectsRenderer.h
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

@import Foundation;
@import CoreGraphics;

@class DMUIObject;

@interface DMObjectsRenderer : NSObject 

- (instancetype)initWithRootObject:(DMUIObject *)aRoot NS_DESIGNATED_INITIALIZER;
- (void)renderInContex:(CGContextRef)aContext;

@property (atomic, strong, readonly) DMUIObject *root;
@end
