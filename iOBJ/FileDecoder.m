//
//  FileDecoder.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "FileDecoder.h"

@implementation FileDecoder

@synthesize filePath = filePath;
@synthesize fileName = fileName;
@synthesize directory = directory;
@synthesize dictionary = dictionary;
@synthesize fileInfo = fileInfo;

- (id)init: (NSString*) file
{
    self = [super init];
    
    filePath = file;
    self.fileInfo = [[FileInfo alloc] init];
    
    return self;
}

-(void)decode {
    
}

-(FileInfo*)getFileInfo {
    return fileInfo;
}


@end
