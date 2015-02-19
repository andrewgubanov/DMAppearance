//
//
//  DMAppearance.h
//  DMAppearance
//
//  Created by Andrew Gubanov on 19/02/15.
//  Copyright 2015 Andrew Gubanov. All rights reserved.
//
//

@import Foundation;

/*
 Appearance property selectors must be of the form:
 - (void)setProperty:(PropertyType)property forAxis1:(PropertyType)axis1 axis2:(PropertyType)axis2 axisN:(PropertyType)axisN;
 - (PropertyType)propertyForAxis1:(PropertyType)axis1 axis2:(PropertyType)axis2 axisN:(PropertyType)axisN;
 You may have no axes or as many as you like for any property. PropertyType may be any standard iOS type: id, BOOL NSInteger, NSUInteger, CGFloat, CGPoint, CGSize, CGRect. Exception will be thrown if any other type is met.
 */

@protocol DMAppearance <NSObject>
+ (instancetype)appearance;
@end
