//
//  BreakOutAppDelegate.h
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//  Copyright Black Pixel Luminance 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface BreakOutAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	UILabel *score;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UILabel *score;
@end

