//
//  PXMiniaturizePlugInLoader.h
//  PXMiniaturize
//
//  Created by Andrey on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CoreImage.h>

@interface PXMiniaturizePlugInLoader : NSObject <CIPlugInRegistration>

- (BOOL)load:(void *)host;

@end
