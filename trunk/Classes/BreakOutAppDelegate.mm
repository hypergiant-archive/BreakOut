//
//  BreakOutAppDelegate.m
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import "BreakOutAppDelegate.h"
#import "EAGLView.h"

@implementation BreakOutAppDelegate

@synthesize window;
@synthesize glView;
@synthesize score;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
