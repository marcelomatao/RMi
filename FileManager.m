//
//  FileManager.m
//  RMi
//
//  Created by Marcelo da Mata on 27/03/2013.
//
//

#import "FileManager.h"

@implementation FileManager

@synthesize filePath = filePath;
@synthesize fileName = fileName;
@synthesize decoder = decoder;

- (id)init:(NSString*)name : (NSString*)path
{
    self.fileName = name;
    self.filePath = path;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", filePath, fileName]]) {
        NSException *ex = [NSException exceptionWithName:[NSString stringWithFormat:@"%@", FILE_EXCEPTION] reason:@"O arquivo solicitado nao existe." userInfo:nil];
        @throw ex;
    }
    
    return self;
}



-(FileInfo*)getFileInfo: (int) fileType {
    if (fileType == DICOM) {
        decoder = [[DicomDecoder alloc] init: filePath: fileName];
    } else {
        NSException *ex = [NSException exceptionWithName:[NSString stringWithFormat:@"%@", FILE_UNKNOW_EXCEPTION] reason:@"Tipo de arquivo desconhecido." userInfo:nil];
        @throw ex;
    }
    
    [decoder decode];
    return [decoder getFileInfo];
}


@end
