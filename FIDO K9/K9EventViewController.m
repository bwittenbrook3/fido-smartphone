//
//  K9EventViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9EventViewController.h"
#import "K9Event.h"
#import <MapKit/MapKit.h>
#import "K9EventDetailViewController.h"
#import "K9Dog.h"
#import "K9Photo.h"

#import <objc/runtime.h>

@interface K9EventViewController () <K9EventDetailViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong) IBOutlet UIView *detailContainerView;
@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (weak) IBOutlet MKMapView *mapView;

@property (strong) K9EventDetailViewController *detailsViewController;
@property (strong) UIMotionEffectGroup *mapEffects;

@end

@interface UIButton (ColorForState)

- (void)setColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface K9DogPath (Renderer)

@property (readonly, retain) MKPolylineRenderer *renderer;
- (void)clearRenderer;

@end

@implementation K9EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsViewController = [[self childViewControllers] objectAtIndex:0];
    self.detailsViewController.delegate = self;
    self.detailsViewController.event = self.event;
    
    self.mapView.delegate = self;
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(25);
    verticalMotionEffect.maximumRelativeValue = @(-25);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                          type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(12);
    horizontalMotionEffect.maximumRelativeValue = @(-12);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    self.mapEffects = group;
    [self.mapView addMotionEffect:group];


    [[self subheaderBar] setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *detailsView = [self detailContainerView];
    [detailsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [detailsView setFrame:[[self subheaderBar] bounds]];
    [[self subheaderBar] addSubview:detailsView];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    
    if(self.event) {
        [self updateEventViews];
    }
}

- (void)setEvent:(K9Event *)event {
    _event = event;
    if(self.isViewLoaded) {
        [self updateEventViews];
        self.detailsViewController.event = self.event;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if([viewControllers indexOfObject:(self)] == NSNotFound) {
        for(K9DogPath *path in self.event.dogPaths) {
            [path clearRenderer];
        }
    }
}

- (void)updateEventViews {
    self.navigationItem.title = [self.event title];
    
    [self setLocation:self.event.location.coordinate inBottomCenterOfMapView:self.mapView];
//    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
//    pa.coordinate = self.event.location.coordinate;
//    pa.title = self.event.title;
//    pa.subtitle = self.event.description;
//    [self.mapView addAnnotation:pa];
    
    for(K9DogPath *path in self.event.dogPaths) {
        [self.mapView addOverlay:path];
    }
}

-(void)setLocation:(CLLocationCoordinate2D)location inBottomCenterOfMapView:(MKMapView*)mapView {
    MKCoordinateRegion oldRegion = [mapView regionThatFits:MKCoordinateRegionMakeWithDistance(location, 200, 200)];
    CLLocationCoordinate2D centerPointOfOldRegion = oldRegion.center;
    //We want it to be 2/3 of the way down. 1/6 = 2/3 - 1/2
    CLLocationCoordinate2D centerPointOfNewRegion = CLLocationCoordinate2DMake(centerPointOfOldRegion.latitude + oldRegion.span.latitudeDelta/6.0, centerPointOfOldRegion.longitude);
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(centerPointOfNewRegion, oldRegion.span);
    [mapView setRegion:newRegion animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[K9DogPath class]]) {
        MKPolylineRenderer *renderer = [(K9DogPath *)overlay renderer];
        [renderer setAlpha:0.7];
        return renderer;
    } else {
        return nil;
    }
}

- (void)eventDetailViewController:(K9EventDetailViewController *)eventDetail didFocusOnDog:(K9Dog *)dog wasFocusedOnDog:(K9Dog *)oldDog{
    [UIView animateWithDuration:0.3 animations:^{
        if(dog) {
            K9DogPath *path = [[self.event dogPaths] objectAtIndex:[[[self.event dogPaths] valueForKey:@"dog"] indexOfObject:dog]];
            
            for(K9DogPath *otherPath in [self.event dogPaths]) {
                [[otherPath renderer] setAlpha:0.3];
            }
            [[path renderer] setAlpha:0.9];
        } else {
            for(K9DogPath *path in [self.event dogPaths]) {
                [[path renderer] setAlpha:0.7];
            }
        }
    }];

}

- (IBAction)showActions:(id)sender {
    UIActionSheet *sheet;
    sheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Take Photo", @"Record Audio", nil];
    [sheet showFromBarButtonItem:sender animated:YES];
    [self.mapView removeMotionEffect:self.mapEffects];
}

- (void)recordAudio {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self recordAudio];
            break;
        default:
            break;
    }
    [self.mapView addMotionEffect:self.mapEffects];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor *textColor = [[[[UIApplication sharedApplication] windows] firstObject] tintColor];
    UIColor *backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:150.0];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            
            for(UIView *buttonSubview in subview.subviews) {
                if (![buttonSubview isKindOfClass:[UILabel class]]) {
                    [buttonSubview setHidden:YES];
                }
            }
            
            UIButton *button = (UIButton *)subview;
            [button setColor:backgroundColor forState:UIControlStateNormal];
            [button setClipsToBounds:YES];
            CGRect frame = [button frame];
            frame.size.width -= 10;
            frame.origin.x += 5;
            frame.size.height += 1;
            [button setFrame:frame];
            
            UIRectCorner corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight);
            if([[button titleForState:UIControlStateNormal] isEqualToString:@"Take Photo"]) {
                corners = UIRectCornerTopLeft | UIRectCornerTopRight;
            } else if([[button titleForState:UIControlStateNormal] isEqualToString:@"Record Audio"]) {
                corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(4.0, 4.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
            
            
            [button setTitleColor:textColor forState:UIControlStateNormal];
        }
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = nil;
    if([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    K9Photo *photo = [K9Photo new];
    photo.image = image;
    [self.event addResource:photo];
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


@end

@implementation K9DogPath (Renderer)

- (MKPolylineRenderer *)renderer {
    MKPolylineRenderer *renderer = objc_getAssociatedObject(self, @selector(renderer));
    if(!renderer) {
        renderer = [[MKPolylineRenderer alloc] initWithPolyline:[self polyline]];
        [renderer setStrokeColor:[[self dog] color]];
        objc_setAssociatedObject(self, @selector(renderer), renderer, OBJC_ASSOCIATION_RETAIN);
    }
    return renderer;
}

- (void)clearRenderer {
    objc_setAssociatedObject(self, @selector(renderer), nil, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UIButton (ColorForState)

- (void)setColor:(UIColor *)color forState:(UIControlState)state {
    UIView *colorView = [[UIView alloc] initWithFrame:self.frame];
    colorView.backgroundColor = color;
    
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:colorImage forState:state];
}

@end
