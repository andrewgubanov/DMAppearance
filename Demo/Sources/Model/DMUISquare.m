//
//
//  DMUISquare.m
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

#import "DMUISquare.h"

@interface DMUISquare ()
@end

@implementation DMUISquare

- (void)renderInContext:(CGContextRef)aContext
{
    CGContextSaveGState(aContext);
    CGContextSetFillColorWithColor(aContext, self.fillColor.CGColor);
    CGContextFillRect(aContext, self.bounds);
    CGContextRestoreGState(aContext);
}
@end
