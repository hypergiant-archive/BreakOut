//
//  quad.m
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import "quad.h"

GLushort quadCoordinateIndices[] = {
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
Vertex quadFullVertexList[6] = {
	{
		{ 0.5f, 0.5f, 0.0f},		// RT	1, 1, 
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 1.0f},
	},
	{
		{-0.5f, 0.5f, 0.0f },	// LT	0, 1
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 1.0f},
	},
	{
		{ 0.5f, -0.5f, 0.0f },	// RB	1, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 0.000000f},
	},
	{
		{ -0.5f,  -0.5f, 0.0f},	// LB	0, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 0.000000f},
	},
	{
		{ 0.5f,  -0.5f, 0.0f },	// RB	1, 0
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{0.995625f, 0.000000f},
	},
	{
		{ -0.5f, 0.5f, 0.0f},	// LT	0, 1
		{1.000000, 0.000000, 0.000000},
		{128, 0, 255, 200},
		{-0.005625f, 1.0f},
	}
};
