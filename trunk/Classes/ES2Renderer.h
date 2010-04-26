//
//  ES2Renderer.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Scene.h"

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
}

- (void)render:(Scene*)scene;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end

