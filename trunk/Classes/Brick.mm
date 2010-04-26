//
//  Brick.mm
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import "Brick.h"
#import "Scene.h"

#import "quad.h"

GLushort brickCoordinateIndices[] = {
	0,
	1,
	2,
	3,
	4,
	5};
/**
 *	RT = 1, 1
 *  LB = 0, 0
 *	First tex ordinate is left to right (0 to 1)
 *  Second text ordinate is bottom to top (0 to 1)
 */
Vertex brickFullVertexList[6] = {
	{
		{ 10.0f, 5.0f, 0.0f},		// RT	1, 1, 
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 1.0f},
	},
	{
		{-10.0f, 5.0f, 0.0f },	// LT	0, 1
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 1.0f},
	},
	{
		{ 10.0f, -5.0f, 0.0f },	// RB	1, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 0.000000f},
	},
	{
		{ -10.0f,  -5.0f, 0.0f},	// LB	0, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 0.000000f},
	},
	{
		{ 10.0f,  -5.0f, 0.0f },	// RB	1, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 0.000000f},
	},
	{
		{ -10.0f, 5.0f, 0.0f},	// LT	0, 1
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 1.0f},
	}
};

@implementation Brick
@synthesize index;
@synthesize dead;
@synthesize dropping;
@synthesize transX, transY;
@synthesize type;

static GLuint staticTextureId;

static GLuint	programObject;
static GLint	positionLoc;
static GLint	texCoordLoc;
static GLint	samplerLoc;
static GLint	modelTransformLoc;
static GLint	projectionMatrixLoc;
static GLint	vertexTagLoc;
static GLint	colorLoc;
static GLint	colorIndexLoc;
static Vertex *vertexData;
static GLfloat colorSet[5][4];
static GLfloat *vertexTags;
static GLfloat *colorIndex;
static ESMatrix staticModelMatrix;

+(GLuint)staticTextureId {
	return staticTextureId;
}

-(id)initWithIndex:(int)_index {
	if(self = [ super init ]) {
		self.index = _index;
		transX =  ((index % 10)*20) - 90;
		transY = 135 - ((index / 10) *10.0f);
		transZ = -1.6f;
		type = rand()%6;
		leftX = (float)(type % 3) * 0.33f;
		rightX = leftX + 0.33f;
		topY = (float)(type % 2) * 0.5f;
		bottomY = topY + 0.5f;
		tick = 0;
	}
	return self;
}

-(void)drop {
	dropping = YES;
}

-(void)setVertexData:(Vertex*)vert {
	if(dropping)  {
		transZ -= 4.0f;
	}
	
	if(tumbling) {
		rotX = (GLfloat)180*sin(tick*M_PI/180);
		rotZ += 1.0f;	
		tick++;
	}

	if(transZ < -2000.0f) {
		dead = YES;
	}
	
	for(int j=0; j< 6; j++)
	{
		vert[j].position.x = brickFullVertexList[j].position.x + transX;
		vert[j].position.y = brickFullVertexList[j].position.y + transY;
		vert[j].position.z = brickFullVertexList[j].position.z + transZ;
	}	
	
	vert[0].texel.u =  rightX;
	vert[0].texel.v =  topY;

	// LT	0, 1
	vert[1].texel.u =  leftX;
	vert[1].texel.v =  topY;

	// RB	1, 0
	vert[2].texel.u =  rightX;
	vert[2].texel.v =  bottomY;

	// LB	0, 0
	vert[3].texel.u =  leftX;
	vert[3].texel.v =  bottomY;

	// RB	1, 0
	vert[4].texel.u =  rightX;
	vert[4].texel.v =  bottomY;

	// LT	0, 1
	vert[5].texel.u =  leftX;
	vert[5].texel.v =  topY;
}

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
		
		glGetProgramiv ( programObject, GL_INFO_LOG_LENGTH, &infoLen );
		
		if ( infoLen > 1 )
		{
			char* infoLog = (char*)malloc (sizeof(char) * infoLen );
			
			glGetProgramInfoLog ( programObject, infoLen, NULL, infoLog );
			esLogMessage ( "Error linking program:\n%s\n", infoLog );            
			
			free ( infoLog );
		}
	}
}

+(void)loadShaders
{
	// Create the program object
	if ( programObject == 0 ) {
		programObject = esLoadProgram ([ Brick getShaderSourceFromResource:@"Brick" extension:@"vsh"],  
									   [ Brick getShaderSourceFromResource:@"Brick" extension:@"fsh"]);
		if ( programObject == 0 ) {
			NSLog(@"Error creating Brick shaders");
			return;
		}
		
		positionLoc = glGetAttribLocation ( programObject, "a_position" );
		texCoordLoc = glGetAttribLocation ( programObject, "a_texCoord" );
		samplerLoc = glGetUniformLocation ( programObject, "s_texture" );
		vertexTagLoc = glGetAttribLocation ( programObject, "a_vertexTag" );
		colorIndexLoc = glGetAttribLocation ( programObject, "a_colorIndex" );

		modelTransformLoc = glGetUniformLocation ( programObject, "u_mvp_matrix" );
		projectionMatrixLoc = glGetUniformLocation ( programObject, "u_project_matrix" );
		colorLoc = glGetUniformLocation ( programObject, "u_color" );
	}
	
	if(staticTextureId == 0) {
		
		colorSet[0][0] = 1.0f;
		colorSet[0][1] = 0.0f;
		colorSet[0][2] = 0.0f;
		colorSet[0][3] = 1.0f;
		
		colorSet[1][0] = 0.0f;
		colorSet[1][1] = 1.0f;
		colorSet[1][2] = 0.0f;
		colorSet[1][3] = 1.0f;
		
		colorSet[2][0] = 0.0f;
		colorSet[2][1] = 0.0f;
		colorSet[2][2] = 1.0f;
		colorSet[2][3] = 1.0f;
		
		esMatrixLoadIdentity(&staticModelMatrix);
		esTranslate(&staticModelMatrix, 0.0f, 0.0f, -220.6f);

		staticTextureId = [ ModelElement LoadTexture:"brickatlas" ];
		vertexData =  (Vertex*)malloc(sizeof(Vertex)*kNumBricks*6);
		vertexTags = (GLfloat *)malloc(sizeof(GLfloat)*kNumBricks*6);
		colorIndex = (GLfloat *)malloc(sizeof(GLfloat)*kNumBricks*6);
		
		int brickIndex = 0;
		for(int i = 0; i< kNumBricks*6; i+=6) {
			GLfloat *vertTags = &(vertexTags[i]);
			GLfloat *colorIndices = &(colorIndex[i]);
			
			int colorIndex = rand()%6;
			for(int j=0; j< 6; j++) {
				vertTags[j] = i;
				colorIndices[j] = colorIndex;
			}
			brickIndex++;
		}
	}
}

+(void)bindShaders
{

}

+(void)drawBricks:(Scene*)scene  withProjectionMatrix:(ESMatrix*)projection{
	NSMutableArray *deadBricks = [ NSMutableArray array ];
	for(int i = 0; i< [ scene.bricks count ]; i++) {
		Brick *brick = [ scene.bricks objectAtIndex:i ];
		[ brick setVertexData:&(vertexData[(i*6)]) ];
		if(brick.dead) [ deadBricks addObject:brick ];
	}
	
	glUseProgram(programObject);
	glUniformMatrix4fv(modelTransformLoc, 1, false, (GLfloat*)&staticModelMatrix );		
	glUniformMatrix4fv(projectionMatrixLoc, 1, false, (GLfloat*)projection );	
	
	// Load the vertex attributes
	glEnableVertexAttribArray ( positionLoc );	
	glEnableVertexAttribArray ( texCoordLoc );	
	glEnableVertexAttribArray ( vertexTagLoc );	
	glEnableVertexAttribArray ( colorIndexLoc );	
	
	glVertexAttribPointer ( positionLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), &(vertexData[0]) );
	glVertexAttribPointer ( texCoordLoc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), &(vertexData[0].texel));
	glVertexAttribPointer ( vertexTagLoc, 1, GL_FLOAT, GL_FALSE, sizeof(GLfloat),  &(vertexTags[0]) );
	glVertexAttribPointer ( colorIndexLoc, 1, GL_FLOAT, GL_FALSE, sizeof(GLfloat),  &(colorIndex[0]) );
	
	glUniform4fv ( colorLoc, 3, &(colorSet[0][0]));	
	
	glActiveTexture ( GL_TEXTURE0 );
	glBindTexture ( GL_TEXTURE_2D, staticTextureId);
	glEnable ( GL_TEXTURE_2D );
	glUniform1i ( samplerLoc, 0 );
	
	glDrawArrays(GL_TRIANGLES, 0, kquadVertexIndexCount*[ scene.bricks count ]);

	glDisableVertexAttribArray ( positionLoc );	
	glDisableVertexAttribArray ( texCoordLoc );	
	glDisableVertexAttribArray ( vertexTagLoc );	
	glDisableVertexAttribArray ( colorIndexLoc );	
	
	for(Brick* brick in deadBricks) {
		[ scene removeBrick:brick ];
	}
}
@end
