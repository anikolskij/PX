//
//  PXMiniaturizeFilter.m
//  PXMiniaturize
//
//  Created by Andrey on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PXMiniaturizeFilter.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation PXMiniaturizeFilter

static CIKernel *_PXMiniaturizeFilterKernel = nil;
static CIKernel *_CreateLinearMaskKernel = nil;
static CIKernel *_CreateEllipticalMaskKernel = nil;
static CIKernel *_GaussianBlurKernel = nil;

static CIKernel *_HorizontalPassKernel = nil;
static CIKernel *_VerticalPassAndMixKernel = nil;

- (id)init
{
    if(!_PXMiniaturizeFilterKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"PXMiniaturizeFilterKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];

		_PXMiniaturizeFilterKernel = [kernels objectAtIndex:0];
        
        [_PXMiniaturizeFilterKernel retain];
    }
    
    if(!_CreateLinearMaskKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CreateLinearMaskKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
        
		_CreateLinearMaskKernel = [kernels objectAtIndex:0];
        
        [_CreateLinearMaskKernel retain];
    }
    
    if(!_CreateEllipticalMaskKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"CreateEllipticalMaskKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
        
		_CreateEllipticalMaskKernel = [kernels objectAtIndex:0];
        
        [_CreateEllipticalMaskKernel retain];
    }
    
    if(!_GaussianBlurKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"GaussianBlurKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
        
		_GaussianBlurKernel = [kernels objectAtIndex:0];
        
        [_GaussianBlurKernel retain];
    }
    
    if(!_HorizontalPassKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"HorizontalPassKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
        
		_HorizontalPassKernel = [kernels objectAtIndex:0];
        
        [_HorizontalPassKernel retain];
    }
    
    if(!_VerticalPassAndMixKernel) {
		NSBundle    *bundle = [NSBundle bundleForClass:NSClassFromString(@"PXMiniaturizeFilter")];
		NSStringEncoding encoding = NSUTF8StringEncoding;
		NSError     *error = nil;
		NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"VerticalPassAndMixKernel" ofType:@"cikernel"] encoding:encoding error:&error];
		NSArray     *kernels = [CIKernel kernelsWithString:code];
        
		_VerticalPassAndMixKernel = [kernels objectAtIndex:0];
        
        [_VerticalPassAndMixKernel retain];
    }
    
    return [super init];
}

- (CGRect)regionOf:(int)sampler  destRect:(CGRect)rect  userInfo:(NSNumber *)radius
{
    return CGRectInset(rect, -[radius floatValue], 0);
}

- (NSDictionary *)customAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputBlurRadius",kCIAttributeName,
             NSLocalizedString(@"Blur Radius", nil), kCIAttributeDisplayName, 
             kCIAttributeTypeDistance, kCIAttributeType, 
             @"NSNumber",kCIAttributeClass,
             [NSNumber numberWithFloat:0.0], kCIAttributeSliderMin,
             [NSNumber numberWithFloat:200.0], kCIAttributeSliderMax,
             [NSNumber numberWithFloat:10.0], kCIAttributeDefault,
             [NSNumber numberWithFloat:10.0], kCIAttributeIdentity,
             nil], 
            @"inputBlurRadius",

        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputTransitionSize",kCIAttributeName,
             NSLocalizedString(@"Transition Size", nil), kCIAttributeDisplayName, 
             kCIAttributeTypeDistance, kCIAttributeType, 
             @"NSNumber",kCIAttributeClass,
             [NSNumber numberWithFloat:1.0], kCIAttributeSliderMin,
             [NSNumber numberWithFloat:200.0], kCIAttributeSliderMax,
             [NSNumber numberWithFloat:10.0], kCIAttributeDefault,
             [NSNumber numberWithFloat:10.0], kCIAttributeIdentity,
             nil], 
            @"inputTransitionSize",
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputAngle",kCIAttributeName,
             NSLocalizedString(@"Angle", nil), kCIAttributeDisplayName, 
             kCIAttributeTypeAngle, kCIAttributeType, 
             @"NSNumber",kCIAttributeClass,
             [NSNumber numberWithFloat:-3.14], kCIAttributeSliderMin,
             [NSNumber numberWithFloat:3.14], kCIAttributeSliderMax,
             [NSNumber numberWithFloat:0.0], kCIAttributeDefault,
             [NSNumber numberWithFloat:0.0], kCIAttributeIdentity,
             nil], 
            @"inputAngle",
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputType",kCIAttributeName,
             NSLocalizedString(@"Tilt Type", nil), kCIAttributeDisplayName, 
             kCIAttributeTypeInteger, kCIAttributeType, 
             @"NSNumber",kCIAttributeClass,
             [NSNumber numberWithInt:0], kCIAttributeSliderMin,
             [NSNumber numberWithInt:1], kCIAttributeSliderMax,
             [NSNumber numberWithInt:0], kCIAttributeDefault,
             [NSNumber numberWithInt:0], kCIAttributeIdentity,
             nil], 
            @"inputType",
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputLinearCenter",kCIAttributeName,
             NSLocalizedString(@"Linear Center", nil), kCIAttributeDisplayName, 
             kCIAttributeTypePosition, kCIAttributeType,
             @"CIVector",kCIAttributeClass,
             [CIVector vectorWithX:0 Y:0], kCIAttributeSliderMin,
             [CIVector vectorWithX:500 Y:500], kCIAttributeSliderMax,
             [CIVector vectorWithX:0 Y:0], kCIAttributeDefault,
             [CIVector vectorWithX:0 Y:0], kCIAttributeIdentity,
             nil], 
            @"inputLinearCenter",
            
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputEllipse",kCIAttributeName,
             NSLocalizedString(@"Ellipse Rect", nil), kCIAttributeDisplayName, 
             //kCIAttributeTypeRectangle, kCIAttributeType,
             @"CIVector",kCIAttributeClass,
             [CIVector vectorWithX:0 Y:0 Z:200 W:200], kCIAttributeSliderMin,
             [CIVector vectorWithX:500 Y:500  Z:2000 W:2000], kCIAttributeSliderMax,
             [CIVector vectorWithX:0 Y:0 Z:200 W:200], kCIAttributeDefault,
             [CIVector vectorWithX:0 Y:0 Z:200 W:200], kCIAttributeIdentity,
             nil], 
            @"inputEllipse",
            
        [NSDictionary dictionaryWithObjectsAndKeys:
             @"inputLinearRadius",kCIAttributeName,
             NSLocalizedString(@"Linear Radius", nil), kCIAttributeDisplayName, 
             kCIAttributeTypeDistance, kCIAttributeType, 
             @"NSNumber",kCIAttributeClass,
             [NSNumber numberWithFloat:1.0], kCIAttributeSliderMin,
             [NSNumber numberWithFloat:200.0], kCIAttributeSliderMax,
             [NSNumber numberWithFloat:10.0], kCIAttributeDefault,
             [NSNumber numberWithFloat:10.0], kCIAttributeIdentity,
             nil], 
            @"inputLinearRadius",
            

        nil];
}


// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    if(inputImage == nil)
        return nil;
    
    // crop result 
    CGRect inputImageRect = [inputImage extent];
    float startx = inputImageRect.origin.x;
    float starty = inputImageRect.origin.y;
    float width = inputImageRect.size.width;
    float height = inputImageRect.size.height;
    
    if(width > 32000.0)
        width = 100.0;
    
    if(height > 32000.0)
        height = 100.0;
    
    CISampler *src;
    
    src = [CISampler samplerWithImage:inputImage];
    
    CIImage *maskImage;
    
    float maxSize = 0.0;
    
    if(width > height)
        maxSize = width;
    else
        maxSize = height;
    
    float kern[2][2];
    float radiusKernel = 0.9;
    double sigma = radiusKernel/2.0;
    
    int kernelWidth = 2;
    
    double sum = 0.0;
    for (int row = 0; row < kernelWidth; row++){
        for (int col = 0; col < kernelWidth; col++) {
            
            float gaussianRow = exp( -((((float)((float)row-radiusKernel))/(sigma))*(((float)((float)row-radiusKernel))/(sigma)))/2.0 );
            float gaussianCol = exp( -((((float)((float)col-radiusKernel))/(sigma))*(((float)((float)col-radiusKernel))/(sigma)))/2.0 );
            
            
            kern[row][col] = gaussianRow * gaussianCol;
            
            sum += kern[row][col];
        }
    }

    float linearRadius = [inputLinearRadius floatValue];    
    float transitionSize = [inputTransitionSize floatValue];
    float rotateAngle = [inputAngle floatValue];
   
    float radius = roundf([inputBlurRadius floatValue] / 20.0);   
        
    
    if([inputType boolValue] == PXMiniaturizeFilterLinearEffectType){
        
        // apply linear mask
        //    
        maskImage = [self apply:_CreateLinearMaskKernel, src, [NSNumber numberWithFloat: inputLinearCenter.X], [NSNumber numberWithFloat: inputLinearCenter.Y], [NSNumber numberWithFloat: linearRadius], [NSNumber numberWithFloat: transitionSize], [NSNumber numberWithFloat: rotateAngle], nil];
    }
    else{
        
        // apply elliptical mask
        //    
        maskImage = [self apply:_CreateEllipticalMaskKernel, src, [NSNumber numberWithFloat: inputEllipse.X], [NSNumber numberWithFloat: inputEllipse.Y], [NSNumber numberWithFloat: inputEllipse.Z], [NSNumber numberWithFloat: inputEllipse.W], [NSNumber numberWithFloat: transitionSize], [NSNumber numberWithFloat: rotateAngle], nil];
    }

   
 
    CIImage *horPassImage = [self apply:_HorizontalPassKernel, src, maskImage,
                             [NSNumber numberWithFloat:radius], 
                             [NSNumber numberWithFloat:width], nil];

    
    CIImage *vertPassImage = [self apply:_VerticalPassAndMixKernel, horPassImage, maskImage,
                              [NSNumber numberWithFloat: radius], [NSNumber numberWithFloat: height], nil];
    
    
    CIImage *img = vertPassImage;
  
    // make smoother blur
    //
    for(int i=0; i<1; i++){
        
        img = [self apply:_HorizontalPassKernel, img, maskImage,
                   [NSNumber numberWithFloat:radius], [NSNumber numberWithFloat:width], nil];
        
        img = [self apply:_VerticalPassAndMixKernel, img, maskImage,
                   [NSNumber numberWithFloat: radius], [NSNumber numberWithFloat: height], nil];
        
    }
      
    // apply smooth thransition
    //
    img = [self apply:_GaussianBlurKernel, img, maskImage, [NSNumber numberWithFloat:width], [NSNumber numberWithFloat:height], [NSNumber numberWithFloat:radius],  nil];

    
    //CIImage *img = maskImage;
    
    // crop result 
    CIFilter *preCrop = [CIFilter filterWithName:@"CICrop"];
    [preCrop setValue:[CIVector vectorWithX:startx Y:starty Z:width W:height] forKey:@"inputRectangle"];
    [preCrop setValue:img forKey:@"inputImage"];
    return [preCrop valueForKey:@"outputImage"];
}

@end
