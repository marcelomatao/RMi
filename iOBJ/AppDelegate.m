//
//  AppDelegate.m
//  iOBJ
//
//  Created by felipowsky on 02/01/12.
//
//

#import "AppDelegate.h"
#import "DicomDecoder.h"


@implementation AppDelegate

- (void)initialize
{
    [self copyDicomDirsFromResourcesToDocuments];
}

- (void)copyDicomDirsFromResourcesToDocuments
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (!error) {
        NSString *path = [[NSBundle mainBundle] bundlePath];

        //NSLog(@"%@", path);
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error: nil];
        
        for (NSString *file in contents) {
            //NSLog(@"%@", file);
            BOOL isDir;
            [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path,file] isDirectory:&isDir];
            if (isDir) {
                
                NSString *newPath = [NSString stringWithFormat:@"%@/%@", path, file];
                
                NSArray *contentsDirDicom = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:&error];
                
                BOOL hasDicom = false;
                BOOL createDir = false;
                for (NSString *fileDicom in contentsDirDicom) {
                    DicomDecoder *dc = [[DicomDecoder alloc] init:newPath :fileDicom];
                    hasDicom |= [dc isDicom];
                    if(hasDicom) {
                        if (!createDir) {
                            [self createDirectory:file atFilePath:documentsPath];
                            createDir = true;
                        }
                        NSString *fromFilePath = [newPath stringByAppendingPathComponent:fileDicom];
                        NSString *toFilePath = [[NSString stringWithFormat:@"%@/%@", documentsPath, file] stringByAppendingPathComponent:fileDicom];
                        
                        if (![fileManager fileExistsAtPath:toFilePath]) {
                            [fileManager copyItemAtPath:fromFilePath toPath:toFilePath error:&error];
                        }
                    }
                }
        
               
            }
        }
    }
#ifdef DEBUG
    else {
        NSLog(@"Couldn't load resources from '%@'", resourcePath);
    }
#endif
    
}

-(void)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error])
    {
        NSLog(@"Create directory error: %@", error);
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [self initialize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initialize];
    
    return YES;
}

@end
