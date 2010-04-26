//
//  Scene.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import <Foundation/Foundation.h>
#define kNumBricks 40

#import "Box2D.h"
#import "Paddle.h"
#import "Ball.h"
#import "Brick.h"
#import <AudioToolbox/AudioServices.h>				
#import "AudioFX.h"

@class Brick;

@interface Scene : NSObject {
	b2World *world;  
	Paddle *paddle;
	Ball *ball;
	NSMutableArray *bricks;
	NSMutableDictionary *bricksTable;
	b2MouseJoint *mouseJoint;
	AudioFX *brickSounds[6];
	AudioFX *wallCollisionSound;
	AudioFX *beat;
}

-(void)createScene;
-(void)dropBrick:(int)index;
-(void)removeBrick:(Brick*)brick;
-(void)updateModel;
-(void)contactBegan:(b2Contact*)contact;
-(void)postSolve:(b2Contact*)contact withImpulse:(b2ContactImpulse*)impulse;
- (void)touchesBegan:(UITouch *)touch withLocation:(CGPoint*)location;
- (void)touchesMoved:(UITouch *)touch withLocation:(CGPoint*)location;
- (void)touchesCancelled:(UITouch *)touch withLocation:(CGPoint*)location;
- (void)touchesEnded:(UITouch *)touch withLocation:(CGPoint*)location;

@property (retain, nonatomic) Paddle *paddle;
@property (retain, nonatomic) Ball *ball;
@property (retain, nonatomic) NSMutableArray *bricks;
@end

class SceneContactListener : public b2ContactListener
{
public:
	Scene *scene;
	
	void setScene(Scene* aScene) {
		scene = aScene;
	}
	void BeginContact(b2Contact* contact)
	{ // handle begin event 
		[ scene contactBegan:contact ];
	}
	void EndContact(b2Contact* contact)
	{ // handle end event 
	}
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
	{ // handle pre-solve event 
	}
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
	{ // handle post-solve event 
		[ scene postSolve:contact withImpulse:(b2ContactImpulse*)impulse ];

	}
};

