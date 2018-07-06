//
//  ViewController.m
//  iOBJ
//
//  Created by felipowsky on 02/01/12.
//
//

#import "Viewer3DController.h"
#import "ScreenManager.h"
#import "NSObject+PerformBlock.h"
#import "UIBarButtonItem+DisplayMode.h"
#import "UIView+Additions.h"
#import "GraphicObject.h"
#import "OBJParser.h"
#import "Camera.h"
#import "DicomDecoder.h"
#import "DicomParser.h"
#import "VolumeSlices.h"
#import "Viewer2DController.h"

@interface ViewController () {
    @private
    GLint modeEventCatch; BOOL initApp;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) ScreenManager *screenManager;
@property (nonatomic, strong) Camera *camera;
@property (nonatomic) GLfloat previousPinchScale;
@property (nonatomic) GLfloat previousOneFingerPanX;
@property (nonatomic) GLfloat previousOneFingerPanY;
@property (nonatomic) GLfloat previousTwoFingersPanX;
@property (nonatomic) GLfloat previousTwoFingersPanY;
@property (nonatomic) GLfloat previousRotation;
@property (nonatomic, strong) NSString *loadedFile;
@property (nonatomic, strong) NSString *fileToLoad;
@property (nonatomic, weak) UIBarButtonItem *currentModeDisplay;
@property (nonatomic) NSTimeInterval lastTimeInterval;
@property (nonatomic) NSUInteger frames;
@property (nonatomic, strong) GraphicObject *object;
@property (strong, nonatomic) GLKBaseEffect *effect;

@property (nonatomic, strong) NSMutableArray *dicomFiles;
@property (nonatomic, strong) NSString *documentsPath;

@end

@implementation ViewController

- (void)initialize
{
    initApp = false;
    self.screenManager = nil;
    self.loadedFile = @"";
    self.fileToLoad = @"";
    self.currentModeDisplay = nil;
    self.lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    self.frames = 0;
    self.object = nil;
    //modeEventCatch = NORMAL;
    modeEventCatch = VOXEL;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenManager = [[ScreenManager alloc] init];
    
    [self performBlock:^(void) {
        [self showControlsAnimated:NO];
        [self showStatsViewAnimated:NO];
        
        [self displayModeTouched:self.textureDisplayButton];
    }
            afterDelay:0.0];
    
    if(!initApp) {
        [self performBlock:^(void) {
            [self performSegueWithIdentifier:@"FileList" sender:self];
        }
            afterDelay:1.0];
        initApp = true;
    }
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

#ifdef DEBUG
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
#endif
    
    [self setupGL];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    
    self.preferredFramesPerSecond = 99;
    
    Camera *camera = [[Camera alloc] init];
    camera.aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    camera.fovyDegrees = 60.0f;
    camera.eyeZ = 100.0f;
    
    self.camera = camera;
    
    [self registerGestureRecognizersToView:self.gestureView];
}

- (void)registerGestureRecognizersToView:(UIView *)view
{
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTouchesRequired = 2;
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.delegate = self;
    
    [view addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.delegate = self;
    
    [view addGestureRecognizer:tapRecognizer];    
    
    UIPanGestureRecognizer *panOneFingerRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    panOneFingerRecognizer.minimumNumberOfTouches = 1;
    panOneFingerRecognizer.maximumNumberOfTouches = 1;
    panOneFingerRecognizer.delegate = self;
    
    [view addGestureRecognizer:panOneFingerRecognizer];
    
    UIPanGestureRecognizer *panTwoFingersRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingersPan:)];
    panTwoFingersRecognizer.minimumNumberOfTouches = 2;
    panTwoFingersRecognizer.delegate = self;
    
    [view addGestureRecognizer:panTwoFingersRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinchRecognizer.delegate = self;
    
    [view addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationRecognizer.delegate = self;
    
    [view addGestureRecognizer:rotationRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (BOOL)shouldAutorotate
{
    self.camera.aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //glDisable(GL_DEPTH_TEST);
    //glEnable(GL_VERTEX_ARRAY);
    //glEnableClientState(GL_COLOR_ARRAY);
    //glEnable(GL_TEXTURE_2D);
    //glEnable(GL_DEPTH_TEST);
    //glEnable(GL_ALPHA_TEST_FUNC);
    //glEnable(GL_SAMPLE_ALPHA_TO_COVERAGE);
    //glDepthMask(GL_TRUE);
    //glDepthFunc(GL_ALWAYS);
    //glDepthFunc(GL_NOTEQUAL);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glEnable(GL_BLEND);
    //glAlphaFunc(GL_GREATER, 255);
    //glEnable(GL_ALPHA_TEST_FUNC);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glBlendEquation(GL_FRONT_FACE);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glDepthMask(false);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)update
{
    GraphicObject *graphicObject = self.screenManager.currentGraphicObject;
    
    if (graphicObject) {
        [graphicObject update];
        self.effect.transform.modelviewMatrix = graphicObject.transform.matrix;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    GLuint verticesCount = 0;
    GLuint facesCount = 0;
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_DEPTH_BUFFER_BIT);
    glClear(GL_STENCIL_BUFFER_BIT);
    
    GraphicObject *graphicObject = self.screenManager.currentGraphicObject;
    
    if (graphicObject && self.camera) {
        
        GraphicObjectDisplayMode mode = GraphicObjectDisplayModeTexture;
        
        if (self.currentModeDisplay) {
            mode = self.currentModeDisplay.displayMode;
        }
        
        [graphicObject drawWithDisplayMode:mode camera:self.camera effect:self.effect];
        
        verticesCount = self.screenManager.verticesCount;
        
        facesCount = [graphicObject.volume getFacesCount];
    }
    
    NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval diffTimeInterval = timeInterval - self.lastTimeInterval;
    
    if (diffTimeInterval > 1.0) {
        NSTimeInterval rate = self.frames / diffTimeInterval;
        self.frames = 0;
        self.lastTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        
        self.framesPerSecondLabel.text = [NSString stringWithFormat:@"%.1f", rate];
    }
    
    self.verticesCountLabel.text = [NSString stringWithFormat:@"%d", verticesCount];
    self.facesCountLabel.text = [NSString stringWithFormat:@"%d", facesCount];
    
    self.frames++;
}

- (void)hideNavigatorBar
{
    [self hideNavigatorBarAnimated:YES];
}

- (void)hideNavigatorBarAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.navigatorBar.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.navigatorBar.hidden = YES;
                         }];
    } else {
        self.navigatorBar.alpha = 0.0f;
        self.navigatorBar.hidden = YES;
    }
}

- (void)showNavigatorBar
{
    [self showNavigatorBarAnimated:YES];
}

- (void)showNavigatorBarAnimated:(BOOL)animated
{
    self.navigatorBar.hidden = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.navigatorBar.alpha = 1.0f;
                         }];
    } else {
        self.navigatorBar.alpha = 1.0f;
    }
}

- (void)hideToolbar
{
    [self hideToolbarAnimated:YES];
}

- (void)hideToolbarAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.toolBar.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.toolBar.hidden = YES;
                         }];
    } else {
        self.toolBar.alpha = 0.0f;
        self.toolBar.hidden = YES;
    }
}

- (void)showToolBar
{
    [self showToolBarAnimated:YES];
}

- (void)showToolBarAnimated:(BOOL)animated
{
    self.toolBar.hidden = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.toolBar.alpha = 1.0f;
                         }];
    } else {
        self.toolBar.alpha = 1.0f;
    }
}

- (void)hideStatsView
{
    [self hideStatsViewAnimated:YES];
}

- (void)hideStatsViewAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.statsView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.statsView.hidden = YES;
                         }];
    } else {
        self.statsView.alpha = 0.0f;
        self.statsView.hidden = YES;
    }
}

- (void)showStatsView
{
    [self showStatsViewAnimated:YES];
}

- (void)showStatsViewAnimated:(BOOL)animated
{
    self.statsView.hidden = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.statsView.alpha = 1.0f;
                         }];
    } else {
        self.statsView.alpha = 1.0f;
    }
}

- (void)hideProgressiveSliderView
{
    [self hideProgressiveSliderViewAnimated:YES];
}

- (void)hideProgressiveSliderViewAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.progressiveSliderView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.progressiveSliderView.hidden = YES;
                         }];
    } else {
        self.progressiveSliderView.alpha = 0.0f;
        self.progressiveSliderView.hidden = YES;
    }
}

- (void)showProgressiveSliderView
{
    [self showProgressiveSliderViewAnimated:YES];
}

- (void)showProgressiveSliderViewAnimated:(BOOL)animated
{
    self.progressiveSliderView.hidden = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.progressiveSliderView.alpha = 1.0f;
                         }];
    } else {
        self.progressiveSliderView.alpha = 1.0f;
    }
}

- (void)hideControls
{
    [self hideControlsAnimated:YES];
}

- (void)hideControlsAnimated:(BOOL)animated
{
    [self hideNavigatorBarAnimated:animated];
    [self hideToolbarAnimated:animated];
    
    switch (self.screenManager.type) {
        case ScreenManagerTypeProgressiveMesh: {
            [self hideProgressiveSliderViewAnimated:animated];
        }
            break;
            
        case ScreenManagerTypeNormal:
            break;
            
        default:
            break;
    }
}

- (void)showControls
{
    [self showControlsAnimated:YES];
}

- (void)showControlsAnimated:(BOOL)animated
{
    [self showNavigatorBarAnimated:animated];
    [self showToolBarAnimated:animated];
    
    switch (self.screenManager.type) {
        case ScreenManagerTypeProgressiveMesh: {
            [self showProgressiveSliderViewAnimated:animated];
        }
            break;
            
        case ScreenManagerTypeNormal:
            break;
            
        default:
            break;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{    
    if (self.navigatorBar.hidden) {
        [self showControls];
        
    } else {
        [self hideControls];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    [self adjustCamera:self.camera toFitObject:self.screenManager.currentGraphicObject];
    [self.screenManager.currentGraphicObject setupCamera];
}

- (void)handleOneFingerPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.gestureView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.previousOneFingerPanX = 0.0f;
        self.previousOneFingerPanY = 0.0f;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        GLfloat pan = 1.5f;
        
        GLfloat panX = (translation.x - self.previousOneFingerPanX) * pan;
        GLfloat panY = (translation.y - self.previousOneFingerPanY) * pan;
        
        GraphicObject *graphicObject = self.screenManager.currentGraphicObject;
        
        if (graphicObject) {
            if(modeEventCatch == NORMAL || modeEventCatch == VOXEL) {
                [graphicObject.transform rotateWithDegrees:panY axis:GLKVector3Make(1.0f, 0.0f, 0.0f)];
                [graphicObject.transform rotateWithDegrees:panX axis:GLKVector3Make(0.0f, 1.0f, 0.0f)];
            } else if(modeEventCatch == AXIAL) {
                if(panY > 0) {
                    [graphicObject addSlicingAxial];
                } else if(panY < 0) {
                    [graphicObject subSlicingAxial];
                }
            } else if(modeEventCatch == CORONAL) {
                if(panX > 0) {
                    [graphicObject addSlicingCoronal];
                } else if(panX < 0) {
                    [graphicObject subSlicingCoronal];
                }
            } else if(modeEventCatch == SAGITAL) {
                if(panX > 0) {
                    [graphicObject addSlicingSagital];
                } else if(panX < 0) {
                    [graphicObject subSlicingSagital];
                }
            }
        }
    }
    
    self.previousOneFingerPanX = translation.x;
    self.previousOneFingerPanY = translation.y;
}

- (void)handleTwoFingersPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.gestureView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.previousTwoFingersPanX = 0.0f;
        self.previousTwoFingersPanY = 0.0f;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        GLfloat pan = 0.5f;
        
        GLfloat panX = (translation.x - self.previousTwoFingersPanX) * pan;
        GLfloat panY = (translation.y - self.previousTwoFingersPanY) * -pan;
        
        if (fabs(panX) > 0.0f) {
            self.camera.eyeX += panX;
            self.camera.centerX += panX;
        }
        
        if (fabs(panY) > 0.0f) {
            self.camera.eyeY += panY;
            self.camera.centerY += panY;
        }
    }
    
    self.previousTwoFingersPanX = translation.x;
    self.previousTwoFingersPanY = translation.y;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.previousPinchScale = 0.0f;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        GLfloat pinch = 5.0f;
        
        if ((recognizer.scale - self.previousPinchScale) > 0.0f) {
            pinch = -pinch;
        }
        
        GLfloat result = self.camera.eyeZ + pinch;
        
        if (result > 0) {
            self.camera.eyeZ = result;
        }
    }
    
    self.previousPinchScale = recognizer.scale;
}

- (void)handleRotation:(UIRotationGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.previousRotation = 0.0f;
    
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        GLfloat rotate = (self.previousRotation - recognizer.rotation) * 45.0f;
        
        GraphicObject *graphicObject = self.screenManager.currentGraphicObject;
        
        if (graphicObject) {
            [graphicObject.transform rotateWithDegrees:rotate axis:GLKVector3Make(0.0f, 0.0f, 1.0f)];
        }
    }
    
    self.previousRotation = recognizer.rotation;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FileListViewController class]]) {
        FileListViewController *viewController = (FileListViewController *) segue.destinationViewController;
        
        viewController.selectedFile = self.loadedFile;
        viewController.delegate = self;
    } else if([segue.destinationViewController isKindOfClass:[Viewer2DController class]]) {
        Viewer2DController *viewController = (Viewer2DController *) segue.destinationViewController;
        viewController.viewer2D = [[Viewer2D alloc] init];
        viewController.viewer2D.dicomFiles = self.dicomFiles;
        viewController.viewer2D.directory = self.documentsPath;
        [viewController.viewer2D setThickness: [self.screenManager.currentGraphicObject.volume getThickness]];
        [viewController.viewer2D setOrientation:[self.screenManager.currentGraphicObject.volume getFirstOrientation]];
        viewController.viewer2D.axialSlices = [[NSMutableArray alloc] init];
        viewController.viewer2D.coronalSlices = [[NSMutableArray alloc] init];
        viewController.viewer2D.sagitalSlices = [[NSMutableArray alloc] init];
    }
}

- (void)fileList:(FileListViewController *)fileList selectedFile:(NSString *)file
{
    self.fileToLoad = file;
}

- (void)fileListWillClose:(FileListViewController *)fileList
{
    BOOL ok = self.fileToLoad && ![self.fileToLoad isEqualToString:@""] && ![self.fileToLoad isEqualToString:self.loadedFile];
    
    if (ok) {
        if(self.screenManager) {
            [self.screenManager setGraphicObject:nil];
            self.screenManager = nil;
        }
        
        GraphicObject *newGraphicObject;

        if([self isDicomDir: self.fileToLoad]) {
            self.dicomFiles = [self getDicomFiles:self.fileToLoad];
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            self.documentsPath = [NSString stringWithFormat:@"%@/%@", path, self.fileToLoad];
            
            VolumeSlices *volume = [self loadDicomFileAsVolumeSlices: self.dicomFiles: self.documentsPath];
            //if(modeEventCatch == VOXEL) {
            //    [volume generateVoxels];
            //} else {
                [volume generateOtherDirection];
            //[volume initSlices];
            //}
            newGraphicObject = [[GraphicObject alloc] initWithVolumeSlices:volume];
        }
        
        [self centralizeObject:newGraphicObject];
        [self adjustCamera:self.camera toFitObject:newGraphicObject];
        self.screenManager = [[ScreenManager alloc] initWithGraphicObject:newGraphicObject];
        self.loadedFile = self.fileToLoad;
    }
}

-(BOOL) isDicomDir: (NSString *) path {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSError *error;
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL isDir;
    [fm fileExistsAtPath:[NSString stringWithFormat:documentsPath, path] isDirectory:&isDir];
    
    if (isDir) {
        NSString *newPath = [NSString stringWithFormat:@"%@/%@", documentsPath, path];
        
        NSArray *contentsDirDicom = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:&error];
        BOOL hasDicom = false;
        for (NSString *fileDicom in contentsDirDicom) {
            DicomDecoder *dc = [[DicomDecoder alloc] init:newPath :fileDicom];
            hasDicom |= [dc isDicom];
            if(hasDicom) {
                return true;
            }
        }
    }
    return false;
}

-(NSMutableArray *) getDicomFiles: (NSString *) path {
    NSMutableArray *dicomFiles = [[NSMutableArray alloc] init];

    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSError *error;
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL isDir;
    //[fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", @"/Users/User/Desktop/Dicom_Files", path] isDirectory:&isDir];
    [fm fileExistsAtPath:[NSString stringWithFormat:documentsPath, path] isDirectory:&isDir];
    
    if (isDir) {
        //NSString *newPath = [NSString stringWithFormat:@"%@/%@", @"/Users/User/Desktop/Dicom_Files", path];
        NSString *newPath = [NSString stringWithFormat:@"%@/%@", documentsPath, path];
        
        NSArray *contentsDirDicom = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:&error];

        for (NSString *fileDicom in contentsDirDicom) {
            DicomDecoder *dc = [[DicomDecoder alloc] init:newPath :fileDicom];

            if([dc isDicom]) {
                [dicomFiles addObject:fileDicom];
            }
        }
    }
    return dicomFiles;
}

- (void)centralizeObject:(GraphicObject *)graphicObject
{
    [graphicObject.transform translateToOrigin];
}

- (void)adjustCamera:(Camera *)camera toFitObject:(GraphicObject *)graphicObject
{
    camera.centerX = 0.0f;
    camera.centerY = 0.0f;
    camera.centerZ = 0.0f;
    
    camera.upX = 0.0f;
    camera.upY = 1.0f;
    camera.upZ = 0.0f;
    
    camera.eyeX = 0.0f;
    camera.eyeY = 0.0f;
    
    GLfloat maxValue = MAX(graphicObject.width, graphicObject.height);
    
    if (maxValue > 0.0f) {
        camera.eyeZ = maxValue * 2;
    }
}

- (Mesh *)loadOBJFileAsMesh:(NSString *)file
{
    OBJParser *parser = [[OBJParser alloc] initWithFilename:file];
    return [parser parseAsObject];
}

- (VolumeSlices *)loadDicomFileAsVolumeSlices:(NSMutableArray *)dicomFiles :(NSString *)directory
{
    DicomParser *parser = [[DicomParser alloc] initWithDicomFiles:dicomFiles: directory];
    return [parser parseAsDicom];
}

- (IBAction)displayModeTouched:(id)sender
{
    if (self.currentModeDisplay) {
        self.currentModeDisplay.style = UIBarButtonItemStyleBordered;
    }
    
    GraphicObject *graphicObject = self.screenManager.currentGraphicObject;
    
    
    if ([[sender title] isEqualToString:@"Rotate"]) {
        modeEventCatch = NORMAL;
    } else if([[sender title] isEqualToString:@"Axial"]) {
        modeEventCatch = AXIAL;
        [graphicObject setModeRender: AXIAL];
    } else if([[sender title] isEqualToString:@"Sagital"]) {
        modeEventCatch = SAGITAL;
        [graphicObject setModeRender: SAGITAL];
    } else if([[sender title] isEqualToString:@"Coronal"]) {
        modeEventCatch = CORONAL;
        [graphicObject setModeRender: CORONAL];
    }
    
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    barButtonItem.style = UIBarButtonItemStyleDone;
    
    self.currentModeDisplay = barButtonItem;
}

- (IBAction)toggleStats:(id)sender
{
    if (self.statsView.hidden) {
        [self showStatsView];
        
    } else {
        [self hideStatsView];
    }
}

- (IBAction)toggleLOD:(id)sender
{
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    barButtonItem.style = UIBarButtonItemStyleBordered;
    
    if (self.screenManager.type != ScreenManagerTypeProgressiveMesh) {
        //[self activateLODType:LODManagerTypeProgressiveMesh];
        barButtonItem.style = UIBarButtonItemStyleDone;
    
    } else {
        //[self activateLODType:LODManagerTypeNormal];
    }
}

- (IBAction)sliderValueChanging:(id)sender
{
    UISlider *slider = (UISlider *) sender;
    
    self.percentageProgressiveLOD.text = [NSString stringWithFormat:@"%d%%", (int) slider.value];
}

- (IBAction)sliderValueChanged:(id)sender
{
    //UISlider *slider = (UISlider *) sender;
    
    GraphicObject *priorGraphicObject = self.screenManager.currentGraphicObject;
    
    //[self.lodManager generateProgressiveMeshWithPercentage:(int) slider.value];
    
    self.screenManager.currentGraphicObject.transform = priorGraphicObject.transform;
}

- (GraphicObject*)getGraphicObject {
    return self.screenManager.currentGraphicObject;
}

@end
