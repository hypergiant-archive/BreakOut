//
//  Brick.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import <Foundation/Foundation.h>

#import "Box2D.h"
#import "ModelElement.h"
#import "quad.h"
#import "Scene.h"
@class Scene;

@interface Brick : ModelElement {
	float transX, transY, transZ;
	float leftX, rightX, topY, bottomY;
	BOOL dropping;
	BOOL dead;
	int index;
	int type;
	float rotX, rotZ;
	BOOL tumbling;
	int tick;
}

-(id)initWithIndex:(int)index;
-(void)setVertexData:(Vertex*)vert;
-(void)drop;
+(GLuint)staticTextureId;
+(void)loadShaders;
+(void)bindShaders;
+(void)drawBricks:(Scene*)scene  withProjectionMatrix:(ESMatrix*)projection;

@property int index;
@property int type;
@property BOOL dropping;
@property BOOL dead;
@property float transX;
@property float transY;

@end
