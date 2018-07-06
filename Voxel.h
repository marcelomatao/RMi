//
//  Voxel.h
//  RMi
//
//  Created by Marcelo da Mata on 07/05/2013.
//
//

#import <UIKit/UIKit.h>
#import "Shape.h"

@interface Voxel : Shape

-(id)initWithPosition: (float)x : (float)y : (float)z;
-(void)generatePointsWithColor: (float)r : (float)g : (float)b;

@end
