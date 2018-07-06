//
//  FileDecoder.h
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "DicomDictionary.h"
#import "ExceptionsConstants.h"
#import "DicomConstants.h"
#import "FileFormatsConstants.h"

@interface FileDecoder : NSObject

@property (nonatomic) NSMutableDictionary *dictionary;
@property (nonatomic) FileInfo *fileInfo;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *directory;
@property (nonatomic) NSString *fileName;

- (id)init: (NSString*) file;
-(FileInfo*)getFileInfo;
-(void) decode;

@end
