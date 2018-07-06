//
//  Viewer2D.m
//  RMi
//
//  Created by Marcelo da Mata on 29/05/2013.
//
//

#import "Viewer2D.h"
#import "DicomDecoder.h"
#import "Image.h"
#import "ConstantsDicomRender.h"

@implementation Viewer2D

@synthesize dicomFiles = dicomFiles;
@synthesize directory = directory;

@synthesize axialSlices = axialSlices;
@synthesize sagitalSlices = sagitalSlices;
@synthesize coronalSlices = coronalSlices;


-(void)loadImages {
    DicomDecoder *dicomDecoder;
    
    orientation = SLICE_ORIENTATION_AXIAL;
    for (NSString *file in dicomFiles) {
        dicomDecoder = [[DicomDecoder alloc] init:directory : file];
        if([dicomDecoder isDicom]) {
            [dicomDecoder decode];
            Image *img = [[Image alloc] init: dicomDecoder];
            UIImage *i = [self generateUIImageGrayScale:[img getPixels8]: [img getWidth]: [img getHeight]];
            if (orientation == SLICE_ORIENTATION_AXIAL) {
                [axialSlices addObject:i];
            } else if (orientation == SLICE_ORIENTATION_SAGITAL) {
                [sagitalSlices addObject:i];
            } else if (orientation == SLICE_ORIENTATION_CORONAL) {
                [coronalSlices addObject:i];
            }
        }
    }
}

-(void)setOrientation: (GLint)o {
    orientation = o;
}

-(void)setThickness: (float)t {
    thickness = t;
}

-(UIImage *) generateUIImageGrayScale:(char *) buffer : (int) width : (int) height {
    size_t bufferLength = width * height;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 8;
    size_t bytesPerRow = 1 * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    
    CGImageRef iref =  CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    YES,            // should interpolate
                                    renderingIntent);
    
    
    CGContextRef context = CGBitmapContextCreate(buffer,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef, bitmapInfo);
    
    if(context == NULL) {
        NSLog(@"Error context not created");
    }
    
    UIImage *image = nil;
    if(context) {
        
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    return image;
}

@end
