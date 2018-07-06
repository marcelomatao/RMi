//
//  2DViewerController.h
//  RMi
//
//  Created by Marcelo da Mata on 28/05/2013.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Viewer2D.h"

@class Viewer2DController;

@protocol Viewer2DControllerDelegate <NSObject>

@end

@interface Viewer2DController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) Viewer2D *viewer2D;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *modeViewButton;
@property (nonatomic, weak) id<Viewer2DControllerDelegate> delegate;

- (IBAction)setOrientationAction:(id)sender;
- (IBAction)valueSliderChange:(id)sender;

- (IBAction)cancel:(id)sender;

@end
