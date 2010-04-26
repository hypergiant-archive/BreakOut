//
//  Scene.m
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//
//	Note: paddle handling code based on another BreakOut demo found during the development
//	of this app, written by Ray Wenderlich 
//	(http://www.raywenderlich.com/475/how-to-create-a-simple-breakout-game-with-box2d-and-cocos2d-tutorial-part-12)
//
#import "Scene.h"
#import "BreakOutAppDelegate.h"


@implementation Scene
@synthesize paddle;
@synthesize ball;
@synthesize bricks;

static 	SceneContactListener scl;
static		b2Fixture *paddleFixture;
static		b2Body *paddleBody;
static 	b2Body *groundBody;
static BOOL inPaddle;
-(void)createScene {
	b2AABB worldAABB;  
	worldAABB.lowerBound.Set(-100.0f, -150.0f);  
	worldAABB.upperBound.Set(100.0f, 150.0f);  
	b2Vec2 gravity(0.0f, 0.0f);  
	world = new b2World(gravity, true); 	
	self.paddle = [[[ Paddle alloc ] init ] autorelease ];
	self.ball = [[[ Ball alloc ] init ] autorelease ];
	self.bricks = [ NSMutableArray array ];
	bricksTable = [ [ NSMutableDictionary dictionary ] retain ];

	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0,0);

	groundBody = world->CreateBody(&groundBodyDef);

	b2PolygonShape groundBox;
	b2FixtureDef groundBoxDef;
	groundBoxDef.shape = &groundBox;
	groundBox.SetAsEdge(b2Vec2(-100,-150), b2Vec2(100, -150));
	
	b2Fixture * _bottomFixture = groundBody->CreateFixture(&groundBoxDef);
	groundBox.SetAsEdge(b2Vec2(-100,-150), b2Vec2(-100, 150));
	groundBody->CreateFixture(&groundBoxDef);
	groundBox.SetAsEdge(b2Vec2(-100, 150), b2Vec2(100, 150));
	groundBody->CreateFixture(&groundBoxDef);
	groundBox.SetAsEdge(b2Vec2(100, 150), b2Vec2(100, -150));
	groundBody->CreateFixture(&groundBoxDef);
	
	
	b2BodyDef ballBodyDef;
	ballBodyDef.type = b2_dynamicBody;
	ballBodyDef.position.Set(0, 80);
	ballBodyDef.userData = ball;
	b2Body * ballBody = world->CreateBody(&ballBodyDef);
	b2Fixture *_ballFixture;

	// Create circle shape
	b2CircleShape circle;
	circle.m_radius = 10;
	
	// Create shape definition and add to body
	b2FixtureDef ballShapeDef;
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 0.25f;
	ballShapeDef.friction = 0.f;
	ballShapeDef.restitution = 1.0f;
	_ballFixture = ballBody->CreateFixture(&ballShapeDef);
	b2Vec2 velocity = b2Vec2(10000000, -10000000);
	ballBody->SetLinearVelocity(velocity);
//	ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
//	b2Vec2 force = b2Vec2(10000000, -10000000);
//	ballBody->ApplyLinearImpulse(force, ballBodyDef.position);

	ballBody->SetUserData(self.ball);
	ballBody->SetLinearDamping(0.0f);
	b2BodyDef paddleBodyDef;
	paddleBodyDef.type = b2_dynamicBody;
	paddleBodyDef.position.Set(-80, -120);
	paddleBodyDef.userData = self.paddle;
	paddleBody = world->CreateBody(&paddleBodyDef);
	
	b2PolygonShape paddleBox;
	paddleBox.SetAsBox(20.0f, 5.0f);

	// Create shape definition and add to body
	b2FixtureDef paddleShapeDef;
	paddleShapeDef.shape = &paddleBox;
	paddleShapeDef.density = 10.0f;
	paddleShapeDef.friction = 0.4f;
	paddleShapeDef.restitution = 1.0f;
	paddleFixture = paddleBody->CreateFixture(&paddleShapeDef);
	//	ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
	paddleBody->SetUserData(self.paddle);
	
	for(int i= 0; i< kNumBricks; i++) {
		Brick *brick = [[ Brick alloc ] initWithIndex:i ];
		[ self.bricks addObject:brick ];
		[ bricksTable setObject:brick forKey:[ NSString stringWithFormat:@"%i", i ]];

		b2BodyDef brickBodyDef;
		brickBodyDef.type = b2_dynamicBody;
		brickBodyDef.position.Set(brick.transX, brick.transY);
		brickBodyDef.userData = brick;
		b2Body * brickBody = world->CreateBody(&brickBodyDef);
		b2Fixture *_brickFixture;
		
		
		b2PolygonShape brickBox;
		brickBox.SetAsBox(10.0f, 5.0f);
		// Create shape definition and add to body
		b2FixtureDef brickShapeDef;
		brickShapeDef.shape = &brickBox;
		brickShapeDef.density = 10.0f;
		brickShapeDef.friction = 0.f;
		brickShapeDef.restitution = 1.0f;
		brickShapeDef.filter.groupIndex = -8;

		_brickFixture = brickBody->CreateFixture(&brickShapeDef);
		//	ballBody->ApplyLinearImpulse(force, ballBodyDef.position);
		brickBody->SetUserData(brick);
		[ brick release ];
	}
	
	brickSounds[0] = [[AudioFX alloc] initWithPath:@"brick0.aif"];
	brickSounds[1] = [[AudioFX alloc] initWithPath:@"brick1.aif"];
	brickSounds[2] = [[AudioFX alloc] initWithPath:@"brick2.aif"];
	brickSounds[3] = [[AudioFX alloc] initWithPath:@"brick3.aif"];
	brickSounds[4] = [[AudioFX alloc] initWithPath:@"brick4.aif"];
	brickSounds[5] = [[AudioFX alloc] initWithPath:@"brick5.aif"];
	wallCollisionSound = [[AudioFX alloc] initWithPath:@"bounce.aif"];
	beat = [[AudioFX alloc] initWithPath:@"bass.aif"];
	scl.setScene(self);
	world->SetContactListener(&scl);
	
	b2PrismaticJointDef jointDef;
	b2Vec2 worldAxis(1.0f, 0.0f);
	jointDef.collideConnected = true;
	jointDef.Initialize(paddleBody, groundBody, 
					paddleBody->GetWorldCenter(), worldAxis);
	world->CreateJoint(&jointDef);
}

-(void)updateModel {
	static int counter = 0;
	if(counter == 0) {
		[ beat play ];
	}
	counter++;
	if(counter > 45) {
		counter = 0;
	}
	world->Step(1/30.0f, 10, 10);
	world->ClearForces();
	for(b2Body *body = world->GetBodyList(); body; body=body->GetNext()) {    
		b2Vec2 position = body->GetPosition();
		float32 angle = body->GetAngle();
		if(body->GetUserData() == self.ball) {
			esMatrixLoadIdentity(self.ball.model);
			esTranslate(self.ball.model, position.x, position.y, -220.6f);
			esRotate(self.ball.model, angle*180.0f/M_PI, 0.0f, 0.0f, 1.0f);
			esScale(self.ball.model, 20.0f, 20.0f, 1.0f);
		}
		else if([ (id)body->GetUserData() isKindOfClass:[ Brick class ]]) {
			Brick *brick = (Brick*)body->GetUserData();
			if(brick.dropping) {
				world->DestroyBody(body);
			}
		}
		else if(body->GetUserData() == self.paddle) {
			esMatrixLoadIdentity(self.paddle.model);
			esTranslate(self.paddle.model, position.x, -120.0f, -220.6f);
			esScale(self.paddle.model, 40.0f, 10.0f, 1.0f);
		}
	}
}

-(void)contactBegan:(b2Contact*)contact {

	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	if(bodyA->GetUserData() == self.ball) {
		if([ (id)bodyB->GetUserData() isKindOfClass:[ Brick class ]]) {
			NSLog(@"A->B: Contact happened");
			Brick *brick = (Brick*)bodyB->GetUserData();
			[ brickSounds[brick.type] play ];
			[ self dropBrick:brick.index ];
		}
		else {
			[ wallCollisionSound play ];
		}
	}
	else if(bodyB->GetUserData() == self.ball) {
		if([ (id)bodyA->GetUserData() isKindOfClass:[ Brick class ]]) {
			NSLog(@"B->A: Contact happened");
			Brick *brick = (Brick*)bodyA->GetUserData();
			[ brickSounds[brick.type] play ];
			[ self dropBrick:brick.index ];
		}
		else {
			[ wallCollisionSound play ];
		}
	}
}

-(void)postSolve:(b2Contact*)contact withImpulse:(b2ContactImpulse*)impulse {
//	b2Body* bodyA = contact->GetFixtureA()->GetBody();
//	b2Body* bodyB = contact->GetFixtureB()->GetBody();
//	if(bodyA->GetUserData() == self.ball) {
//		if([ (id)bodyB->GetUserData() isKindOfClass:[ Brick class ]]) {
//			
//		}
//	}
//	else if(bodyB->GetUserData() == self.ball) {
//		if([ (id)bodyA->GetUserData() isKindOfClass:[ Brick class ]]) {
//		}
//	}
	
}

- (void)touchesBegan:(UITouch *)touch withLocation:(CGPoint*)location	 {
	
//    if (mouseJoint != NULL) return;
//	
	location->x = ( location->x /3.84) - 100.0f;
	location->y = ( -location->y / 3.31) + 160.0f;
	
	b2Vec2 locationWorld = b2Vec2(location->x, location->y);
	
    if (paddleFixture->TestPoint(locationWorld)) {
	    NSLog(@"hiyo: %2.2f", location->y);
	    inPaddle = YES;

        b2MouseJointDef md;
        md.bodyA = groundBody;
        md.bodyB = paddleBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 1000.0f * paddleBody->GetMass();
		
        mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
        paddleBody->SetAwake(true);
		NSLog(@"Doing stuff.");
    }	
    else {
	    inPaddle = NO;
    }
	
}

- (void)touchesMoved:(UITouch *)touch withLocation:(CGPoint*)location	 {

	if (mouseJoint == NULL) return;
	location->x = ( location->x /3.84) - 100.0f;
	location->y = ( -location->y / 3.31) + 160.0f;
	b2Vec2 locationWorld = b2Vec2(location->x, location->y);
	mouseJoint->SetTarget(locationWorld);
}

- (void)touchesEnded:(UITouch *)touch withLocation:(CGPoint*)location	 {
	if (mouseJoint) {
		world->DestroyJoint(mouseJoint);
		mouseJoint = NULL;
	}
}

- (void)touchesCancelled:(UITouch *)touch withLocation:(CGPoint*)location	 {
	if (mouseJoint) {
		world->DestroyJoint(mouseJoint);
		mouseJoint = NULL;
	}
}
	
-(void)removeBrick:(Brick*)brick {
	[ bricksTable removeObjectForKey:[ NSString stringWithFormat:@"%i", brick.index ] ];
	[ bricks removeObject:brick ];
}

-(void)dropBrick:(int)index {
	static int score = 0;

	Brick *brick = [ bricksTable objectForKey:[ NSString stringWithFormat:@"%i", index ]];
	if(brick != nil) {
		[ brick drop ];
		score++;
	}
	BreakOutAppDelegate *boad = (BreakOutAppDelegate*)[UIApplication sharedApplication ].delegate;
	boad.score.text = [ NSString stringWithFormat:@"%i", score ];
}

-(void) runWorld {  
	// step the world forward  
	world->Step(1.0f/60.0f, 10, 10);  
}  

-(void)dealloc {
	[ bricksTable release ];
	[ super dealloc ];
}
@end
