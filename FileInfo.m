//
//  FileInfo.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "FileInfo.h"

@implementation FileInfo

- (id)init
{
    return self;
}

-(void)setFormat: (int) format {
    fileFormat = format;
}

-(void)setType: (int) type {
    fileType = type;
}

-(void)setNImages: (int) numImages {
    nImages = numImages;
}

-(void)setCompression: (int) compress {
    compression = compress;
}

-(void)setSamplesPerPixel: (int) samplesPPixel {
    samplesPerPixel = samplesPPixel;
}

-(void)setWidth: (int) w {
    width = w;
}

-(void)setHeight: (int) h {
    height = h;
}

-(void)setOffset: (int) o {
    offset = o;
}

-(void)setRedLength: (int) rLength {
    redLength = rLength;
}

-(void)setGreenLength: (int) gLength {
    greenLength = gLength;
}

-(void)setBlueLength: (int) bLength {
    blueLength = bLength;
}

-(void)setLutSize: (int) lut {
    lutSize = lut;
}

-(void)setLongOffset: (long long) lo {
    longOffset = lo;
}

-(void)setIntelByteOrder: (BOOL) intelOrder {
    intelByteOrder = intelOrder;
}

-(void)setWhiteIsZero: (BOOL) wIsZero {
    whiteIsZero = wIsZero;
}

-(void)setFileName: (NSString *) name {
    fileName = name;
}

-(void)setDirectory: (NSString *) dir {
    directory = dir;
}

-(void)setURL: (NSString *) u {
    url = u;
}

-(void)setUnit: (NSString *) u {
    unit = u;
}

-(void)setPixelWidth: (double) pWidth {
    pixelWidth = pWidth;
}

-(void)setPixelHeight: (double) pHeight {
    pixelHeight = pHeight;
}

-(void)setPixelDepth: (double) pDepth {
    pixelDepth = pDepth;
}

-(void)setReds: (char *) r {
    reds = r;
}

-(void)setGreens: (char *) g {
    greens = g;
}

-(void)setBlues: (char *) b {
    blues = b;
}



-(int)getFormat {
    return fileFormat;
}

-(int)getType {
    return fileType;
}

-(int)getNImages {
    return nImages;
}

-(int)getCompression {
    return compression;
}

-(int)getSamplesPerPixel {
    return samplesPerPixel;
}

-(int)getWidth {
    return width;
}

-(int)getHeight {
    return height;
}

-(int)getOffset {
    return offset;
}

-(int)getRedLength {
    return redLength;
}

-(int)getGreenLength {
    return greenLength;
}

-(int)getBlueLength {
    return blueLength;
}

-(int)getLutSize {
    return lutSize;
}

-(long long)getLongOffset {
    return longOffset;
}

-(BOOL)getIntelByteOrder {
    return intelByteOrder;
}

-(BOOL)getWhiteIsZero {
    return whiteIsZero;
}

-(NSString *)getFileName {
    return fileName;
}

-(NSString *)getDirectory {
    return directory;
}

-(NSString *)getURL {
    return url;
}

-(NSString *)getUnit {
    return unit;
}

-(double)getPixelWidth {
    return pixelWidth;
}

-(double)getPixelHeight {
    return pixelHeight;
}

-(double)getPixelDepth {
    return pixelDepth;
}

-(char *)getReds {
    return reds;
}

-(char *)getGreens {
    return greens;
}

-(char *)getBlues {
    return blues;
}

@end
