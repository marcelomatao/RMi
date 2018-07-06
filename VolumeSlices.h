//
//  VolumeSlices.h
//  RMi
//
//  Created by Marcelo da Mata on 13/04/2013.
//
//

#import <Foundation/Foundation.h>
#import "Shape.h"


@interface VolumeSlices : NSObject {
    @private
    float nextZPosition;
    int thickness;
    int axialCount, coronalCount, sagitalCount;
    int indexAxialSlicing, indexSagitalSlicing, indexCoronalSlicing;
}

@property (nonatomic, strong) NSMutableArray *slicesAxial;
@property (nonatomic, strong) NSMutableArray *slicesCoronal;
@property (nonatomic, strong) NSMutableArray *slicesSagital;
@property (nonatomic, strong) NSMutableArray *slicesInformations;
@property (nonatomic, strong) NSMutableArray *slicesValues;

@property (nonatomic, strong) NSMutableArray *pointsAxial;
@property (nonatomic, strong) NSMutableArray *pointsCoronal;
@property (nonatomic, strong) NSMutableArray *pointsSagital;

@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic, strong) NSMutableArray *voxels;
@property (nonatomic, strong) NSMutableArray *pointsVoxels;

-(void) initSlices;
-(void) addSlice: (Shape *)slice : (NSString *)fileName;
-(void) addSliceInformation: (NSMutableArray *)informations : (NSString *)fileName;
-(void) addSliceValue: (NSMutableArray *)value : (NSString *)fileName;
-(void) generateOtherDirection;
-(int) getPointsAxialCount;
-(int) getPointsCoronalCount;
-(int) getPointsSagitalCount;
-(float) getNextZPosition: (float) thickness;
-(GLint) getFirstOrientation;
-(GLint) getOrientationRender;
-(void) setOrientationRender: (GLint) o;

- (void) addSlicingAxial;
- (void) addSlicingSagital;
- (void) addSlicingCoronal;
- (void) subSlicingAxial;
- (void) subSlicingSagital;
- (void) subSlicingCoronal;

- (int) getIndexAxialSlicing;
- (int) getIndexCoronalSlicing;
- (int) getIndexSagitalSlicing;
- (int) getThickness;
- (void) setThickness: (int)t;

-(void) calculateSagitalByAxial;
-(void) calculateCoronalByAxial;

-(void) calculateAxialByCoronal;
-(void) calculateSagitalByCoronal;

-(void)generateVoxels;
-(NSMutableArray *)getVoxels;

-(NSMutableArray*) getAxialSlices;
-(NSMutableArray*) getCoronalSlices;
-(NSMutableArray*) getSagitalSlices;

- (int) getFacesCount;

@end
