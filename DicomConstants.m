//
//  DicomConstants.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "DicomConstants.h"

@implementation DicomConstants

char const hexDigits[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

int const IMPLICIT_VR = 0x2D2D;

int const ID_OFFSET = 128;
NSString *const DICM = @"DICM";

int const PIXEL_REPRESENTATION = 0x00280103;
int const TRANSFER_SYNTAX_UID = 0x00020010;
int const MODALITY = 0x00080060;
int const SLICE_THICKNESS = 0x00180050;
int const SLICE_SPACING = 0x00180088;
int const IMAGER_PIXEL_SPACING = 0x00181164;
int const SAMPLES_PER_PIXEL = 0x00280002;
int const PHOTOMETRIC_INTERPRETATION = 0x00280004;
int const PLANAR_CONFIGURATION = 0x00280006;
int const NUMBER_OF_FRAMES = 0x00280008;
int const ROWS = 0x00280010;
int const COLUMNS = 0x00280011;
int const PIXEL_SPACING = 0x00280030;
int const BITS_ALLOCATED = 0x00280100;
int const WINDOW_CENTER = 0x00281050;
int const WINDOW_WIDTH = 0x00281051;
int const RESCALE_INTERCEPT = 0x00281052;
int const RESCALE_SLOPE = 0x00281053;
int const RED_PALETTE = 0x00281201;
int const GREEN_PALETTE = 0x00281202;
int const BLUE_PALETTE = 0x00281203;
int const ICON_IMAGE_SEQUENCE = 0x00880200;
int const ITEM = 0xFFFEE000;
int const ITEM_DELEMITATION = 0xFFFEE00D;
int const SEQUENCE_DELEMITATION = 0xFFFEE0DD;
int const PIXEL_DATA = 0x7FE00010;
int const DEPTH = 0x00180088;

int const AE = 0x4145;
int const AS = 0x4153;
int const AT = 0x4154;
int const CS = 0x4353;
int const DA = 0x4441;
int const DS = 0x4453;
int const DT = 0x4454;
int const FD = 0x4644;
int const FL = 0x464C;
int const IS = 0x4953;
int const LO = 0x4C4F;
int const LT = 0x4C54;
int const PN = 0x504E;
int const SH = 0x5348;
int const SL = 0x534C;
int const SS = 0x5353;
int const ST = 0x5354;
int const TM = 0x544D;
int const UI = 0x5549;
int const UL = 0x554C;
int const US = 0x5553;
int const UT = 0x5554;
int const OB = 0x4F42;
int const OW = 0x4F57;
int const SQ = 0x5351;
int const UN = 0x554E;
int const QQ = 0x3F3F;


int const GRAY8 = 0;
int const GRAY16_SIGNED = 1;
int const GRAY16_UNSIGNED = 2;
int const GRAY32_INT = 3;
int const GRAY32_UNSIGNED = 11;

int const COLORB = 5;
int const RGB = 6;
int const RGB_PLANAR = 7;
int const BITMAP = 8;


/** Compression modes */
int const COMPRESSION_UNKNOWN = 0;
int const COMPRESSION_NONE = 1;
int const LZW = 2;
int const LZW_WITH_DIFFERENCING = 3;
int const JPEG = 4;
int const PACK_BITS = 5;
int const ZIP = 6;

int const DICOM_SIZE_HEAD = 132;

@end
