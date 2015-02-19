//
//
//  DMUIElipse.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

#import "DMUIElipse.h"

@interface DMUIElipse ()
@end

@implementation DMUIElipse

- (void)renderInContext:(CGContextRef)aContext
{
    CGContextSaveGState(aContext);
    CGContextSetFillColorWithColor(aContext, self.fillColor.CGColor);
    CGContextFillEllipseInRect(aContext, self.bounds);
    CGContextRestoreGState(aContext);
}

@end
