//
//  FileManager.h
//  RMi
//
//  Created by Marcelo da Mata on 27/03/2013.
//
//

#import <Foundation/Foundation.h>
#import "FileDecoder.h"
#import "DicomDecoder.h"
#import "FileStream.h"
#import "DicomConstants.h"
#import "FileFormatsConstants.h"

@interface FileManager : NSObject

@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *fileName;
@property (nonatomic) FileDecoder *decoder;

-(FileInfo*)getFileInfo: (int) fileType;

@end
