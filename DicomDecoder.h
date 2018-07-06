//
//  DicomDecoder.h
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileDecoder.h"
#import "DicomDictionary.h"
#import "FileStream.h"

@interface DicomDecoder : FileDecoder {
    @private
        //int location;
        //int bufferLenght;
        int elementLenght;
        int vr; //valuer representation
        int previousGroup;
        double windowCenter;
        double windowWidth;
        double rescaleIntercept;
        double rescaleSlope;
        //unsigned char *bytes;
        BOOL dicmFound;
        BOOL littleEndian;
        BOOL bigEndianTransferSyntax;
        BOOL oddLocations;
        BOOL inSequence;
        //char buf8[8];
        //char buf10[11];
        NSString *previousInfo;
        NSString *dicomInfo;
        NSString *modality;
    
}

@property (nonatomic, strong) FileStream *dicomStream;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSMutableDictionary *informations;
@property (nonatomic, retain) UIImage *dicomImage;


-(id)init: (NSString *) dir : (NSString *) name;
-(BOOL)isDicom;


- (void)addInfo:(int) tag : (NSString*) value;
- (void)addInfoInt:(int) tag : (int) value;
- (NSString*)getHeaderInfo:(int) tag : (NSString*) value;
-(int)getNextTag;
-(int)getShort;
-(int)getInt;
-(int)getLenght;
-(float)getFloat;
-(double)getDouble;
- (void)getSpatialScale:(FileInfo*)fi : (NSString*)scale;
- (char*)getLut:(int) length;
-(void)generateUIImage:(UInt32*)buffer : (int) width :(int) height;
- (char*)getBytes;
- (long long)getPosition;
- (UIImage*)getDicomImage;
- (long long)getBufferLenght;
- (NSMutableDictionary *)getValues;
- (NSMutableDictionary *)getInformations;

-(int)indexOf:(NSString*)str : (NSString *)index;

@end
