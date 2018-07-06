//
//  DicomDictionary.h
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import <Foundation/Foundation.h>

@interface DicomDictionary : NSObject 

@property (weak, nonatomic) NSMutableDictionary *dictionary;

-(NSMutableDictionary*)loadProperties;

@end
