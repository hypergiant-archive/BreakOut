//
//  Brick.vsh
//  BreakOut
//
//  Created by Daniel Pasco on 3/19/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//
precision mediump float;                             

uniform mat4	u_mvp_matrix;		// Modelview matrix
uniform mat4	u_project_matrix;	// Projection matrix
uniform vec4	u_color[3];

attribute vec2	a_texCoord;
attribute vec4	a_position;
attribute float	a_colorIndex;
attribute vec4	a_vertColor;
varying vec2		v_texCoord;			// Texel for this vertex
varying vec4		v_vertColor;

// unused
attribute float	a_vertexTag;

void main()	{
	vec4 position = vec4(a_position);
	position.xyz = a_position.xyz;
	position.w = 1.0;
	gl_Position = u_project_matrix*u_mvp_matrix*position;
	v_texCoord = a_texCoord;
	int colorIndex = int(a_colorIndex);
//	v_vertColor = u_color[colorIndex];
//	v_vertColor = u_color[0];
}