//
//  DicomDictionary.m
//  RMi
//
//  Created by Marcelo da Mata on 26/03/2013.
//
//

#import "DicomDictionary.h"

@implementation DicomDictionary

static DicomDictionary *dicomDictionary = nil;

@synthesize dictionary = dictionary;

+(id)alloc {
    @synchronized(self) {
        if (!dicomDictionary) {
            dicomDictionary = [[super alloc] init];
        }
    }
    return dicomDictionary;
}

-(NSMutableDictionary*)loadProperties {
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Dictionary" ofType:@"txt"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:4 error:NULL];
        
        NSArray *properties = [content componentsSeparatedByString:@","];
        
        int lenght = [properties count];
        NSArray *keyValue;
        NSString *obj;
        
        for (int i = 0; i < lenght; i++) {
            obj = [properties objectAtIndex:i];
            keyValue = [obj componentsSeparatedByString:@"="];
            
            [dictionary setObject:[keyValue objectAtIndex:1] forKey:[[keyValue objectAtIndex:0] substringFromIndex:1]];
        }
        
    }
    return dictionary;
    
}

@end
