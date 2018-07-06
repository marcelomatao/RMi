//
//  FileStream.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "FileStream.h"

@implementation FileStream

-(id)init:(NSString*) filePath {
    //pega os bytes do arquivo
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    lenght = data.length;
    
    bytes = malloc(lenght * (sizeof(char)));
    [data getBytes:bytes length:lenght];
    
    position = 0;
    
    return self;
}

-(void)get:(char *)buffer :(int)offset :(int)end {
    int num = end - offset;
    if (offset < 0 || num < 0 || (num + position) > lenght) {
        NSException *ex = [NSException exceptionWithName:[NSString stringWithFormat:@"%@", FILE_STREAM_EXCEPTION] reason:@"Erro ao ler arquivo." userInfo:nil];
        @throw ex;
    }
    
    for (int i = offset; i < end; i++) {
        buffer[i] = bytes[position] & 255;
        position++;
    }
}

-(void)setPosition:(long long)pos {
    position = pos;
}

-(long long)getPosition {
    return position;
}

-(long long)getLenght {
    return lenght;
}

-(NSString*)getString:(int)len {
    char buf[len];
    
    [self read:buf :0 :len];
    
    return [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
}

-(int)read:(char[])buf :(int)pos :(int)len {
    int n = 0;
    for(int i = 0; i < len && i + pos + position < lenght; i++) {
        buf[pos+i] = bytes[position+n];
        n++;
    }
    
    position += len;
    return n;
}

-(int)read {
    if(position == lenght)
        return -1;
    return bytes[position++] & 0xff;
}

-(int)getByte {
    int b = [self read];
    //se b = -1 fim de arquivo
    return b;
}

-(double)longlongBitsToDouble:(long long)bits {
    void *a = &bits;
    double *b = (double*) a;
    double res = (double) *b;
    
    return res;
}

-(NSString*)i2hex:(unsigned int)i {
    for (int pos=7; pos>=0; pos--) {
        buf8[pos] = hexDigits[i&0xf];
        i >>= 4;
    }
    
    return [[NSString alloc] initWithBytes:buf8 length:8 encoding:NSASCIIStringEncoding];
}

-(float)intBitsToFloat:(int)bits {
    void *a = &bits;
    float *b = (float*) a;
    float res = (float) *b;
    
    return res;
    
}

-(NSString*)tag2hex:(unsigned int)tag {
    buf10[4] = ',';
    buf10[9] = ' ';
    
    int pos = 8;
    while (pos>=0) {
        buf10[pos] = hexDigits[tag&0xf];
        tag >>= 4;
        pos--;
        if (pos==4) {
            pos--; //pular coma
        }
    }
    return [[NSString alloc] initWithBytes:buf10 length:10 encoding:NSASCIIStringEncoding];
}

-(double)s2d:(NSString *)s {
    if (s==nil) {
        return 0.0;
    }
    if ([s hasPrefix:@"\\"]) {
        s = [s substringFromIndex:1];
    }
    double d;
    NSString *regx = @"(-){0,1}(([0-9]+)(.)){0,1}([0-9]+)";
    NSPredicate *validate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
    BOOL isValid = [validate evaluateWithObject:s];
    if (!isValid) {
        return 0.0;
    }
    
    d = [s doubleValue];
    return d;
    
}

-(char*)getBytes {
    return bytes;
}


@end
