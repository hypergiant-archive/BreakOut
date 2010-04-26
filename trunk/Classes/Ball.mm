//
//  Ball.mm
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import "Ball.h"


@implementation Ball
-(id)init {
	if(self = [ super init ]) {
		self.model = (ESMatrix*)malloc(sizeof(ESMatrix));
		esMatrixLoadIdentity(self.model);
		esTranslate(self.model, -80.0f, -105.0f, -220.6f);
		esScale(self.model, 20.0f, 20.0f, 1.0f);
		textureId = [ ModelElement LoadTexture:"ball" ];
	}
	return self;
}
@end
