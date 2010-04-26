//
//  ImageUtils.m
//  Common
//
//	Based on code from OpenGL® ES 2.0 Programming Guide - Book Website
//	Authors: Aaftab Munshi, Dan Ginsburg, Dave Shreiner
//	http://www.opengles-book.com/downloads.html
//
//  Created by Dan Ginsburg on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

char *esLoadUIImage(UIImage *image,int *width, int *height) {
    *width = CGImageGetWidth(image.CGImage);
    *height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( *height * *width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, *width, *height, 8, 4 * *width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGContextTranslateCTM (context, 0, *height);
	CGContextScaleCTM (context, 1.0, -1.0);    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, *width, *height ) );
    CGContextTranslateCTM( context, 0, *height - *height );
	
    CGContextDrawImage( context, CGRectMake( 0, 0, *width, *height ), image.CGImage );
	
    CGContextRelease(context);
	
	return imageData;
}

///
//	Load a 24-bit PNG file
//
char*  esLoadPNG ( char *fileName, int *width, int *height )
{
	NSString *filePath = [NSString stringWithUTF8String: fileName];
	NSString *path = [[NSBundle mainBundle] pathForResource: filePath ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    
	return esLoadUIImage(image,width, height);
}