//
//  LODManager.h
//  iOBJ
//
//  Created by felipowsky on 31/01/13.
//
//

#import <Foundation/Foundation.h>

@class GraphicObject;

typedef enum {
    ScreenManagerTypeNormal,
    ScreenManagerTypeProgressiveMesh,
} ScreenManagerType;

@interface ScreenManager : NSObject

@property (nonatomic, readonly, strong) GraphicObject *currentGraphicObject;
@property (nonatomic, readonly) GLuint verticesCount;
@property (nonatomic) ScreenManagerType type;

- (id)initWithGraphicObject:(GraphicObject *)graphicObject;

- (void)setGraphicObject:(GraphicObject *)graphicObject ;
//- (void)generateProgressiveMeshWithPercentage:(GLuint)percentage;

@end
