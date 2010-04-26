//
//  Brick.fsh
//  BreakOut
//
//  Created by Daniel Pasco on 3/19/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//
precision mediump float;                             

/**
 *	Inputs from our vertex shader
 */
varying vec2 v_texCoord;
varying vec4 v_vertColor;
uniform sampler2D s_texture;

void main()
{
//	vec4 texColor;
//	texColor = texture2D( s_texture, v_texCoord );
//	gl_FragColor = v_vertColor * texColor;
	gl_FragColor = texture2D( s_texture, v_texCoord );
}