//
//  Voxel.m
//  RMi
//
//  Created by Marcelo da Mata on 07/05/2013.
//
//

#import "Voxel.h"
#import "ConstantsDicomRender.h"

GLint numVertex = 216;

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    
    //1
    0.0f, 0.0f, 0.0f,        0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, 0.0f,         0.0f, 0.0f, -1.0f,
    1.0f, 0.0f, 0.0f,         0.0f, 0.0f, -1.0f,
    0.0f, 0.0f, 0.0f,         0.0f, 0.0f, -1.0f,
    0.0f, 1.0f, 0.0f,          0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, 0.0f,         0.0f, 0.0f, -1.0f,
    
    //2
    0.0f, 0.0f, 0.0f,        -1.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 1.0f,       -1.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f,         -1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 0.0f,         -1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f,       -1.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 1.0f,        -1.0f, 0.0f, 0.0f,
    
    //3
    0.0f, 1.0f, 0.0f,         0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 0.0f,          0.0f, 1.0f, 0.0f,
    0.0f, 1.0f, 0.0f,          0.0f, 1.0f, 0.0f,
    0.0f, 1.0f, 1.0f,        0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
    
    //4
    1.0f, 0.0f, 0.0f,       1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, 1.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 0.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, 1.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 0.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    
    //5
    0.0f, 0.0f, 0.0f,          0.0f, -1.0f, 1.0f,
    1.0f, 0.0f, 0.0f,         0.0f, -1.0f, 1.0f,
    1.0f, 0.0f, 1.0f,         0.0f, -1.0f, 1.0f,
    0.0f, 0.0f, 0.0f,         0.0f, -1.0f, 1.0f,
    1.0f, 0.0f, 1.0f,         0.0f, -1.0f, 1.0f,
    0.0f, 0.0f, 1.0f,        0.0f, -1.0f, 1.0f,
    
    //6
    0.0f, 0.0f, 1.0f,        0.0f, 0.0f, 1.0f,
    1.0f, 0.0f, 1.0f,       0.0f, 0.0f, 1.0f,
    1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    1.0f, 1.0f, 1.0f,       0.0f, 0.0f, 1.0f,
    0.0f, 1.0f, 1.0f,        0.0f, 0.0f, 1.0f
};


@implementation Voxel

-(id)initWithPosition: (float)x : (float)y :  (float)z {
    
    self = [super init];
    
    if (self) {
        self.faces = [[NSMutableArray alloc] init];
        self.pointsSlice = [[NSMutableArray alloc] init];
        width = x;
        height = y;
        depth = z;
    }
    
    return self;
}

- (void)generatePointsWithColor: (float)r : (float)g : (float)b
{    
    Face3 *face[12];
    for (int i=0, l = 0; i<numVertex;) {
        face[l] = [[Face3 alloc] init];
        Vertex *vertex[3];
        for (int j=0; j<3; j++) {
            GLKVector3 point[3];
            GLKVector3 normal[3];
            vertex[j] = [[Vertex alloc] init];
            for (int k=0; k<3; k++) {
                point[j].v[k] = gCubeVertexData[i++];
            }
            for (int k=0; k<3; k++) {
                normal[j].v[k] = gCubeVertexData[i++];
            }
            
            if(direction == SLICE_ORIENTATION_AXIAL) {
                point[j].v[0] *= width;
                point[j].v[1] *= thickness;
                point[j].v[2] *= depth;
                point[j].v[1] += height;
            } else if(direction == SLICE_ORIENTATION_SAGITAL) {
                point[j].v[0] *= thickness;
                point[j].v[1] *= height;
                point[j].v[2] *= depth;
                point[j].v[0] += width;
            } else {
                point[j].v[0] *= width;
                point[j].v[1] *= height;
                point[j].v[2] *= thickness;
                point[j].v[2] += depth;
            }
            
            vertex[j].point = point[j];
            vertex[j].normal = normal[j];
        }
        face[l].vertices = [NSMutableArray arrayWithObjects:vertex[0], vertex[1], vertex[2], nil];
        [self setMaterialWithColor: r: g: b];
        face[l].material = self.material;
        [self addFace:face[l]];
        l++;
    }
    
}

-(void)setMaterialWithColor: (float)r : (float)g : (float)b  {
	NSString *name = @"";
	Material *currentMaterial = [[Material alloc] initWithName:name];
    
	GLKVector4 color = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
	currentMaterial.specularColor = color;
    
	GLKVector4 diffuseColor = GLKVector4Make(r, g, b, 1.0f);
	currentMaterial.diffuseColor = diffuseColor;
    
	GLKVector4 ambientColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
	currentMaterial.ambientColor = ambientColor;
    
	self.material = currentMaterial;
}

@end
