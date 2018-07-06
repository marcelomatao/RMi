//
//  VoxelsLayer.h
//  RMi
//
//  Created by Marcelo da Mata on 07/05/2013.
//
//

#import <UIKit/UIKit.h>
//#import "Voxel.h"
#import "Shape.h"

@interface VoxelsLayer: NSObject

@property (nonatomic, strong) NSMutableArray *voxels;

//-(void)addObject: (Voxel*)voxel;
-(void)addObject: (Shape*)voxel;

@end
