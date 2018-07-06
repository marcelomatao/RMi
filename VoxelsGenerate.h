//
//  VoxelsGenerate.h
//  RMi
//
//  Created by Marcelo da Mata on 18/05/2013.
//
//

#import <UIKit/UIKit.h>

@interface VoxelsGenerate: NSObject

-(NSMutableArray *) generateVoxelsLayers: (NSMutableArray *)slices : (int)orientation : (int)thickness;

@end
