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

#import <objc/runtime.h>

@interface K9EventViewController () <K9EventDetailViewControllerDelegate>

@property (strong) IBOutlet UIView *detailContainerView;
@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (weak) IBOutlet MKMapView *mapView;

@property (strong) K9EventDetailViewController *detailsViewController;

@end

@interface K9DogPath (Renderer)

@property (readonly) MKPolylineRenderer *renderer;

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
        [[(K9DogPath *)overlay renderer] setAlpha:0.7];
        return [(K9DogPath *)overlay renderer];
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

@end

@implementation K9DogPath (Renderer)

- (MKPolylineRenderer *)renderer {
    MKPolylineRenderer *renderer = objc_getAssociatedObject(self, _cmd);
    if(!renderer) {
        renderer = [[MKPolylineRenderer alloc] initWithPolyline:[self polyline]];
        [renderer setStrokeColor:[[self dog] color]];
        objc_setAssociatedObject(self, _cmd, renderer, OBJC_ASSOCIATION_RETAIN);
    }
    return renderer;

}
@end
