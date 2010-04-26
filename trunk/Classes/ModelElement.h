//
//  ModelElement.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "esUtil.h"

@interface ModelElement : NSObject {
	ESMatrix *model;
	GLuint textureId;
}
+(GLuint)LoadTexture:(const char *)fileName;

@property ESMatrix *model;
@property GLuint textureId;
@end
