//
//  FileInfo.h
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import <Foundation/Foundation.h>

@interface FileInfo : NSObject {
    @private
    int fileFormat;
    int fileType;
    int nImages;
    int compression;
    int samplesPerPixel;
    int width;
    int height;
    int offset;
    long long longOffset;
    BOOL intelByteOrder;
    BOOL whiteIsZero;
    NSString *fileName;
    NSString *directory;
    NSString *url;
    NSString *unit;
    double pixelWidth;
    double pixelHeight;
    double pixelDepth;
    char *reds;
    char *greens;
    char *blues;
    int redLength;
    int greenLength;
    int blueLength;
    int lutSize;
}

-(void)setFormat: (int) format;
-(void)setType: (int) type;
-(void)setNImages: (int) numImages;
-(void)setCompression: (int) compress;
-(void)setSamplesPerPixel: (int) samplesPPixel;
-(void)setWidth: (int) w;
-(void)setHeight: (int) h;
-(void)setOffset: (int) o;
-(void)setRedLength: (int) rLength;
-(void)setGreenLength: (int) gLength;
-(void)setBlueLength: (int) bLength;
-(void)setLutSize: (int) lut;
-(void)setLongOffset: (long long) lo;
-(void)setIntelByteOrder: (BOOL) intelOrder;
-(void)setWhiteIsZero: (BOOL) wIsZero;
-(void)setFileName: (NSString *) name;
-(void)setDirectory: (NSString *) dir;
-(void)setURL: (NSString *) u;
-(void)setUnit: (NSString *) u;
-(void)setPixelWidth: (double) pWidth;
-(void)setPixelHeight: (double) pHeight;
-(void)setPixelDepth: (double) pDepth;
-(void)setReds: (char *) r;
-(void)setGreens: (char *) g;
-(void)setBlues: (char *) b;

-(int)getFormat;
-(int)getType;
-(int)getNImages;
-(int)getCompression;
-(int)getSamplesPerPixel;
-(int)getWidth;
-(int)getHeight;
-(int)getOffset;
-(int)getRedLength;
-(int)getGreenLength;
-(int)getBlueLength;
-(int)getLutSize;
-(long long)getLongOffset;
-(BOOL)getIntelByteOrder;
-(BOOL)getWhiteIsZero;
-(NSString *)getFileName;
-(NSString *)getDirectory;
-(NSString *)getURL;
-(NSString *)getUnit;
-(double)getPixelWidth;
-(double)getPixelHeight;
-(double)getPixelDepth;
-(char *)getReds;
-(char *)getGreens;
-(char *)getBlues;

@end
