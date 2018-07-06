//
//  DicomDecoder.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "DicomDecoder.h"
#import "Image.h"
#import "ConstantsDicomRender.h"

@implementation DicomDecoder

@synthesize dicomStream = dicomStream;
@synthesize values = values;
@synthesize informations = informations;
@synthesize dicomImage = dicomImage;

- (id)init: (NSString *)dir : (NSString *)file {
    
    self.filePath = [NSString stringWithFormat:@"%@/%@", dir, file];
    self = [super init:self.filePath];
    
    self.directory = dir;
    self.fileName = file;
    
    rescaleSlope = 1.0;
    
    littleEndian = true;
    bigEndianTransferSyntax = false;
    oddLocations = false;
    inSequence = false;
    
    self.values = [[NSMutableDictionary alloc] init];
    self.informations = [[NSMutableDictionary alloc] init];

    self.dictionary = [[DicomDictionary alloc] loadProperties];
    self.dicomStream = [[FileStream alloc] init:self.filePath];
    
    self.fileInfo = [[FileInfo alloc] init];
        
    return self;
}


-(BOOL)isDicom {
    if([[NSFileManager defaultManager] fileExistsAtPath:self.directory]) {
        char *buffer = malloc(DICOM_SIZE_HEAD * (sizeof(char)));
        BOOL erro = false;
        @try {
            [dicomStream get:buffer:0 :DICOM_SIZE_HEAD];
        }
        @catch (NSException *exception) {
            NSLog(@"Erro ao ler arquivo.");
            erro = true;
        }
        @finally {
            if (erro) {
                return !erro;
            }
        }
    
        char b0 = buffer[128] & 255;
        char b1 = buffer[129] & 255;
        char b2 = buffer[130] & 255;
        char b3 = buffer[131] & 255;
    
        if(b0 == 68 && b1 == 73 && b2 == 67 && b3 == 77) {
            return true;
        }
    }
    
    return false;
}

-(void)decode {
    long skipCount;
    int bitsAllowcated = 16;
    [self.fileInfo setFormat: RAW];
    [self.fileInfo setFileName: self.filePath];
    
    [self.fileInfo setDirectory: self.directory];//aqui tem diferenca, deve ser revisto caso for tratar passagem de url
    
    [self.fileInfo setIntelByteOrder: true];
    [self.fileInfo setType: GRAY16_UNSIGNED];
    [self.fileInfo setFormat: DICOM];
    int samplesPerPixel = 1;
    int planarConfiguration = 0;
    NSString *photoInterpretation = @"";
    
    //aqui tem um while na implementacao do image J, se o comportamento for indesejado deve ser implementado tambem
    skipCount = ID_OFFSET;
    [dicomStream setPosition: skipCount];
    
    if(![[dicomStream getString:4] isEqual:DICM]) {
        //se ocorrer algum comportamento indesejado implementar como no image J aqui
    } else {
        dicmFound = true;
    }
    
    BOOL decodingTags = true;
    BOOL _signed = false;
    long long teste = 0;
    while(decodingTags) {
        teste++;
        if (teste == 350) {
            NSLog(@"");
        }

        int tag = [self getNextTag];
        if(([dicomStream getPosition]&1)!=0)// a tag DICOM deve ser localizada
            oddLocations = true;
        if(inSequence) {
            [self addInfo: tag: nil];
            continue;
        }
        NSString *s;
        NSString *scale;
        NSString *spacing;
        NSString *center;
        NSString *width;
        NSString *intercept;
        NSString *slop;
        int pixelRepresentation;
        int index = 0;
        
        if(tag == TRANSFER_SYNTAX_UID) {
            s = [dicomStream getString:elementLenght];
            [self addInfo:tag :s];
                
            if ([self indexOf:s:@"1.2.840.10008.1.2.2"]>=0) {
                bigEndianTransferSyntax = true;
            }
        } else if(tag == MODALITY) {
            modality = [dicomStream getString:elementLenght];
            [self addInfo:tag :modality];
        } else if( tag == NUMBER_OF_FRAMES) {
            s = [dicomStream getString:elementLenght];
            [self addInfo:tag :s];
            double frames = [dicomStream s2d:s];
            if (frames>1.0) {
                [self.fileInfo setNImages:(int)frames];
            }
        } else if (tag == SAMPLES_PER_PIXEL) {
            samplesPerPixel = [self getShort];
            [self addInfoInt:tag :samplesPerPixel];
        } else if(tag == PHOTOMETRIC_INTERPRETATION) {
            photoInterpretation = [dicomStream getString:elementLenght];
            [self addInfo:tag:photoInterpretation];
        } else if(tag == PLANAR_CONFIGURATION) {
            planarConfiguration = [self getShort];
            [self addInfoInt:tag :planarConfiguration];
        } else if(tag == ROWS) {
            [self.fileInfo setHeight:[self getShort]];
            [self addInfoInt:tag :[self.fileInfo getHeight]];
        } else if(tag == COLUMNS) {
            [self.fileInfo setWidth:[self getShort]];
            [self addInfoInt:tag :[self.fileInfo getWidth]];
        } else if(tag == IMAGER_PIXEL_SPACING || tag == PIXEL_SPACING) {
            scale = [dicomStream getString:elementLenght];
            [self getSpatialScale:self.fileInfo :scale];
            [self addInfo:tag : scale];
        } else if(tag == SLICE_THICKNESS || tag == SLICE_SPACING) {
            spacing = [dicomStream getString:elementLenght];
            [self.fileInfo setPixelDepth:[dicomStream s2d:spacing]];
            [self addInfo: tag :spacing];
        } else if(tag == BITS_ALLOCATED) {
            bitsAllowcated = [self getShort];
            if (bitsAllowcated==8) {
                [self.fileInfo setType:GRAY8];
            } else if (bitsAllowcated==32) {
                [self.fileInfo setType:GRAY32_UNSIGNED];
            }
            [self addInfoInt:tag :bitsAllowcated];
        } else if(tag == PIXEL_REPRESENTATION) {
            pixelRepresentation = [self getShort];
            if (pixelRepresentation==1) {
                [self.fileInfo setType:GRAY16_SIGNED];
                _signed = true;
            }
            [self addInfoInt:tag :pixelRepresentation];
        } else if(tag == WINDOW_CENTER) {
            center = [dicomStream getString:elementLenght];
            [self indexOf:center :@"\\"];
            if (index!=-1) {
                center = [center substringFromIndex:index+1];
            }
            windowCenter = [dicomStream s2d:center];
            [self addInfo:tag :center];
        } else if(tag == WINDOW_WIDTH) {
            width = [dicomStream getString:elementLenght];
            index = [self indexOf:width :@"\\"];
            if (index!=1) {
                [width substringFromIndex:index+1];
            }
            windowWidth = [dicomStream s2d:width];
            [self addInfo:tag :width];
        } else if(tag == RESCALE_INTERCEPT) {
            intercept = [dicomStream getString:elementLenght];
            rescaleIntercept = [dicomStream s2d:intercept];
            [self addInfo:tag :intercept];
        } else if(tag == RESCALE_SLOPE) {
            slop = [dicomStream getString:elementLenght];
            rescaleSlope = [dicomStream s2d:slop];
            [self addInfo:tag :slop];
        } else if(tag == RED_PALETTE) {
            [self.fileInfo setReds: [self getLut:elementLenght]];
            [self.fileInfo setRedLength: elementLenght];
            [self addInfoInt:tag :elementLenght/2];
        } else if(tag == GREEN_PALETTE) {
            [self.fileInfo setGreens: [self getLut:elementLenght]];
            [self.fileInfo setGreenLength: elementLenght];
            [self addInfoInt:tag :elementLenght/2];
        } else if(tag == BLUE_PALETTE) {
            [self.fileInfo setBlues: [self getLut:elementLenght]];
            [self.fileInfo setBlueLength: elementLenght];
            [self addInfoInt:tag :elementLenght/2];
        } else if(tag == PIXEL_DATA) {
            //Inicio dos dados da imagem
            if (elementLenght!=0) {
                [self.fileInfo setOffset: [dicomStream getPosition]];
                [self addInfoInt:tag :[dicomStream getPosition]];
                decodingTags = false;
            } else {
                [self addInfo:tag :nil];
            }
        }
        else if(tag == 0x7F880010) {
            if (elementLenght!=0) {
                [self.fileInfo setOffset: [dicomStream getPosition]+4];
                decodingTags = false;
            }
        } else {
            //nao usado, pular sobre
            [self addInfo: tag:nil];
        }
    } //while(decodingTags);
    
    if ([self.fileInfo getType]==GRAY8) {
        if ([self.fileInfo getReds]!=nil && [self.fileInfo getGreens]!=nil && [self.fileInfo getBlues]!=nil
            && [self.fileInfo getRedLength]==[self.fileInfo getGreenLength] && [self.fileInfo getRedLength]==[self.fileInfo getBlueLength]) {
            [self.fileInfo setType:COLORB];
            [self.fileInfo setLutSize: [self.fileInfo getRedLength]];
        }
    }
    
    if ([self.fileInfo getType]==GRAY32_UNSIGNED && _signed) {
        [self.fileInfo setType: GRAY32_INT];
    }
    
    if (samplesPerPixel==3 && [photoInterpretation hasPrefix:@"RGB"]) {
        if (planarConfiguration==0) {
            [self.fileInfo setType: RGB];
        } else if (planarConfiguration==1) {
            [self.fileInfo setType: RGB_PLANAR];
        }
    } else if ([photoInterpretation hasSuffix:@"1 "]) {
        [self.fileInfo setWhiteIsZero: true];
    }
    
    if (!littleEndian) {
        [self.fileInfo setIntelByteOrder: false];
    }
    
    //Ha implementacoes de stream aqui. Se ger erro verificar implementacao no arquivo DICOM.java linha 692.
    
}

-(void)addInfo:(int)tag :(NSString *)value {
    NSString *info = [self getHeaderInfo:tag :value];
    NSString *v = value;
    
    if (!info) {
        info = @"";
    }
    if (!v) {
        v = @"";
    }
    
    //if TAG_ORIENTATION_SLICES
    if(tag == 2097207) {
        NSArray *valueOrientation = [info componentsSeparatedByString:@":"];
        v= [valueOrientation objectAtIndex:1];
    }
    
    if (tag==TAG_BITS_ALLOCATED || tag==TAG_IMAGE_NUMBER || tag==TAG_ORIENTATION_SLICES
         || tag==TAG_SLICE_THICKNESS || tag==TAG_SPACING_SLICES) {
        [informations setObject:info forKey:[NSNumber numberWithInt:tag]];
        [values setObject:v forKey:[NSNumber numberWithInt:tag]];
    }
    
    if(inSequence && info!=nil && vr!=SQ) {
        info = [NSString stringWithFormat:@">%@", info];
    }
    if(info!=nil && tag!=ITEM) {
        int group = tag>>16;
        previousGroup = group;
        previousInfo = info;
        dicomInfo = [NSString stringWithFormat:@"%@%@%@\n",dicomInfo, [dicomStream tag2hex:tag], info];
    }
}

-(void)addInfoInt:(int)tag :(int)value {
    [self addInfo:tag :[NSString stringWithFormat:@"%d", value]];
}

-(NSString*)getHeaderInfo:(int)tag :(NSString *)value {
    if(tag==ITEM_DELEMITATION || tag==SEQUENCE_DELEMITATION) {
        inSequence = false;
    }
    NSString *key = [dicomStream i2hex:tag];
    //NSLog(@"%@", key);
    
    NSString *id = [self.dictionary objectForKey:key];
    if(id!=nil) {
        if(vr==IMPLICIT_VR)
            vr = ([id characterAtIndex:0]<<8) + [id characterAtIndex:1];
        id = [id substringFromIndex:2];
    }
    
    if(tag==ITEM) {
        return id!=nil?[NSString stringWithFormat:@"%@:",id]:nil;
    }
    
    if(value!=nil) {
        return [NSString stringWithFormat:@"%@:%@",id,value];
    }
    
    if(vr == FD) {
        if(elementLenght==8) {
            value = [NSString stringWithFormat:@"%lf",[self getDouble]];
        } else {
            for (int i = 0; i < elementLenght; i++) {
                [dicomStream getByte];
            }
        }
    } else if(vr == FL) {
        if (elementLenght==4) {
            value = [NSString stringWithFormat:@"%f",[self getFloat]];
        } else {
            for (int i = 0; i < elementLenght; i++) {
                [dicomStream getByte];
            }
        }
    } else if(vr == AE || vr == AS || vr == AT || vr == CS || vr == DA || vr == DS || vr == DT || vr == IS || vr == LO || vr == LT || vr == PN || vr == SH || vr == ST || vr == TM || vr == UI) {
            value = [dicomStream getString:elementLenght];
    } else if(vr == US) {
        if (elementLenght==2) {
            value = [NSString stringWithFormat:@"%d",[self getShort]];
        } else {
            value = @"";
            int n = elementLenght/2;
            for (int  i = 0; i<n; i++) {
                [NSString stringWithFormat:@"%@%d ",value, [self getShort]];
            }
        }
    } else if(vr == IMPLICIT_VR) {
        value = [dicomStream getString:elementLenght];
        if(elementLenght>44) {
            value = nil;
        }
    } else if(vr == SQ) {
        value = @"";
        BOOL privateTag = ((tag>>16)&1) != 0;
        if (!(tag!=ICON_IMAGE_SEQUENCE && !privateTag)) {
            [dicomStream setPosition:[dicomStream getPosition]+elementLenght];
            value = @"";
        }
    } else {
        //senao cai e pula a sequencia da imagem ou sequencia privada
        [dicomStream setPosition:[dicomStream getPosition]+elementLenght];
        value = @"";
    }
    
    if (value!=nil && id==nil && ![value isEqual:@""]) {
        return [NSString stringWithFormat:@"---: %@", value];
    } else if (id==nil) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%@: %@", id, value];
    }
}

-(double)getDouble {
    int b0 = [dicomStream getByte];
    int b1 = [dicomStream getByte];
    int b2 = [dicomStream getByte];
    int b3 = [dicomStream getByte];
    int b4 = [dicomStream getByte];
    int b5 = [dicomStream getByte];
    int b6 = [dicomStream getByte];
    int b7 = [dicomStream getByte];
    long long res = 0;
    if(littleEndian) {
        res += b0;
        res += ( ((long long)b1) << 8);
        res += ( ((long long)b2) << 16);
        res += ( ((long long)b3) << 24);
        res += ( ((long long)b4) << 32);
        res += ( ((long long)b5) << 40);
        res += ( ((long long)b6) << 48);
        res += ( ((long long)b7) << 56);
    } else {
        res += b7;
        res += ( ((long long)b6) << 8);
        res += ( ((long long)b5) << 16);
        res += ( ((long long)b4) << 24);
        res += ( ((long long)b3) << 32);
        res += ( ((long long)b2) << 40);
        res += ( ((long long)b1) << 48);
        res += ( ((long long)b0) << 56);
    }
    
    return [dicomStream longlongBitsToDouble:res];
}
    

-(float)getFloat {
    int b0 = [dicomStream getByte];
    int b1 = [dicomStream getByte];
    int b2 = [dicomStream getByte];
    int b3 = [dicomStream getByte];
    int res = 0;
    if (littleEndian) {
        res += b0;
        res += ( ((int)b1) << 8);
        res += ( ((int)b2) << 16);
        res += ( ((int)b3) << 24);
    } else {
        res += b3;
        res += ( ((int)b2) << 8);
        res += ( ((int)b1) << 16);
        res += ( ((int)b0) << 24);
    }
    
    return [dicomStream intBitsToFloat:res];
}

-(int)getLenght {
    int b0 = [dicomStream getByte];
    int b1 = [dicomStream getByte];
    int b2 = [dicomStream getByte];
    int b3 = [dicomStream getByte];
    
    vr = (b0<<8) + b1;
    
    if (vr == OB || vr == OW || vr == SQ || vr == UN || vr == UT) {
        //VR explicito com tamanho 32-bit se os dois bytes sao 0
        if( (b2 == 0) || (b3 == 0)) return [self getInt];
        //VR implicito com tamaho 32-bit
        vr = IMPLICIT_VR;
        if(littleEndian)
            return ((b3<<24) + (b2<<16) + (b1<<8) + b0);
        else
            return ((b0<<24) + (b1<<16) + (b2<<8) + b3);
    } else if(vr == AE || vr == AS || vr == AT || vr == CS || vr == DA || vr == DS || vr == DT || vr == FD || vr == FL || vr == IS || vr == LO || vr == LT || vr == PN || vr == SH || vr == SL || vr == SS || vr == ST || vr == TM || vr == UI || vr == UL || vr == US || vr == QQ) {
        //VR explicito com tamanho 16-bit
        if(littleEndian)
            return ((b3<<8) + b2);
        else
            return ((b2<<8) + b3);
    } else {
        //VR implicito com tamanho 32-bit
        vr = IMPLICIT_VR;
        if(littleEndian)
            return ((b3<<24) + (b2<<16) + (b1<<8) + b0);
        else
            return ((b0<<24) + (b1<<16) + (b2<<8) + b3);
    }
    
}

-(int)getShort {
    int b0 = [dicomStream getByte];
    int b1 = [dicomStream getByte];
    if(littleEndian) {
        return ((b1 << 8) + b0);
    } else {
        return ((b0 << 8) + b1);
    }
}

-(int)getNextTag {
    int groupWord = [self getShort];
    if(groupWord==0x0800 && bigEndianTransferSyntax) {
        littleEndian = false;
        groupWord = 0x0008;
    }
    int elementWord = [self getShort];
    int tag = groupWord<<16 | elementWord;
    elementLenght = [self getLenght];
    
    //O corte e preciso para ler alguns arquivos de aparelhos GE
    if(elementLenght==13 && !oddLocations) {
        elementLenght = 10;
    }
    
    //indefinido o tamanho do elemento
    //essa e uma ordenacao de suporte que encerra uma sequencia de elementos
    if(elementLenght==-1) {
        elementLenght = 0;
        inSequence = true;
    }
    
    return tag;
}

-(int)getInt {
    int b0 = [dicomStream getByte];
    int b1 = [dicomStream getByte];
    int b2 = [dicomStream getByte];
    int b3 = [dicomStream getByte];
    
    if (littleEndian) {
        return ((b3<<24) + (b2<<16) + (b1<<8) + b0);
    } else {
        return ((b0<<24) + (b1<<16) + (b2<<8) + b3);
    }
}

    
-(void)getSpatialScale:(FileInfo *)fi :(NSString *)scale {
    double xscale=0, yscale=0;
    int i = [self indexOf:scale :@"\\"];
    if(i>0) {
        yscale = [dicomStream s2d:[scale substringWithRange:NSMakeRange(0,i)]];
        xscale = [dicomStream s2d:[scale substringFromIndex:i+1]];
    }
    if(xscale!=0.0 && yscale!=0.0) {
        [self.fileInfo setPixelWidth: xscale];
        [self.fileInfo setPixelHeight: yscale];
        [self.fileInfo setUnit: @"mm"];
    }
}
    
-(char*)getLut:(int)length {
    if((length&1)!=0) {
        return nil;
    }
    length /= 2;
    char *lut = malloc(length * (sizeof(char)));
    for (int i=0; i<length; i++) {
        lut[i] = (char)(((unsigned char)[self getShort]) >> 8);
    }
    return lut;
}
         
-(int)indexOf:(NSString *)str : (NSString *)index {
    NSRange resp = [str rangeOfString:index];
    if (resp.length > 0) {
        return resp.location;
    }
    return -1;
}

-(char*)getBytes {
    return [dicomStream getBytes];
}

-(long long) getPosition {
    return [dicomStream getPosition];
}

-(UIImage *)getDicomImage {
    Image *img = [[Image alloc] init: self];
    UInt32 *buffer = [self insertAlphaBufferRGBScale:[img getPixels8] :[img getWidth]*[img getHeight]];
    [self generateUIImage:buffer:[img getWidth ]:[img getHeight]];
    //[self generateUIImage:malloc([img getWidth]*[img getHeight]*sizeof(UInt32)):[img getWidth ]:[img getHeight]];
    free(buffer);
    return dicomImage;
}

-(UInt32*)insertAlphaBufferRGBScale: (char*)buffer : (int)size {
    UInt32 *buf = malloc(size*sizeof(UInt32));
    int t0 = 0;
    int t1 = 0;
    int t2 = 0;
    for (int i=0; i < size; i++) {
        t0 = buffer[i];
        t1 = buffer[i];
        t2 = buffer[i];
        uint8_t *rgbaPixel = (uint8_t *) &buf[i];
        rgbaPixel[0] = t0; //B
        rgbaPixel[1] = t1; //G
        rgbaPixel[2] = t2; //R
        
        if(t0 >= 50) {
            rgbaPixel[3] = 255;
        } else {
            rgbaPixel[3] = 0;
        }
    }
    
    buffer = nil;
    return buf;
}


-(void) generateUIImage:(UInt32 *) buffer : (int) width :(int) height {
    size_t bufferLength = width * height;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    /*
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        dicomInfo = nil;
    }
     */
    
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    
    CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,   // data provider
                                    NULL,       // decode
                                    YES,            // should interpolate                
                                    renderingIntent);
    
    
    CGContextRef context = CGBitmapContextCreate(buffer,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef, bitmapInfo);
    
    buffer = nil;
    if(context == NULL) {
        NSLog(@"Error context not created");
    }
    
    UIImage *image = nil;
    if(context) {
        
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    dicomImage =  image;
}


-(long long)getBufferLenght {
    return [dicomStream getLenght];
}

-(NSMutableDictionary *)getValues {
    return values;
}

-(NSMutableDictionary *)getInformations {
    return informations;
}


@end