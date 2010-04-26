//
//  EAGLView.m
//  photoleaf
//
//  Created by Daniel Pasco on 3/19/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import "EAGLView.h"
#import "Scene.h"

#import "ES2Renderer.h"

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;

static Scene *scene;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
        renderer = [[ES2Renderer alloc] init];
		
        if (!renderer)
        {
            if (!renderer)
            {
                [self release];
                return nil;
            }
        }
		
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
		 scene = [[ Scene alloc ] init ];
		[ scene createScene ];
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
    }
	
    return self;
}

- (void)drawView:(id)sender
{
	 [ scene updateModel ];
    [renderer render:scene];
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
		
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.
			
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
		
        animating = FALSE;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event		 {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];

	[ scene touchesBegan:touch withLocation:&location ];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event		 {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	[ scene touchesMoved:touch withLocation:&location ];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event		 {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	[ scene touchesCancelled:touch withLocation:&location ];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event		
{ 	
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	[ scene touchesEnded:touch withLocation:&location ];
	
	for(UITouch * touch in touches)
	{
		CGPoint location = [ touch locationInView:self];
		if((location.y > 55 ) && (location.y < 155)) {
			NSLog(@"location is %2.2f, %2.2f", location.x, location.y);
			int x = location.x / 76.8;
			int y = (location.y - 55) / 25;
			NSLog(@"location is %i, %i", x, y);
			int index = (y*10) + x;
			[ scene dropBrick:index ];
		}
	}
}

- (void)dealloc
{
    [renderer release];
	
    [super dealloc];
}

@end
