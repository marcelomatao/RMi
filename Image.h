//
//  Image.h
//  RMi
//
//  Created by Marcelo da Mata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "DicomDecoder.h"

@interface Image : NSObject {
@private
    short *pixels;
    int location;
    int bytesPerPixel, bufferSize, nPixels;
    int skipCount;
    int minPixel, maxPixel;
    BOOL minMaxSet;
    long long byteCount;
    char *pixels8;
    int width, height, numPixels;
}

@property (nonatomic, strong) DicomDecoder *dd;
@property (nonatomic, strong) FileInfo *fi;

-(id)init:(DicomDecoder*) decoder;
-(void)loadPixels;
-(void)skip:(char*)bytes;
-(void)read16biImage:(char*)bytes;
-(int)read:(unsigned char*)buffer :(int)len :(char*)bytesFile;
-(char*)create8BitImage;
-(int)getMax;
-(int)getMin;
-(void)findMinMax;
-(int)getHeight;
-(int)getWidth;
-(char*)getPixels8;


@end
