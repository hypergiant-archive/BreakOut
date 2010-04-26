//
//  Shader.fsh
//  photoleaf
//
//  Created by Daniel Pasco on 3/19/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//
precision mediump float;                             

uniform sampler2D s_texture;    
varying vec2 v_texCoord;
               
void main()                                          
{                   
	gl_FragColor = texture2D( s_texture, v_texCoord );
}      