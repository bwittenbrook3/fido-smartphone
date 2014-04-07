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

@interface K9EventViewController ()

@property (strong) IBOutlet UIView *detailContainerView;
@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (weak) IBOutlet MKMapView *mapView;

@end

@implementation K9EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    }
}

- (void)updateEventViews {
//    [self.mapView setRegion:MKCoordinateRegionMake(self.event.location.coordinate, MKCoordinateSpanMake(0.005, 0.005))];
    [self setLocation:self.event.location.coordinate inBottomCenterOfMapView:self.mapView];
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = self.event.location.coordinate;
    pa.title = self.event.title;
    pa.subtitle = self.event.description;
    [self.mapView addAnnotation:pa];
    self.navigationItem.title = [self.event title];
}

-(void)setLocation:(CLLocationCoordinate2D)location inBottomCenterOfMapView:(MKMapView*)mapView {
    //Get the region (with the location centered) and the center point of that region
    MKCoordinateRegion oldRegion = [mapView regionThatFits:MKCoordinateRegionMakeWithDistance(location, 200, 200)];
    CLLocationCoordinate2D centerPointOfOldRegion = oldRegion.center;
    
    //Create a new center point (I added a quarter of oldRegion's latitudinal span)
    CLLocationCoordinate2D centerPointOfNewRegion = CLLocationCoordinate2DMake(centerPointOfOldRegion.latitude + oldRegion.span.latitudeDelta/6.0, centerPointOfOldRegion.longitude);
    
    //Create a new region with the new center point (same span as oldRegion)
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(centerPointOfNewRegion, oldRegion.span);
    
    //Set the mapView's region
    [mapView setRegion:newRegion animated:YES];
}

@end
