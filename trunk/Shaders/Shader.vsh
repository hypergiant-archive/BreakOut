//
//  Shader.vsh
//  photoleaf
//
//  Created by Daniel Pasco on 3/19/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

uniform mat4	u_mvp_matrix;		// Modelview matrix
uniform mat4	u_project_matrix;	// Projection matrix
attribute vec2	a_texCoord;
attribute vec4	a_position;
varying vec2	v_texCoord;			// Texel for this vertex

void main()	{
	vec4 position = vec4(a_position);
	position.xy = a_position.xy;
	position.w = 1.0;
	gl_Position = u_project_matrix*u_mvp_matrix*position;
	v_texCoord = a_texCoord;
}