//
//  VoxelsGenerate.m
//  RMi
//
//  Created by Marcelo da Mata on 18/05/2013.
//
//

#import "Voxel.h"
#import "ConstantsDicomRender.h"
#import "VoxelsGenerate.h"
#import "VoxelsLayer.h"

@implementation VoxelsGenerate


/*
-(NSMutableArray *) generateVoxelsLayers: (NSMutableArray *)slices: (int)orientation: (int)thickness {
	NSMutableArray *layers = [[NSMutableArray alloc] init];
    
	float width = 0;
	float height = 0;
	float r = 0.0f;
	float g = 0.0f;
	float b = 0.0f;
	if(orientation == SLICE_ORIENTATION_AXIAL) {
		//ALTERAR O TIPO DO DEPTH PARA INT NA CLASSE SHAPE
		//conceitualmente existe um grid cubo com slice.width por slice.height por numero de slices dimensoes.
		//pegar cada posiÁ„o de uma image i pertencente a um slice s que pertence ao conjunto S de slices.
		//executar esses passos para cada slice dentro de S.
		//
		//pegar o slice sy e recuperar a imagem i encapsulada nele. Cria uma camada c para inserir todos os voxels gerados por esse slice
		//pegar o width e o depth e percorrer todos o pixels.
		//para cada pixel p(x,sy,z) fazer.
		//
		//se a cor do pixel for clara, criar um voxel com dimensao 1 x thickness x 1 na posicao (x,sy,z) na camada cy
        
		//for (int s = 0; s < [slices count]; s++) {
        for (int s = 0; s < 1; s++) {
            NSLog(@"%d", s);
			VoxelsLayer *layer = [[VoxelsLayer alloc] init];
			Shape *sy = [slices objectAtIndex:s];
            
			//width = z
			width = [sy getDepth];
			//height = x
			height = [sy getWidth];
            
			//recupera aqui o valor da imagem e dos pixels
			UIImage *i = sy.imageTexture;
            CGImageRef inImage = i.CGImage;
            
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt8 * pixelBufImg = (UInt8 *) CFDataGetBytePtr(dataRefImg);
            
			//for (int x = 0; x < height; x++) {
            for (int x = 100; x < 105; x++) {
				//for (int z = 0; z < width; z++) {
                for (int z = 0; z < 20; z++) {
					//ver aqui o valor do pixels
					//Ver os valores para ver quais sao os canais corretos. Se o alpha for iguai a 255
					//vezes 4 porque sao 4 canais
                    
					uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[(int)width*x + z];
                    
                    int t0 = rgbaPixel[0];
                    int t1 = rgbaPixel[1];
                    int t2 = rgbaPixel[2];
                    int t3 = rgbaPixel[3];
                    
					//if(rgbaPixel[3]==255) {
						//adiciona um voxel na posicao (x,s,z) com espessura = [sy getThickness]
						//na camada camada corrente
						r = (rgbaPixel[2]/255)*100;
						g = (rgbaPixel[1]/255)*100;
						b = (rgbaPixel[0]/255)*100;
                        
						Voxel *voxel = [[Voxel alloc] initWithPosition: x: s: z];
                        //Shape *voxel = [[Voxel alloc] initWithPosition: x: s: z];
						[voxel setOrientation:SLICE_ORIENTATION_AXIAL];
                        [voxel setThickness:20.0f];
						[voxel generatePointsWithColor: 1.0: 0.0: 0.0];
						[layer addObject:voxel];
					//}
				}
			}
			[layers addObject:layer];
		}
        
        
	} else if(orientation == SLICE_ORIENTATION_CORONAL) {
        
	} else {
        
	}
    
	return layers;
}
 */


-(NSMutableArray *) generateVoxelsLayers: (NSMutableArray *)slices : (int)orientation :(int)thickness {
    return nil;
}

/*
-(NSMutableArray *) generateVoxelsLayers: (NSMutableArray *)slices : (int)orientation :(int)thickness {
	NSMutableArray *layers = [[NSMutableArray alloc] init];
    
	float width = 0;
	float height = 0;
	float r = 0.0f;
	float g = 0.0f;
	float b = 0.0f;
	if(orientation == SLICE_ORIENTATION_AXIAL) {
		//ALTERAR O TIPO DO DEPTH PARA INT NA CLASSE SHAPE
		//conceitualmente existe um grid cubo com slice.width por slice.height por numero de slices dimensoes.
		//pegar cada posiÁ„o de uma image i pertencente a um slice s que pertence ao conjunto S de slices.
		//executar esses passos para cada slice dentro de S.
		//
		//pegar o slice sy e recuperar a imagem i encapsulada nele. Cria uma camada c para inserir todos os voxels gerados por esse slice
		//pegar o width e o depth e percorrer todos o pixels.
		//para cada pixel p(x,sy,z) fazer.
		//
		//se a cor do pixel for clara, criar um voxel com dimensao 1 x thickness x 1 na posicao (x,sy,z) na camada cy
        
		for (int s = 0; s < 1; s++) {
        //for (int s = 0; s < [slices count]; s++) {
            NSLog(@"fatia %d", s);
			VoxelsLayer *layer = [[VoxelsLayer alloc] init];
			Shape *sy = [slices objectAtIndex:s];
            
			//width = z
			width = [sy getDepth];
			//height = x
			height = [sy getWidth];
            
			//recupera aqui o valor da imagem e dos pixels
			UIImage *i = sy.imageTexture;
            CGImageRef inImage = i.CGImage;
            
			CFDataRef dataRefImg = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
			UInt8 * pixelBufImg = (UInt8 *) CFDataGetBytePtr(dataRefImg);
            
			for (int x = 100; x < height; x++) {
				for (int z = 100; z < width; z++) {
					//ver aqui o valor do pixels
					//Ver os valores para ver quais sao os canais corretos. Se o alpha for iguai a 255
					//vezes 4 porque sao 4 canais
                    
					uint8_t *rgbaPixel = (uint8_t *) &pixelBufImg[(int)width*x + z];
                    
                    //
                    int t0 = rgbaPixel[0];
                    int t1 = rgbaPixel[1];
                    int t2 = rgbaPixel[2];
                    int t3 = rgbaPixel[3];
                     //
                    
					//if(rgbaPixel[3]==255) {
                        //adiciona um voxel na posicao (x,s,z) com espessura = [sy getThickness]
                        //na camada camada corrente
                        r = (rgbaPixel[2]/255)*100;
                        g = (rgbaPixel[1]/255)*100;
                        b = (rgbaPixel[0]/255)*100;
                    
                        Voxel *voxel = [[Voxel alloc] initWithPosition: x: s: z];
                        //Shape *voxel = [[Voxel alloc] initWithPosition: x: s: z];
                        [voxel setOrientation:SLICE_ORIENTATION_AXIAL];
                        //[voxel setThickness:20.0f];
                        [voxel setThickness:1.0f];
                        //[voxel generatePointsWithColor: 1.0: 0.0: 0.0];
                        [voxel generatePointsWithColor: r: g: b];
                        [layer addObject:voxel];
					//}
				}
			}
			[layers addObject:layer];
		}
        
        
	} else if(orientation == SLICE_ORIENTATION_CORONAL) {
        
	} else {
        
	}
    
	return layers;
}
 */

@end
