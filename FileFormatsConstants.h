//
//  FileFormatsConstants.h
//  RMi
//
//  Created by Marcelo da Mata on 29/03/2013.
//
//

#import <Foundation/Foundation.h>

@interface FileFormatsConstants : NSObject

/** File formats*/
FOUNDATION_EXPORT int const UNKNOWN;
FOUNDATION_EXPORT int const RAW;
FOUNDATION_EXPORT int const TIFF;
FOUNDATION_EXPORT int const GIF_OR_JPG;
FOUNDATION_EXPORT int const FITS;
FOUNDATION_EXPORT int const BMP;
FOUNDATION_EXPORT int const DICOM;
FOUNDATION_EXPORT int const ZIP_ARCHIVE;
FOUNDATION_EXPORT int const PGM;
FOUNDATION_EXPORT int const IMAGEIO;

@end
