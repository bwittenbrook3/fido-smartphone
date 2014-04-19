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
#import "K9Preferences.h"
#import "K9Photo.h"
#import "UIColor+DefaultTintColor.h"
#import "K9PolylineBuilder.h"
#import "K9MapAnnotation.h"

#import <objc/runtime.h>
#import <MapKit/MapKit.h>


@interface K9MapPanGestureRecognizer : UIPanGestureRecognizer

@end

@interface K9EventViewController () <K9EventDetailViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong) IBOutlet UIView *detailContainerView;
@property (weak) IBOutlet UINavigationBar *subheaderBar;

@property (strong) K9EventDetailViewController *detailsViewController;

@property (strong) UIActionSheet *directionsSheet;
@property (strong) UIActionSheet *actionsSheet;


@property (strong) CLGeocoder *geocoder;

@property (strong) K9PolylineBuilder *currentPolylineBuilder;
@property (weak) K9MapPanGestureRecognizer *mapPanGestureRecognizer;
@property (strong) K9MapAnnotation *mapAnnotation;

@property (strong) IBOutlet UIBarButtonItem *actionsBarButtonItem;
@property (strong) IBOutlet UIBarButtonItem *saveAnnotationBarButtonItem;

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
    BOOL disappearingForGood = ![self.navigationController.viewControllers containsObject:self];
    
    for(K9DogPath *path in self.event.dogPaths) {
        [[self mapView] removeOverlay:path];
        if(disappearingForGood) [path clearRenderer];
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    for(K9DogPath *path in self.event.dogPaths) {
        if(![[self.mapView overlays] containsObject:path]) {
            [self.mapView addOverlay:path];
        }
    }
}

- (void)updateEventViews {
    self.navigationItem.title = [self.event title];
    
    [self setLocation:self.event.location.coordinate inBottomCenterOfMapView:self.mapView];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = self.event.location.coordinate;
    
    
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder reverseGeocodeLocation:self.event.location completionHandler:
     ^(NSArray* placemarks, NSError* error){
         if(placemarks.count) {
             pa.title = [[placemarks firstObject] name];
         } else {
             pa.title = self.event.title;
         }
     }];
    
    [self.mapView addAnnotation:pa];
    
    for(K9DogPath *path in self.event.dogPaths) {
        if(![[self.mapView overlays] containsObject:path]) {
            [self.mapView addOverlay:path];
        }
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView* pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
    }
    
    pinView.leftCalloutAccessoryView = [self newDirectionsCalloutView];
    pinView.canShowCallout = YES;
    pinView.image = [UIImage imageNamed:@"Alert"];
    pinView.calloutOffset = CGPointMake(0, 0);

    
    return pinView;
}

- (void)getDirections:(id)sender {
    self.directionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Maps App", @"Google Glass", nil];
    [self.directionsSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [self removeMapParallaxEffect];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if([overlay isKindOfClass:[K9DogPath class]]) {
        MKPolylineRenderer *renderer = [(K9DogPath *)overlay renderer];
        return renderer;
    } else if([overlay isKindOfClass:[K9PolylineBuilder class]]) {
        MKOverlayRenderer *renderer = [(K9PolylineBuilder *)overlay renderer];
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
    self.actionsSheet = [[UIActionSheet alloc] initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Take Photo", @"Record Audio", @"Make Annotation", nil];
    [self.actionsSheet showFromBarButtonItem:sender animated:YES];
    [self removeMapParallaxEffect];
}

- (void)recordAudio {
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(actionSheet == self.actionsSheet) {
        switch (buttonIndex) {
            case 0:
                [self takePhoto];
                break;
            case 1:
                [self recordAudio];
                break;
            case 2:
                [self enterAnnotationMode];
                break;
            default:
                break;
        }
        self.actionsSheet = nil;
    } else if(actionSheet == self.directionsSheet) {
        K9MapDirectionsMethod directionsMethod = (buttonIndex == 0 ? K9MapDirectionsMethodMapsApp : K9MapDirectionsMethodGoogleGlass);
        
        [self sendDirectionsTo:directionsMethod withLocation:self.event.location destinationName:self.event.title];

        self.directionsSheet = nil;
    }

    [self addMapParallaxEffect];
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
            frame.origin.y -= 1;
            frame.size.height += 2;
            [button setFrame:frame];
            
            
            UIRectCorner corners = 0;
            if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:0]]) {
                corners = UIRectCornerTopLeft | UIRectCornerTopRight;
            } else if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:([actionSheet numberOfButtons]-2)]]) {
                corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            } else if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:[actionSheet cancelButtonIndex]]]) {
                corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight);
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
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}


- (void)enterAnnotationMode {
    K9MapPanGestureRecognizer *panGesture = [[K9MapPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.maximumNumberOfTouches = 1;
    self.mapPanGestureRecognizer = panGesture;
    [self.mapView addGestureRecognizer:panGesture];
    
    self.mapAnnotation = [K9MapAnnotation new];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self.navigationItem setRightBarButtonItem:self.saveAnnotationBarButtonItem animated:YES];
}

- (IBAction)exitAnnotationMode:(id)sender {
    NSMutableArray *overlaysToRemove = [NSMutableArray array];
    for(id<MKOverlay> overlay in self.mapView.overlays) {
        if([overlay isKindOfClass:[K9PolylineBuilder class]]) {
            [overlaysToRemove addObject:overlay];
        }
    }
    [self.mapView removeOverlays:overlaysToRemove];
    
    if(self.mapAnnotation.polylines.count) {
        [self.event addResource:self.mapAnnotation progressHandler:nil];
    }
    
    [self.mapView removeGestureRecognizer:self.mapPanGestureRecognizer];
    self.mapPanGestureRecognizer = nil;
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.navigationItem setRightBarButtonItem:self.actionsBarButtonItem animated:YES];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    MKMapRect updateMapRect = MKMapRectNull;
    
    switch(recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.currentPolylineBuilder = [[K9PolylineBuilder alloc] initWithCoordinate:coordinate];
            [self.mapView addOverlay:self.currentPolylineBuilder];
            break;
        case UIGestureRecognizerStateChanged:
            updateMapRect = [self.currentPolylineBuilder addCoordinate:coordinate];
            break;
        case UIGestureRecognizerStateEnded:
            updateMapRect = [self.currentPolylineBuilder addCoordinate:coordinate];
            [self.mapAnnotation addPolyline:[self.currentPolylineBuilder polyline]];
            break;
        default:
            break;
    }
    
    if (!MKMapRectIsNull(updateMapRect)) {
        // There is a non null update rect.
        // Compute the currently visible map zoom scale
        MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
        // Find out the line width at this zoom scale and outset the updateRect by that amount
        CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
        updateMapRect = MKMapRectInset(updateMapRect, -lineWidth, -lineWidth);
        // Ask the overlay view to update just the changed area.
        [self.currentPolylineBuilder.renderer invalidatePath];
        [self.currentPolylineBuilder.renderer setNeedsDisplayInMapRect:updateMapRect];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = nil;
    if([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    K9Photo *photo = [K9Photo new];
    
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *userEventImages = [documents URLByAppendingPathComponent:@"userEventImages" isDirectory:YES];
                            
    if ([[NSFileManager defaultManager] createDirectoryAtURL:userEventImages withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSData *data = UIImageJPEGRepresentation(image, 0.75);
        time_t timestamp = (time_t) [[NSDate date] timeIntervalSince1970];
        NSURL *imageURL = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%ld.jpg", self.event.eventID, (unsigned long)timestamp] isDirectory:NO];
        
        if ([data writeToURL:imageURL atomically:NO]) {
            photo.URL = imageURL;
            [self.event addResource:photo progressHandler:nil];
            NSLog(@"the cachedImagedPath is %@",imageURL);
        } else {
            NSLog(@"Failed to cache image data to disk");
        }

    } else {
        NSLog(@"Error creating images directory");
    }

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end

@implementation K9DogPath (Renderer)

- (MKPolylineRenderer *)renderer {
    MKPolylineRenderer *renderer = objc_getAssociatedObject(self, @selector(renderer));
    if(!renderer) {
        renderer = [[MKPolylineRenderer alloc] initWithPolyline:[self polyline]];
        [renderer setStrokeColor:[[self dog] color]];
        [renderer setAlpha:0.7];
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

@implementation K9MapPanGestureRecognizer

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return YES;
}

@end
