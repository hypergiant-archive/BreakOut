//
//  ModelElement.mm
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import "ModelElement.h"


@implementation ModelElement
@synthesize model, textureId;
+(GLuint)LoadTexture:(char *)fileName
{
	int width, height;
	char *buffer = esLoadPNG ( fileName, &width, &height );
	GLuint texId;
	
	if ( buffer == NULL )
	{
		NSLog( @"Error loading (%s) image.\n", fileName );
		return 0;
	}
	
	glGenTextures ( 1, &texId );
	glBindTexture ( GL_TEXTURE_2D, texId );
	
	glTexImage2D ( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buffer );
	glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	free ( buffer );
	glEnable(GL_TEXTURE_2D);
	return texId;
}


@end
