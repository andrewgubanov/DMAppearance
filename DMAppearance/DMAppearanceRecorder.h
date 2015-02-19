//
//
//  DMAppearanceRecorder.h
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

@import Foundation;

@interface DMAppearanceRecorder : NSProxy
+ (instancetype)appearanceRecorderForClass:(Class)aClass;
- (void)applyAppearanceForTarget:(id)aTarget;
@end
