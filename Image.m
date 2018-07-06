//
//  Image.m
//  RMi
//
//  Created by Marcelo da Mata on 06/02/2013.
//  Copyright (c) 2013 Marcelo da Mata. All rights reserved.
//

#import "Image.h"

@implementation Image

@synthesize dd = dd;
@synthesize fi = fi;



-(id)init:(DicomDecoder*) decoder{
    dd = decoder;
    fi = [dd getFileInfo];
    
    width = [fi getWidth];
    height = [fi getHeight];
    skipCount = [fi getOffset];
    [self loadPixels];
    [self create8BitImage];
    
    return self;
}

-(void)loadPixels {
    char* bytes = [dd getBytes];
    location = [dd getPosition];
    
    switch ([fi getType]) {
        case 1://case GRAY16_SIGNED
        case 2://case GRAY16_UNSIGNED
            bytesPerPixel = 2;
            [self skip:bytes];
            [self read16biImage:bytes];
            break;
        default:
            break;
    }
}

-(void)skip:(char *)bytes {
    
    byteCount = ((long long)width)*height*bytesPerPixel;
    if([fi getType]==BITMAP) {
        int scan = width/8, pad = width%8;
        if (pad>0) {
            scan++;
        }
        byteCount = scan*height;
    }
    nPixels = width*height;
    bufferSize = (int)(byteCount/25L);
    if (bufferSize<8192) {
        bufferSize = 8192;
    } else {
        bufferSize = (bufferSize/8192)*8192;
    }
    location = skipCount;
}

-(void)read16biImage:(char *)bytes {
    /*
     if(fi->compression>COMPRESSION_NONE || (fi->stripOffsets!=nil && fi->stripOffsets->lenght>1)) {
     return [self readCompressed16bitImage?bytes];
     }
     se for ler alguma imagem comprimida deve implementar esse if que se encontra no arquivo ImageReader.java na linha 102.
     */
    int pixelRead;
    unsigned char buffer[bufferSize];
    pixels = malloc(sizeof(short)*nPixels);
    long long totalRead = 0L;
    int base = 0;
    int count;
    //int value;
    int bufferCount;
    
    while (totalRead<byteCount) {
        if ((totalRead+bufferSize)>byteCount) {
            bufferSize = (int)(byteCount-totalRead);
        }
        bufferCount = 0;
        while (bufferCount<bufferSize) {//preenche o buffer
            count = [self read:buffer :bufferSize-bufferCount :bytes];
            if (count==0) {
                if (bufferCount>0) {
                    for (int i=bufferCount; i<bufferSize; i++) {
                        buffer[i] = 0;
                    }
                }
                totalRead = bufferCount;
                //erro de fim de arquivo se for preciso ver arquivo ImageReader.java na linha 122.
                break;
            }
            bufferCount += count;
        }
        totalRead += bufferSize;
        //show progress aqui, ImageReader.java linha 128.
        pixelRead = bufferSize/bytesPerPixel;
        if ([fi getIntelByteOrder]) {
            if ([fi getType]==GRAY16_SIGNED) {
                for (int i=base,j=0; i<(base+pixelRead); i++,j+=2) {
                    pixels[i] = (short)((((buffer[j+1]&0xff)<<8) | (buffer[j]&0xff))+32768);
                }
            } else {
                for (int i=base,j=0; i<(base+pixelRead); i++,j+=2) {
                    pixels[i] = (short)((((buffer[j+1]&0xff)<<8) | (buffer[j]&0xff)));
                }
            }
        } else {
            if ([fi getType]==GRAY16_SIGNED) {
                for (int i=base,j=0; i<(base+pixelRead); i++,j+=2) {
                    pixels[i] = (short)((((buffer[j]&0xff)<<8) | (buffer[j+1]&0xff))+32768);
                }
            } else {
                for (int i=base,j=0; i<(base+pixelRead); i++,j+=2) {
                    pixels[i] = (short)((((buffer[j]&0xff)<<8) | (buffer[j+1]&0xff)));
                }
            }
        }
        base += pixelRead;
    }
}

-(int)read:(unsigned char *)buffer :(int)len :(char*)bytesFile {
    int numBytes = 0;
    int pos = 0;
    while (location < [dd getBufferLenght] && pos < bufferSize) {
        buffer[pos] = bytesFile[location];
        location++;
        pos++;
        numBytes++;
    }
    return numBytes;
}

-(char*)create8BitImage {
    int size = width*height;
    pixels8 = malloc(size * sizeof(char));
    int value;
    int min = [self getMin], max = [self getMax];
    double scale = 256.0/(max-min+1);
    for (int i=0; i<size; i++) {
        value = (pixels[i]&0xffff)-min;
        if (value<0) {
            value = 0;
        }
        value = (int)(value*scale+0.5);
        if (value>255) {
            value = 255;
        }
        pixels8[i] = (char)value;
    }
    numPixels = size;
    return pixels8;
}

-(int)getMax {
    if(!minMaxSet) {
        [self findMinMax];
    }
    return maxPixel;
}

-(int)getMin {
    if(!minMaxSet) {
        [self findMinMax];
    }
    return minPixel;
}

-(void)findMinMax {
    int size = width*height;
    int value;
    minPixel = 65535;
    maxPixel = 0;
    for (int i=0; i<size; i++) {
        value = pixels[i]&0xffff;
        if (value<minPixel) {
            minPixel = value;
        }
        if (value > maxPixel) {
            maxPixel = value;
        }
    }
    minMaxSet = true;
}

-(int)getHeight {
    return height;
}

-(int)getWidth {
    return width;
}

-(char*)getPixels8 {
    return pixels8;
}

@end
