//
//  Paddle.mm
//  BreakOut
//
//  Created by Daniel Pasco on 4/23/10.
//	Provided by Black Pixel (http://blackpixel.com) under the 
//	Creative Common Attribution License http://creativecommons.org/licenses/by/3.0/
//

#import "Paddle.h"


@implementation Paddle
-(id)init {
	if(self = [ super init ]) {
		self.model = (ESMatrix*)malloc(sizeof(ESMatrix));
		esMatrixLoadIdentity(self.model);
		esTranslate(self.model, -80.0f, -120.0f, -220.6f);
//		esTranslate(self.model, 0.0f, -220.0f, -1.5f);
		esScale(self.model, 40.0f, 10.0f, 1.0f);
		textureId = [ ModelElement LoadTexture:"paddle" ];
	}
	return self;
}
@end
