//
//  quad.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10, based on code provided by Guy English (http://kickingbear.com/blog/)
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//
#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
	GLubyte r;
	GLubyte g;
	GLubyte b;
	GLubyte a;
} Color4ub; // 4 bytes long

typedef struct {
	GLfloat r;
	GLfloat g;
	GLfloat b;
	GLfloat a;
} Color4f; // 16 bytes long


typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat z;
} Point3D;  // 12 bytes long

typedef struct {
	GLfloat u;
	GLfloat v;
} Texel;	// 8 bytes long

typedef struct {
	GLushort v1;
	GLushort v2;
	GLushort v3;
} IndexedTriangle;  // six bytes long

typedef struct {
	Point3D position;	// 12
	Point3D normal;		// 12 + 12 = 24
	Color4ub color;		// 4+ 24 = 28
	Texel texel;		// 8 + 28 = 36
} Vertex;

typedef struct {
	Point3D position;	// 12
	Point3D normal;		// 12 + 12 = 24
	Color4ub color;		// 8+ 24 = 32
	Texel texel;		// 6 + 32 = 38
	GLushort unused;	// 2 + 38 = 40
	GLfloat size;		// 4 + 40 = 44
} AlignedVertex;

typedef struct {
	Point3D position;	// 12
} NormalOffset;

typedef struct {
	Point3D position;	// 12
	Point3D normal;		// 12 + 12 = 24
} ColorOffset;

typedef struct {
	Point3D position;	// 12
	Point3D normal;		// 12 + 12 = 24
	Color4ub color;		// 8+ 24 = 32
} TexelOffset;

typedef struct {
	Point3D position;	// 12
	Point3D normal;		// 12 + 12 = 24
	Color4ub color;		// 8+ 24 = 32
	Texel texel;		// 6 + 32 = 38
	GLushort unused;	// 2 + 38 = 40
} SizeOffset;

#define kquadTriangleCount 2

#define kquadVertexIndexCount 6

extern GLushort quadCoordinateIndices[];
extern Vertex quadFullVertexList[6];