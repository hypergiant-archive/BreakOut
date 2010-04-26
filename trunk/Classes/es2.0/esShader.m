//
// Book:      OpenGL(R) ES 2.0 Programming Guide
// Authors:   Aaftab Munshi, Dan Ginsburg, Dave Shreiner
// ISBN-10:   0321502795
// ISBN-13:   9780321502797
// Publisher: Addison-Wesley Professional
// URLs:      http://safari.informit.com/9780321563835
//            http://www.opengles-book.com
//
//	Based on code from OpenGL® ES 2.0 Programming Guide - Book Website
//	Authors: Aaftab Munshi, Dan Ginsburg, Dave Shreiner
//	http://www.opengles-book.com/downloads.html
//
// ESShader.c
//
//    Utility functions for loading shaders and creating program objects.
//

///
//  Includes
//
#ifdef __cplusplus

extern "C" {
#endif
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#ifdef __cplusplus
}
#endif

#include "esUtil.h"
#include <stdlib.h>
//#include <strings.h>

//////////////////////////////////////////////////////////////////
//
//  Private Functions
//
//



//////////////////////////////////////////////////////////////////
//
//  Public Functions
//
//

//
///
/// \brief Load a shader, check for compile errors, print error messages to output log
/// \param type Type of shader (GL_VERTEX_SHADER or GL_FRAGMENT_SHADER)
/// \param shaderSrc Shader source string
/// \return A new shader object on success, 0 on failure
//
GLuint ESUTIL_API esLoadShader ( GLenum type, const char *shaderSrc )
{
	GLuint shader;
	GLint compiled;
   
	// Create the shader object
	shader = glCreateShader ( type );

	if ( shader == 0 )
		return 0;

	// Load the shader source
	glShaderSource ( shader, 1, &shaderSrc, NULL );
   	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error setting shader source 0x%04X", err);
	}
	
	// Compile the shader
	glCompileShader ( shader );
	err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error compiling shader source 0x%04X", err);
	}
	// Check the compile status
	
	glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );

   if ( !compiled ) 
   {
      GLint infoLen = 0;

      glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );
      
      if ( infoLen > 1 )
      {
         char* infoLog = malloc (sizeof(char) * infoLen );

         glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
         esLogMessage ( "Error compiling shader:\n%s\n", infoLog );            
         
         free ( infoLog );
      }

      glDeleteShader ( shader );
      return 0;
   }

   return shader;

}


//
///
/// \brief Load a vertex and fragment shader, create a program object, link program.
//         Errors output to log.
/// \param vertShaderSrc Vertex shader source code
/// \param fragShaderSrc Fragment shader source code
/// \return A new program object linked with the vertex/fragment shader pair, 0 on failure
//
GLuint ESUTIL_API esLoadProgram ( const char *vertShaderSrc, const char *fragShaderSrc )
{
   GLuint vertexShader;
   GLuint fragmentShader;
   GLuint programObject;
   GLint linked;

   // Load the vertex/fragment shaders
	esLogMessage ( "Compiling vertex shader\n");            
	vertexShader = esLoadShader ( GL_VERTEX_SHADER, vertShaderSrc );
	if ( vertexShader == 0 )
		return 0;

	esLogMessage ( "Compiling fragment shader\n");            
	fragmentShader = esLoadShader ( GL_FRAGMENT_SHADER, fragShaderSrc );
   if ( fragmentShader == 0 )
   {
      glDeleteShader( vertexShader );
      return 0;
   }

   // Create the program object
   programObject = glCreateProgram ( );
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error creating program 0x%04X", err);
	}
	
   if ( programObject == 0 )
      return 0;

	glAttachShader ( programObject, vertexShader );
	err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error attaching vertex shader 0x%04X", err);
	}

	glAttachShader ( programObject, fragmentShader );
	err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error attaching fragment shader 0x%04X", err);
	}
	
	// Link the program
	glLinkProgram ( programObject );
	err = glGetError();
	if (err != GL_NO_ERROR) {
		esLogMessage("error linking program 0x%04X", err);
	}
	
   // Check the link status
   glGetProgramiv ( programObject, GL_LINK_STATUS, &linked );

   if ( !linked ) 
   {
      GLint infoLen = 0;

      glGetProgramiv ( programObject, GL_INFO_LOG_LENGTH, &infoLen );
      
      if ( infoLen > 1 )
      {
         char* infoLog = malloc (sizeof(char) * infoLen );

         glGetProgramInfoLog ( programObject, infoLen, NULL, infoLog );
         esLogMessage ( "Error linking program:\n%s\n", infoLog );            
         
         free ( infoLog );
      }

      glDeleteProgram ( programObject );
      return 0;
   }

   // Free up no longer needed shader resources
   glDeleteShader ( vertexShader );
   glDeleteShader ( fragmentShader );

   return programObject;
}