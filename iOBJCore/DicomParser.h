//
//  DicomParser.h
//  RMi
//
//  Created by Marcelo da Mata on 13/04/2013.
//
//

#import <Foundation/Foundation.h>
#import "VolumeSlices.h"
#import "DataParser.h"

@interface DicomParser : DataParser

@property (nonatomic, strong) NSMutableArray *dicomFiles;
@property (nonatomic, strong) NSString *directory;

- (id)initWithDicomFiles:(NSMutableArray *)dicomFiles : (NSString *) dir;
- (VolumeSlices *)parseAsDicom;
- (void)parseAsDicomWithSlice:(VolumeSlices *)volume;

@end
