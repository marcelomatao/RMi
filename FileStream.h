//
//  FileStream.h
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import <Foundation/Foundation.h>
#import "ExceptionsConstants.h"
#import "DicomConstants.h"

@interface FileStream : NSObject {
    @private
    long long position;
    char* bytes;
    long long lenght;
    char buf8[8];
    char buf10[11];
}

-(id)init: (NSString*)filePath;

-(void)get:(char*)buffer : (int)offset : (int)end;
-(void)setPosition: (long long) pos;
-(long long)getPosition;
-(NSString*)getString:(int)lenght;
-(long long)getLenght;
-(int)read:(char[]) buf : (int)pos : (int)len;
-(int)read;
-(int)getByte;
-(double)longlongBitsToDouble:(long long)bits;
-(float)intBitsToFloat:(int)bits;
-(NSString*)i2hex:(unsigned int)i;
-(NSString*)tag2hex:(unsigned int)tag;
-(double)s2d:(NSString*)s;
-(char*)getBytes;

@end
