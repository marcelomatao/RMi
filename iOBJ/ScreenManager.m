//
//  LODManager.m
//  iOBJ
//
//  Created by felipowsky on 31/01/13.
//
//

#import "ScreenManager.h"
#import "GraphicObject.h"
#import "ProgressiveMesh.h"

@interface ScreenManager ()

@property (nonatomic, strong) GraphicObject *originalGraphicObject;
@property (nonatomic, strong) GraphicObject *graphicObjectWithProgressiveMesh;
@property (nonatomic, strong) ProgressiveMesh *progressiveMesh;
@property (nonatomic) GLuint lastProgressivePercentage;

@end

@implementation ScreenManager

- (id)initWithGraphicObject:(GraphicObject *)graphicObject
{
    self = [super init];
    
    if (self) {
        self.originalGraphicObject = graphicObject;
        self.type = ScreenManagerTypeNormal;
        self.graphicObjectWithProgressiveMesh = nil;
        //self.progressiveMesh = [[ProgressiveMesh alloc] initWithMesh:graphicObject.mesh];
        self.lastProgressivePercentage = 0.0f;
    }
    
    return self;
}

/*
- (void)generateProgressiveMeshWithPercentage:(GLuint)percentage
{
    if (self.originalGraphicObject) {        
        GLuint vertices = self.originalGraphicObject.mesh.points.count * (percentage * 0.01f);
        
        Mesh *newMesh = [self.progressiveMesh generateMeshWithVertices:vertices];
        
        self.graphicObjectWithProgressiveMesh = [[GraphicObject alloc] initWithMesh:newMesh];
        
        self.lastProgressivePercentage = percentage;
    }
}
 */

- (GraphicObject *)currentGraphicObject
{
    GraphicObject *graphicObject = self.originalGraphicObject;
    
    if (self.type == ScreenManagerTypeProgressiveMesh) {
        graphicObject = self.graphicObjectWithProgressiveMesh;
    
    }
    
    return graphicObject;
}

- (GLuint)verticesCount
{
    GLuint vertices = 0;
    
    if (self.type == ScreenManagerTypeProgressiveMesh) {
        //vertices = self.originalGraphicObject.mesh.points.count * (self.lastProgressivePercentage * 0.01f);
        
    } else {
        if(self.currentGraphicObject.getModeRender == AXIAL) {
            vertices = [self.currentGraphicObject.volume getPointsAxialCount];
        } else if(self.currentGraphicObject.getModeRender == SAGITAL) {
            vertices = [self.currentGraphicObject.volume getPointsSagitalCount];
        } else if(self.currentGraphicObject.getModeRender == CORONAL) {
            vertices = [self.currentGraphicObject.volume getPointsCoronalCount];
        }
    }
    
    return vertices;
}

- (void)setGraphicObject:(GraphicObject *)graphicObject {
    self.originalGraphicObject = graphicObject;
}

@end
