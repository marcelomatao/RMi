//
//  GraphicObject.h
//  iOBJ
//
//  Created by felipowsky on 08/01/12.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Mesh.h"
#import "Transform.h"
#import "VolumeSlices.h"

@class Camera;

typedef enum {
    GraphicObjectDisplayModeTexture,
    GraphicObjectDisplayModeSolid,
    GraphicObjectDisplayModeWireframe,
    GraphicObjectDisplayModePoint,
} GraphicObjectDisplayMode;

typedef enum {
    NORMAL, AXIAL, SAGITAL, CORONAL, VOXEL
} ModeRenderVolumeSlices;

@interface GraphicObject : NSObject {
    @private
    GLint firstModeRender, modeRender, nameSlice;
}

@property (nonatomic, strong) VolumeSlices *volume;
@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) Transform *transform;
@property (nonatomic, readonly) BOOL haveTextures;
@property (nonatomic, readonly) GLfloat width;
@property (nonatomic, readonly) GLfloat height;
@property (nonatomic, readonly) GLfloat depth;

- (id)initWithVolumeSlices:(VolumeSlices *)volume;
- (void)update;
- (void)drawWithDisplayMode:(GraphicObjectDisplayMode)displayMode camera:(Camera *)camera effect:(GLKBaseEffect *)  effect;
- (void) addSlicingAxial;
- (void) addSlicingSagital;
- (void) addSlicingCoronal;
- (void) subSlicingAxial;
- (void) subSlicingSagital;
- (void) subSlicingCoronal;
- (void) setupCamera;
- (void) setModeRender: (ModeRenderVolumeSlices) mode;
- (ModeRenderVolumeSlices) getModeRender;

- (VolumeSlices*) getVolume;


@end
