//
//
//  DMView.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

#import "DMView.h"
#import "DMObjectsRenderer.h"

@interface DMView ()
@end

@implementation DMView

- (void)setRenderer:(DMObjectsRenderer *)aRenderer
{
    if (_renderer != aRenderer) {
        _renderer = aRenderer;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)aRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.renderer renderInContex:context];
}

@end
