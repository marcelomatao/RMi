//
//  DicomParser.m
//  RMi
//
//  Created by Marcelo da Mata on 03/01/12.
//
//

#import "DicomParser.h"
#import "Vertex.h"
#import "Mesh.h"
#import "Face3.h"
#import "Material.h"
#import "MaterialParser.h"
#import "NSScanner+Additions.h"
#import "Shape.h"
#import "ConstantsDicomRender.h"
#import "DicomDecoder.h"


@interface DicomParser () {
    
}

@end

@implementation DicomParser

- (id)initWithDicomFiles:(NSMutableArray *)dicomFiles : (NSString *) dir
{
    self = [super init];
    self.dicomFiles = dicomFiles;
    self.directory = dir;
    
    if (self) {
        
    }
    
    return self;
}
//depth = [[((NSMutableDictionary *)[dicomDecoder getValues]) objectForKey:[NSNumber numberWithInt:TAG_SPACING_SLICES]] floatValue];
//UIImage *img = [UIImage imageNamed:@"/Users/User/Desktop/images/galaxia.jpeg"];
//para cada arquivo DCM

/*
if ([volume getThickness] != (int)depth+1) {
    [volume setThickness:(int)depth+1];
}
 */

- (VolumeSlices *)parseAsDicom
{
    DicomDecoder *dicomDecoder;
    int width, height;
    float depth;
    float x1, x2, y1, y2, z1, z2;
    GLint direction;
    NSString *orientation;
    FileInfo *fi;
    VolumeSlices *volume = [[VolumeSlices alloc] init];
    
    for (NSString *file in self.dicomFiles) {
        dicomDecoder = [[DicomDecoder alloc] init:self.directory : file];
        if([dicomDecoder isDicom]) {
            [dicomDecoder decode];
            UIImage *img = [dicomDecoder getDicomImage];
            
            depth = [[((NSMutableDictionary *)[dicomDecoder getValues]) objectForKey:[NSNumber numberWithInt:TAG_SLICE_THICKNESS]] floatValue];
            
            [volume setThickness:(int)depth+1];
            
            orientation = [((NSMutableDictionary *)[dicomDecoder getValues]) objectForKey:[NSNumber numberWithInt:TAG_ORIENTATION_SLICES]];
            NSArray *valueOrientation = [orientation componentsSeparatedByString:@"\\"];
            orientation = nil;
            x1 = [[valueOrientation objectAtIndex:0] floatValue];
            y1 = [[valueOrientation objectAtIndex:1] floatValue];
            z1 = [[valueOrientation objectAtIndex:2] floatValue];
            x2 = [[valueOrientation objectAtIndex:3] floatValue];
            y2 = [[valueOrientation objectAtIndex:4] floatValue];
            z2 = [[valueOrientation objectAtIndex:5] floatValue];
            
            fi = [dicomDecoder getFileInfo];
            dicomDecoder = nil;
            width = [fi getWidth];
            height = [fi getHeight];
            
            float thickness = depth+1;
            BOOL points = true;
            
            Shape *slice = [[Shape alloc] initWithImage:img];
            [slice setOrientation: x1 :y1 :z1 :x2 :y2 :z2];
            direction = [slice calculateOrientation];
            [slice setThickness:depth];
            if (direction == SLICE_ORIENTATION_AXIAL) {
                [slice setSizes:width :[volume getNextZPosition: thickness] :height];
            } else if (direction == SLICE_ORIENTATION_SAGITAL) {
                [slice setSizes:[volume getNextZPosition: thickness] :height :width];
            } if (direction == SLICE_ORIENTATION_CORONAL) {
                [slice setSizes:width :height :[volume getNextZPosition: thickness]];
            }
                
            
            [slice generatePoints:points];
                
            [volume addSlice:slice :nil];
        }
    }
    
    return volume;
}

- (void)parseAsDicomWithSlice:(Shape *)slice
{
    //NSMutableDictionary *materials = [[NSMutableDictionary alloc] init];
    //Material *currentMaterial = nil;
        
    //[self parseFaceSlices :slice];
}

@end
