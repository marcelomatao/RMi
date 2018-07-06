//
//  Slice.h
//  RMi
//
//  Created by Marcelo da Mata on 13/04/2013.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "MeshMaterial.h"

@interface Shape : MeshMaterial {
    @private
    int n;
    
    @protected
    float depth, width, height;
    float orientation[6];
    float thickness;
    BOOL haveColors;
    GLint direction;
}

@property (nonatomic, strong) UIImage *imageTexture;
@property (nonatomic, strong) NSMutableArray *pointsSlice;
@property (nonatomic, readwrite) GLKVector2 *pointsTexture;
@property (nonatomic, readwrite) GLuint pointsTextureLenght;
@property (nonatomic, readwrite) NSString *name;

@property (nonatomic, strong) NSMutableArray *faces;

-(id)init;
-(id)initWithImage: (UIImage *)image;
-(void)setOrientation: (float)x1 : (float)y1 : (float)z1 : (float)x2 : (float)y2 : (float)z2;
-(int)getOrientation;
-(void)setOrientation: (GLint) o;
-(void)setSizes: (float)widthNum : (float)heightNum : (float)depthNum; 
-(void)setDepth: (float)d;
-(float)getWidth;
-(float)getHeight;
-(float)getDepth;
-(float)getThickness;
-(void)setThickness: (float)t;
-(void)generatePoints: (BOOL)points;
-(int) calculateOrientation;
-(NSMutableArray *)getPoints;
-(BOOL)haveColors;
- (void)addFace:(Face3 *)face;

@end
