//
//  ES2Renderer.m
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import "ES2Renderer.h"
#import "esUtil.h"
#import "Scene.h"
#import "Paddle.h"

#import "quad.h"
// uniform index
enum {
	UNIFORM_MVP_MATRIX,
	UNIFORM_PROJECTION_MATRIX,
	UNIFORM_TEXTURE_UNIT,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

GLint attributes[NUM_ATTRIBUTES];

@interface ES2Renderer (PrivateMethods)
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ES2Renderer
static GLuint program;

+(char*)getShaderSourceFromResource:(NSString *)theShaderResourceName extension:(NSString *)theExtension
{
	NSLog(@"building shader %@.%@", theShaderResourceName, theExtension);
	NSBundle  *appBundle = [NSBundle mainBundle];
	
	NSString  *shaderTempSource = [appBundle pathForResource:theShaderResourceName 
													  ofType:theExtension];
	
	char *shaderSource = NULL;
	NSError *error;
	shaderTempSource = [ NSString stringWithContentsOfFile:shaderTempSource encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"%@\n", shaderTempSource);
	shaderSource     = (char *)[shaderTempSource cStringUsingEncoding:NSASCIIStringEncoding];
	
	return  shaderSource;
} 

+(void)logError
{
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		NSLog(@"Error executing request. glError: 0x%04X", err);
		GLint infoLen = 0;
		
		glGetProgramiv ( program, GL_INFO_LOG_LENGTH, &infoLen );
		
		if ( infoLen > 1 )
		{
			char* infoLog = (char*)malloc (sizeof(char) * infoLen );
			
			glGetProgramInfoLog ( program, infoLen, NULL, infoLog );
			esLogMessage ( "Error linking program:\n%s\n", infoLog );            
			
			free ( infoLog );
		}
	}
}
// Create an OpenGL ES 2.0 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
        {
            [self release];
            return nil;
        }

        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffers(1, &defaultFramebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    }

    return self;
}

-(void)renderBricks:(Scene*)scene  withProjectionMatrix:(ESMatrix*)projection{
	
	[ Brick drawBricks:scene   withProjectionMatrix:projection ];
}

-(void)renderBall:(Scene*)scene  withProjectionMatrix:(ESMatrix*)projection{
	glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, false, (GLfloat*)scene.ball.model );		
	glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, false, (GLfloat*)projection );	
	
	// Load the vertex attributes
	glEnableVertexAttribArray (attributes[ATTRIB_VERTEX]);
	glEnableVertexAttribArray (attributes[ATTRIB_TEXCOORD]);
	
	glVertexAttribPointer ( attributes[ATTRIB_VERTEX], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), &(quadFullVertexList[0].position) );
	glVertexAttribPointer ( attributes[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex),&(quadFullVertexList[0].texel) );
	
	glActiveTexture ( GL_TEXTURE0 );
	glBindTexture ( GL_TEXTURE_2D, scene.ball.textureId);
	glEnable ( GL_TEXTURE_2D );
	glUniform1i ( uniforms[UNIFORM_TEXTURE_UNIT], 0 );
	
	
	// Validate program before drawing. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
	if (![self validateProgram:program])
	{
		NSLog(@"Failed to validate program: %d", program);
		return;
	}
#endif
	
	// Draw
	glDrawArrays(GL_TRIANGLES, 0, kquadVertexIndexCount);
	glDisableVertexAttribArray (attributes[ATTRIB_VERTEX]);
	glDisableVertexAttribArray (attributes[ATTRIB_TEXCOORD]);
}

-(void)renderPaddle:(Scene*)scene  withProjectionMatrix:(ESMatrix*)projection{
	glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, false, (GLfloat*)scene.paddle.model );		
	glUniformMatrix4fv(uniforms[UNIFORM_PROJECTION_MATRIX], 1, false, (GLfloat*)projection );	
	
	// Load the vertex attributes
	glEnableVertexAttribArray (attributes[ATTRIB_VERTEX]);
	glEnableVertexAttribArray (attributes[ATTRIB_TEXCOORD]);
	
	glVertexAttribPointer ( attributes[ATTRIB_VERTEX], 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), &(quadFullVertexList[0].position) );
	glVertexAttribPointer ( attributes[ATTRIB_TEXCOORD], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex),&(quadFullVertexList[0].texel) );
	
	glActiveTexture ( GL_TEXTURE0 );
	glBindTexture ( GL_TEXTURE_2D, scene.paddle.textureId);
	glEnable ( GL_TEXTURE_2D );
	glUniform1i ( uniforms[UNIFORM_TEXTURE_UNIT], 0 );
	
	// Validate program before drawing. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
	if (![self validateProgram:program])
	{
		NSLog(@"Failed to validate program: %d", program);
		return;
	}
#endif
	
	// Draw
	glDrawArrays(GL_TRIANGLES, 0, kquadVertexIndexCount);
	glDisableVertexAttribArray (attributes[ATTRIB_VERTEX]);
	glDisableVertexAttribArray (attributes[ATTRIB_TEXCOORD]);
}

- (void)render:(Scene*)scene {
	
	// Replace the implementation of this method to do your own custom drawing
	ESMatrix projection;
	
    // This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];

    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	// Set up our viewing volume
	esMatrixLoadIdentity(&projection);
//	esOrtho(&projection, -100.0, 100.0, -150, 150, 1.0, 200.0);
		esFrustum(&projection, -100.0, 100.0, -150, 150, 220.0, 4000);
//	esFrustum(&projection, -1.0, 1.0, -1.5, 1.5, 1.5, 500.0);
    // Use shader program
    glUseProgram(program);

	[ self renderBricks:scene withProjectionMatrix:&projection  ];
	[ self renderBall	:scene withProjectionMatrix:&projection  ];
	[ self renderPaddle:scene withProjectionMatrix:&projection ];
	
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }

    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;

    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }

    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;

    return TRUE;
}

- (BOOL)loadShaders
{
	if ( program == 0 ) {
		program = esLoadProgram ([ ES2Renderer getShaderSourceFromResource:@"Shader" extension:@"vsh"],  
									   [ ES2Renderer getShaderSourceFromResource:@"Shader" extension:@"fsh"]);
		if ( program == 0 ) {
			NSLog(@"Error creating Brick shaders");
			return FALSE;
		}
		
		// Bind attribute locations
		// this needs to be done prior to linking
		attributes[ATTRIB_VERTEX] = glGetAttribLocation(program, "a_position");
		attributes[ATTRIB_TEXCOORD] = glGetAttribLocation(program, "a_texCoord");
		
		
		// Get uniform locations
		uniforms[UNIFORM_MVP_MATRIX] = glGetUniformLocation(program, "u_mvp_matrix");
		uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(program, "u_project_matrix");
		
		uniforms[UNIFORM_TEXTURE_UNIT] = glGetUniformLocation(program, "s_texture");
		
		NSLog(@"attributes[ATTRIB_VERTEX] = %i", attributes[ATTRIB_VERTEX]);
		NSLog(@"attributes[ATTRIB_TEXCOORD] = %i", attributes[ATTRIB_TEXCOORD]);
		
		NSLog(@"uniforms[UNIFORM_MVP_MATRIX] = %i", uniforms[UNIFORM_MVP_MATRIX]);
		NSLog(@"uniformsUNIFORM_PROJECTION_MATRIX = %i", uniforms[UNIFORM_PROJECTION_MATRIX]);
		NSLog(@"uniforms[UNIFORM_TEXTURE_UNIT] = %i", uniforms[UNIFORM_TEXTURE_UNIT]);
		[ Brick loadShaders ];
	}
    return TRUE;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffers(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}

@end
