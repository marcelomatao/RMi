//
//  Viewer2D.h
//  RMi
//
//  Created by Marcelo da Mata on 29/05/2013.
//
//

#import "VolumeSlices.h"

@interface Viewer2D : NSObject {
    @private
    GLint orientation;
    float thickness;
}

@property (nonatomic, strong) NSMutableArray *dicomFiles;
@property (nonatomic, strong) NSString *directory;

@property (nonatomic, strong) NSMutableArray *axialSlices;
@property (nonatomic, strong) NSMutableArray *sagitalSlices;
@property (nonatomic, strong) NSMutableArray *coronalSlices;

-(void)loadImages;
-(void)setOrientation: (GLint)o;
-(void)setThickness: (float)t;

@end
