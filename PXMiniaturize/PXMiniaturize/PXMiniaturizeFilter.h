//
//  PXMiniaturizeFilter.h
//  PXMiniaturize
//
//  Created by Andrey on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <QuartzCore/QuartzCore.h>

typedef enum 
{
    PXMiniaturizeFilterLinearEffectType=0, 
    PXMiniaturizeFilterEllipticalEffectType
} PXMiniaturizeFilterEffectType;


@interface PXMiniaturizeFilter : CIFilter {
    CIImage      *inputImage;
  
    NSNumber    *inputBlurRadius; //0.0-1.0
    NSNumber    *inputTransitionSize; //0.0-1.0
    NSNumber    *inputType;
    NSNumber    *inputAngle;
    
    //Linear
    CIVector    *inputLinearCenter;
    NSNumber    *inputLinearRadius;
    
    //Elliptical
    CIVector    *inputEllipse;
 
}

@end
