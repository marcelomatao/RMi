//
//  VolumeSlices.m
//  RMi
//
//  Created by Marcelo da Mata on 13/04/2013.
//
//

#import "VolumeSlices.h"
#import "ConstantsDicomRender.h"
#import "VoxelsGenerate.h"
#import "VoxelsLayer.h"
#import "Voxel.h"

int NUM_MAX_ROWS_COLUNS = 256;
int NUM_GENERATE_SLICES = 40;
int VAR_ADJUST = 8;

@interface VolumeSlices ()
{
    GLint firstOrientation;
    GLint orientationRender;
}

@end

@implementation VolumeSlices

@synthesize slicesAxial = slicesAxial;
@synthesize slicesCoronal = slicesCoronal;
@synthesize slicesSagital = slicesSagital;
@synthesize slicesInformations = slicesInformations;
@synthesize slicesValues = slicesValues;

@synthesize layers = layers;
@synthesize voxels = voxels;

-(id) init {
    self = [super init];
    
    slicesAxial = [[NSMutableArray alloc] init];
    slicesCoronal = [[NSMutableArray alloc] init];
    slicesSagital = [[NSMutableArray alloc] init];
    slicesInformations = [[NSMutableArray alloc] init];
    slicesValues = [[NSMutableArray alloc] init];
    
    self.pointsAxial = [[NSMutableArray alloc] init];
    self.pointsCoronal = [[NSMutableArray alloc] init];
    self.pointsSagital = [[NSMutableArray alloc] init];
    firstOrientation = -1;
    nextZPosition = 0.0f;
    axialCount = 0;
    sagitalCount = 0;
    coronalCount = 0;
    thickness = 0;
    
    layers = [[NSMutableArray alloc] init];
	voxels = [[NSMutableArray alloc] init];

    
    return self;
}

-(void) addSlice:(Shape *)slice :(NSString *)fileName {
    GLint orientation;
    if([slice getOrientation] == SLICE_ORIENTATION_AXIAL) {
        [slicesAxial addObject:slice];
        axialCount++;
        orientation = SLICE_ORIENTATION_AXIAL;
        [self.pointsAxial addObjectsFromArray:[slice getPoints]];
    } else if([slice getOrientation] == SLICE_ORIENTATION_CORONAL) {
        [slicesCoronal addObject:slice];
        coronalCount++;
        orientation = SLICE_ORIENTATION_CORONAL;
        [self.pointsCoronal addObjectsFromArray:[slice getPoints]];
    } else {
        [self.slicesSagital addObject:slice];
        sagitalCount++;
        orientation = SLICE_ORIENTATION_SAGITAL;
        [self.pointsSagital addObjectsFromArray:[slice getPoints]];
    }
    
    if (firstOrientation == -1) {
        firstOrientation = orientation;
    }
}

-(void) addSliceInformation:(NSMutableArray *)informations :(NSString *)fileName {
    [self.slicesInformations setValue:informations forKey:fileName];
}

-(void) addSliceValue:(NSMutableArray *)value :(NSString *)fileName {
    [self.slicesValues setValue:value forKey:fileName];
}

-(void)generateOtherDirection {
    voxels = [[NSMutableArray alloc] init];
    layers = [[NSMutableArray alloc] init];
    
    if(firstOrientation == SLICE_ORIENTATION_AXIAL && axialCount > 0) {
        [self calculateSagitalByAxial];
        [self calculateCoronalByAxial];
    } else if(firstOrientation == SLICE_ORIENTATION_CORONAL && coronalCount > 0) {
        [self calculateAxialByCoronal];
        //[self calculateSagitalByCoronal];
    } else if(firstOrientation == SLICE_ORIENTATION_SAGITAL && sagitalCount > 0) {
        //[self calculateAxialBySagital];
        //[self calculateCoronalBySagital];
    }
    
    [self initSlices];
}

-(void) initSlices {
    axialCount = slicesAxial.count;
    coronalCount = slicesCoronal.count;
    sagitalCount = slicesSagital.count;
    indexAxialSlicing = axialCount;
    indexCoronalSlicing = coronalCount;
    indexSagitalSlicing = sagitalCount;
}

-(void)generateVoxels {
    ///*
    NSMutableArray *slices = [[NSMutableArray alloc] init];
    
     if(firstOrientation == SLICE_ORIENTATION_AXIAL && axialCount > 0) {
         slices = slicesAxial;
         slicesCoronal = [[NSMutableArray alloc] init];
         slicesSagital = [[NSMutableArray alloc] init];
         sagitalCount = 0;
         coronalCount = 0;
     } else if(firstOrientation == SLICE_ORIENTATION_CORONAL && coronalCount > 0) {
         slices = slicesCoronal;
         slicesAxial = [[NSMutableArray alloc] init];
         slicesSagital = [[NSMutableArray alloc] init];
         sagitalCount = 0;
         axialCount = 0;
     } else if(firstOrientation == SLICE_ORIENTATION_SAGITAL && sagitalCount > 0) {
         slices = slicesSagital;         
         slicesCoronal = [[NSMutableArray alloc] init];
         slicesAxial = [[NSMutableArray alloc] init];
         axialCount = 0;
         coronalCount = 0;
     }
    
	VoxelsGenerate *generate = [[VoxelsGenerate alloc] init];
	layers = [generate generateVoxelsLayers: slices: firstOrientation: thickness];
	for(VoxelsLayer *layer in layers) {
		for(Voxel *voxel in layer.voxels) {
        //for(Shape *voxel in layer.voxels) {
			[self.pointsVoxels addObjectsFromArray:[voxel getPoints]];
			[voxels addObject: voxel];
		}
	}
     //*/
}

-(NSMutableArray *)getVoxels {
	if(voxels.count == 0) {
		[self generateVoxels];
	}
    
	return voxels;
    
}

-(void) calculateCoronalByAxial {
    if(axialCount > 0 && self.slicesCoronal.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesCoronal.count > 0);
        float nextZCoronalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = axialCount*thickness;
        
        for (int k = 0, l = 0; k < axialCount; k+=count, l++) {
            //for (int k = 0; k < axialCount; k++) {
            Shape *slice = [self.slicesAxial objectAtIndex:k];
            UIImage *img = slice.imageTexture;
            
            CGImageRef inImage = img.CGImage;
            
			CFDataRef dataRefImg;
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = rows/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice;
            int space = (rows-temp)/VAR_ADJUST;
            if(temp >= rows) {
                space = 0;
                temp = rows;
            }
			dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);
            
			//a n-esima linha da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < rows; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc((space + temp) * cols * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg :cols :(space + temp)];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_CORONAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:cols :(temp+space) :nextZCoronalPosition];
                    [newSlice generatePoints: points];
                    nextZCoronalPosition += t;
					[self addSlice: newSlice: nil];
				} else {
					newSlice = [self.slicesCoronal objectAtIndex:x];
				}
                
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
				CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
				UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);
                
				for (int i = 0; i < cols; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*n + i];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*(l*thickness+j+space) + i];
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
			}
            CFRelease(dataRefImg);
        }
    }
}

-(void) calculateSagitalByAxial {
    if(axialCount > 0 && self.slicesSagital.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesSagital.count > 0);
        float nextZSagitalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = axialCount*thickness;
        
		for (int k = 0, l = 0; k < axialCount; k+=count, l++) {
            //for (int k = 0; k < axialCount; k++) {
			Shape *slice = [self.slicesAxial objectAtIndex:k];
			UIImage *img = slice.imageTexture;
            
			//implementar valor da razao da quantidade de colunas pela quantidade de fatias
            
			CGImageRef inImage = img.CGImage;
            
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = cols/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice;
            int space = (cols-temp)/VAR_ADJUST;
            if(temp >= cols) {
                space = 0;
                temp = cols;
            }
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);            
            
			//a n-esima coluna da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < cols; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc(rows * (temp + space) * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg:rows :temp + space];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_SAGITAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:nextZSagitalPosition :(temp+space) :rows];
                    [newSlice generatePoints: points];
                    nextZSagitalPosition += t;
					[self addSlice: newSlice: nil];
				} else {
					newSlice = [self.slicesSagital objectAtIndex:x];
				}
                
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
				CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
				UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);                
                
				for (int i = 0; i < rows; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*i + n];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*(l*thickness+space+j) + i];
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
			}
            CFRelease(dataRefImg);
		}
    }
}

-(void) calculateAxialByCoronal {    
    if(coronalCount > 0 && self.slicesAxial.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesAxial.count > 0);
        float nextZSagitalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = coronalCount*thickness;//qtd de linhas inicial
        
        for (int k = 0, l = 0; k < coronalCount; k+=count, l++) {
            //for (int k = 0; k < coronalCount; k++) {
            
			Shape *slice = [self.slicesCoronal objectAtIndex:k];
			UIImage *img = slice.imageTexture;
            
			//implementar valor da razao da quantidade de colunas pela quantidade de fatias
            
			CGImageRef inImage = img.CGImage;
            
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = rows/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice-1;
            int space = (rows-temp)/VAR_ADJUST;
            if(temp >= rows) {
                space = 0;
                temp = rows;
            }
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);
            
			//a n-esima linha da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < rows; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc(cols * (temp + space) * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg:cols :temp + space];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_AXIAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:rows :nextZSagitalPosition: (temp+space)];
                    [newSlice generatePoints: points];
                    nextZSagitalPosition += t;
					[self addSlice: newSlice: nil];                    
				} else {
					newSlice = [self.slicesAxial objectAtIndex:x];
				}
                
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
                CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
                UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);

                for (int i = 0; i < cols; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*n + i];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*(l*thickness+space+j) + i];
                        
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                  
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
            }
            CFRelease(dataRefImg);
		}
    }
}

-(void) calculateSagitalByCoronal {
    if(coronalCount > 0 && self.slicesSagital.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesSagital.count > 0);
        float nextZSagitalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = coronalCount*thickness;//qtd de linhas inicial
        //coronalCount
        for (int k = 0, l = 0; k < coronalCount; k+=count, l++) {
            //for (int k = 0; k < coronalCount; k++) {
            
			Shape *slice = [self.slicesCoronal objectAtIndex:k];
			UIImage *img = slice.imageTexture;
            
			//implementar valor da razao da quantidade de colunas pela quantidade de fatias
            
			CGImageRef inImage = img.CGImage;
            
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = cols/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice-1;
            int space = (cols-temp)/VAR_ADJUST;
            if(temp >= cols) {
                space = 0;
                temp = rows;
            }
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);
            
			//a n-esima linha da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < cols; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc(rows * (temp + space) * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg:(temp+space): rows];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_SAGITAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:rows: (temp+space): nextZSagitalPosition];
                    [newSlice generatePoints: points];
                    nextZSagitalPosition += t;
                     
					[self addSlice: newSlice: nil];
				} else {
					newSlice = [self.slicesAxial objectAtIndex:x];
				}
                
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
                CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
                UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);
                
                for (int i = 0; i < rows; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*i + n];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*i + (l*thickness+space+j)];
                        
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
            }
            CFRelease(dataRefImg);
		}
    }
}

-(void) calculateAxialBySagital {
    if(sagitalCount > 0 && self.slicesAxial.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesAxial.count > 0);
        float nextZSagitalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = sagitalCount*thickness;
        
        for (int k = 0, l = 0; k < sagitalCount; k+=count, l++) {
            //for (int k = 0; k < sagitalCount; k++) {
            
			Shape *slice = [self.slicesSagital objectAtIndex:k];
			UIImage *img = slice.imageTexture;
            
			//implementar valor da razao da quantidade de colunas pela quantidade de fatias
            
			CGImageRef inImage = img.CGImage;
            
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = rows/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice-1;
            int space = (rows-temp)/VAR_ADJUST;
			
			if(temp >= rows) {
                space = 0;
                temp = rows;
            }
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);
            
			//a n-esima linha da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < rows; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc(temp + space) * cols * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg:cols: (temp+space)];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_AXIAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:cols: nextZSagitalPosition: (temp+space)];
                    [newSlice generatePoints: points];
                    nextZSagitalPosition += t;
                     
					[self addSlice: newSlice: nil];
				} else {
					newSlice = [self.slicesAxial objectAtIndex:x];
				}
				
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
                CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
                UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);
                
                for (int i = 0; i < cols; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*n + i];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*(l*thickness+space+j) + i];
                        
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
            }
            CFRelease(dataRefImg);
		}
    }
}

-(void) calculateCoronalBySagital {
    if(sagitalCount > 0 && self.slicesCoronal.count == 0) {
        BOOL points = true;
        BOOL create = (self.slicesCoronal.count > 0);
        float nextZSagitalPosition = 0.0f;
        float t = 1.0f;
        int count = 1;
        int temp = sagitalCount*thickness;
        
        for (int k = 0, l = 0; k < sagitalCount; k+=count, l++) {
            //for (int k = 0; k < sagitalCount; k++) {
            
			Shape *slice = [self.slicesSagital objectAtIndex:k];
			UIImage *img = slice.imageTexture;
            
			//implementar valor da razao da quantidade de colunas pela quantidade de fatias
            
			CGImageRef inImage = img.CGImage;
            
			int rows = img.size.height;
			int cols = img.size.width;
            int numGenerateSlice = cols/NUM_GENERATE_SLICES;//quantidade de slices aproximada que serao geradas
            t = numGenerateSlice-1;
            int space = (cols-temp)/VAR_ADJUST;
			
			if(temp >= cols) {
                space = 0;
                temp = cols;
            }
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt32 * pixelBufImg = (UInt32 *) CFDataGetBytePtr(dataRefImg);
            
			//a n-esima linha da k-esima imagem sera a k-esima linha da n-esima nova imagem
			for (int n = 0, x = 0; n < cols; n+=numGenerateSlice, x++) {
				Shape *newSlice;
				if(!create && (k == 0)) {
					newSlice = [slice copy];
                    
					UInt32 *pixelBufNewImg = malloc(temp + space) * rows * (sizeof(UInt32)));
                    newSlice.imageTexture = [self buff32BitsToUIImage:inImage :pixelBufNewImg: rows: (temp+space)];
                    
                    [newSlice setOrientation:SLICE_ORIENTATION_CORONAL];
                    [newSlice setThickness:t];
                    [newSlice setSizes:nextZSagitalPosition: cols: (temp+space)];
                    [newSlice generatePoints: points];
                    nextZSagitalPosition += t;
                     
					[self addSlice: newSlice: nil];
				} else {
					newSlice = [self.slicesCoronal objectAtIndex:x];
				}
				
				UIImage *newImg = newSlice.imageTexture;
                
				CGImageRef inNewImage = newImg.CGImage;
                
				int colsNewImg = newImg.size.width;
                CFMutableDataRef dataRefNewImg = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inNewImage)));
                UInt32 *pixelBufNewImg = (UInt32 *) CFDataGetMutableBytePtr(dataRefNewImg);
                
                for (int i = 0; i < rows; i++) {
                    for (int j = 0; j < thickness; j++) {
                        uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[cols*i + n];
                        uint8_t *rgbaPixelNew = (uint8_t *) &pixelBufNewImg[colsNewImg*n + i*(l*thickness+space+j)];
                        
                        int t0 = rgbaPixel[0];
                        int t1 = rgbaPixel[1];
                        int t2 = rgbaPixel[2];
                        int t3 = rgbaPixel[3];
                        
                        rgbaPixelNew[0] = t0;
                        rgbaPixelNew[1] = t1;
                        rgbaPixelNew[2] = t2;
                        rgbaPixelNew[3] = t3;
                    }
				}
                
				newSlice.imageTexture = [self buff32BitsToUIImage:inNewImage :pixelBufNewImg :CGImageGetWidth(inNewImage) :CGImageGetHeight(inNewImage)];
                CFRelease(dataRefNewImg);
            }
            CFRelease(dataRefImg);
		}
    }
}

-(UIImage *)buff32BitsToUIImage: (CGImageRef) inImage : (UInt32 *)pixels : (int) width : (int) height {
    CGContextRef ctx;
    int bitsPerComponent = 8;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst;
    
    ctx = CGBitmapContextCreate(pixels,
                                width,
                                height,
                                bitsPerComponent,
                                CGImageGetBytesPerRow(inImage),
                                CGImageGetColorSpace(inImage),
                                bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage* newUIImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGImageRelease(imageRef);
    
    return newUIImage;
}

-(UIImage *)buff8BitsToUIImage: (CGImageRef) inImage : (UInt8 *)pixels : (int) width : (int) height {
    CGContextRef ctx;
    int bitsPerComponent = 8;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    
    ctx = CGBitmapContextCreate(pixels,
                                width,
                                height,
                                bitsPerComponent,
                                CGImageGetBytesPerRow(inImage),
                                CGImageGetColorSpace(inImage),
                                bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage* newUIImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGImageRelease(imageRef);
    
    return newUIImage;
}

-(int) getPointsAxialCount {
    return self.pointsAxial.count;
}

-(int) getPointsSagitalCount {
    return self.pointsSagital.count;
}

-(int) getPointsCoronalCount {
    return self.pointsCoronal.count;
}

-(float)getNextZPosition:(float)t {
    float returnNextZPosition = nextZPosition;
    nextZPosition += t;
    return returnNextZPosition;
}

-(GLint) getFirstOrientation {
    return firstOrientation;
}

-(GLint) getOrientationRender {
    return orientationRender;
}

-(void) setOrientationRender: (GLint) o {
    orientationRender = o;
}

- (void) addSlicingAxial {
    if(indexAxialSlicing < axialCount) {
        indexAxialSlicing++;
    }
}

- (void) addSlicingSagital {
    if(indexSagitalSlicing < sagitalCount) {
        indexSagitalSlicing++;
    }
}

- (void) addSlicingCoronal {
    if(indexCoronalSlicing < coronalCount) {
        indexCoronalSlicing++;
    }
}

- (void) subSlicingAxial {
    if(indexAxialSlicing > 1) {
        indexAxialSlicing--;
    }
}

- (void) subSlicingSagital {
    if(indexSagitalSlicing > 1) {
        indexSagitalSlicing--;
    }
}

- (void) subSlicingCoronal {
    if(indexCoronalSlicing > 1) {
        indexCoronalSlicing--;
    }
}

- (int) getIndexAxialSlicing {
    return indexAxialSlicing;
}

- (int) getIndexCoronalSlicing {
    return indexCoronalSlicing;
}
- (int) getIndexSagitalSlicing {
    return indexSagitalSlicing;
}

- (int) getThickness {
    return thickness;
}

- (void) setThickness: (int)t {
    thickness = t;
}

-(NSMutableArray*) getAxialSlices {
    return slicesAxial;
}

-(NSMutableArray*) getCoronalSlices {
    return slicesCoronal;
}

-(NSMutableArray*) getSagitalSlices {
    return slicesSagital;
}

- (int) getFacesCount {
    if(firstOrientation == SLICE_ORIENTATION_AXIAL) {
        return slicesAxial.count*12;
    } else if(firstOrientation == SLICE_ORIENTATION_SAGITAL) {
        return slicesSagital.count*12;
    } else if(firstOrientation == SLICE_ORIENTATION_CORONAL) {
        return slicesCoronal.count*12;
    }
    return 0;
}

@end
