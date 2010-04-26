//
//  ESRenderer.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Scene.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void)render:(Scene*)scene;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end
