//
//  2DViewerController.m
//  RMi
//
//  Created by Marcelo da Mata on 28/05/2013.
//
//

#import "Viewer2DController.h"
#import "NSObject+PerformBlock.h"
#import "Shape.h"

@interface Viewer2DController () {
    @private
        GLint viewMode;
        int indexSlider;
}

@property (nonatomic, weak) UIBarButtonItem *currentModeView;
@property (nonatomic, strong) UIImage *currentImage;

@end


@implementation Viewer2DController

@synthesize viewer2D = viewer2D;

typedef enum {
    AXIAL_SLICES, SAGITAL_SLICES, CORONAL_SLICES
} ModeRenderViewSlices;

- (void)viewDidLoad
{
    indexSlider = 0;
    viewMode = AXIAL_SLICES;
    [super viewDidLoad];
    self.currentModeView = nil;
    
    [self performBlock:^(void) {
        [self setOrientationAction:self.modeViewButton];
    }
             afterDelay:0.0];
    
    [viewer2D loadImages];
    
}

- (IBAction)setOrientationAction:(id)sender {

    indexSlider = 0;
    [self.slider setValue:0.0f];
    if(/*[[sender title] isEqualToString:@"Axial"] &&*/ viewer2D.axialSlices.count > indexSlider) {
        viewMode = AXIAL_SLICES;
        _currentImage = [viewer2D.axialSlices objectAtIndex:indexSlider];
    } else if(/*[[sender title] isEqualToString:@"Sagital"] &&*/ viewer2D.sagitalSlices.count > indexSlider) {
        viewMode = SAGITAL_SLICES;
        _currentImage = [viewer2D.sagitalSlices objectAtIndex:indexSlider];
    } else if(/*[[sender title] isEqualToString:@"Coronal"] &&*/ viewer2D.coronalSlices.count > indexSlider) {
        viewMode = CORONAL_SLICES;
        _currentImage = [viewer2D.coronalSlices objectAtIndex:indexSlider];
    }

    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
    barButtonItem.style = UIBarButtonItemStyleDone;
    
    self.currentModeView.style = UIBarButtonItemStyleBordered;
    self.currentModeView = barButtonItem;
    
    [self updateImage];
}

- (IBAction)valueSliderChange:(id)sender {
    NSMutableArray *current = nil;
    
    if (/*viewMode == AXIAL_SLICES && */ viewer2D.axialSlices.count > 0) {
        indexSlider = [(UISlider*)sender value]*viewer2D.axialSlices.count;
        indexSlider--;
        current = viewer2D.axialSlices;
    } else if (/*viewMode == SAGITAL_SLICES &&*/ viewer2D.sagitalSlices.count > 0) {
        indexSlider = [(UISlider*)sender value]*viewer2D.sagitalSlices.count;
        indexSlider--;
        current = viewer2D.sagitalSlices;
    } else if (/*viewMode == CORONAL_SLICES &&*/ viewer2D.coronalSlices.count > 0) {
        indexSlider = [(UISlider*)sender value]*viewer2D.coronalSlices.count;
        indexSlider--;
        current = viewer2D.coronalSlices;
    }
    
    if (indexSlider < 0) {
        indexSlider = 0;
    }
    if(current) {
        _currentImage = [current objectAtIndex:indexSlider];
    }
    [self updateImage];
}

-(void)updateImage {
    if (_currentImage != nil) {
        self.image.image = _currentImage;
    }
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self close];
}


@end
