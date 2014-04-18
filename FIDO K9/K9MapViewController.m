//
//  K9MapViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/17/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9MapViewController.h"
#import "UIColor+DefaultTintColor.h"
#import "K9Preferences.h"

#import <MapKit/MapKit.h>

@interface K9MapViewController ()

@property (strong) UIMotionEffectGroup *mapEffects;

@end

@implementation K9MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.mapView) {
        self.mapView.delegate = self;
        self.mapView.tintColor = [UIColor defaultSystemTintColor];
        
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
        
        // Don't always use the user location (as it would cause the Permission Alert to popup unnecessarily. Only show it if they've already accepted before.
        if([K9Preferences locationPreference] == K9PreferencesLocationAbsoluteAccepted) {
            [self.mapView setShowsUserLocation:YES];
        }
    }
}

- (void)addMapParallaxEffect {
    if(![[self.mapView motionEffects] containsObject:self.mapEffects]) {
        [self.mapView addMotionEffect:self.mapEffects];
    }
}

- (void)removeMapParallaxEffect {
    if([[self.mapView motionEffects] containsObject:self.mapEffects]) {
        [self.mapView removeMotionEffect:self.mapEffects];
    }
}

- (UIView *)newDirectionsCalloutView {
    UIButton *calloutView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    calloutView.titleLabel.text = @"Route";
    calloutView.backgroundColor = [UIColor blueColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Police Car"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *directionsLabel = [[UILabel alloc] init];
    [directionsLabel setText:@"Route"];
    [directionsLabel setFont:[UIFont boldSystemFontOfSize:11]];
    [directionsLabel setTextColor:[UIColor whiteColor]];
    [directionsLabel setTextAlignment:NSTextAlignmentCenter];
    directionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [calloutView addSubview:imageView];
    [calloutView addSubview:directionsLabel];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [calloutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(2)-[imageView]-(-1)-[directionsLabel]-(7)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(imageView, directionsLabel)]];
    [calloutView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[directionsLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings( directionsLabel)]];
    
    
    [calloutView addTarget:self action:@selector(updateButtonColor:) forControlEvents:UIControlEventTouchDown];
    [calloutView addTarget:self action:@selector(releaseButtonColor:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [calloutView addTarget:self action:@selector(getDirections:) forControlEvents:UIControlEventTouchUpInside];
    
    return calloutView;
}

- (void)updateButtonColor:(id)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.6 alpha:1.0]];
}

- (void)releaseButtonColor:(id)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1.0 alpha:1.0]];
}

- (void)getDirections:(id)sender {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [self sendDirectionsTo:K9MapDirectionsMethodMapsApp withLocation:location destinationName:nil];
}

- (void)sendDirectionsTo:(K9MapDirectionsMethod)method withLocation:(CLLocation *)location destinationName:(NSString *)destinationName {
    switch (method) {
        case K9MapDirectionsMethodMapsApp:
            [self sendDirectionsToMapsAppWithLocation:location destinationName:destinationName];
            break;
        case K9MapDirectionsMethodGoogleGlass:
            [self sendDirectionsToGlassWithLocation:location];
            break;
        default:
            break;
    }
}

- (void)sendDirectionsToGlassWithLocation:(CLLocation *)location {
    // TODO! Will there be a nice iPhone-Glass pairing API? Just send this over that once there is
}

- (void)sendDirectionsToMapsAppWithLocation:(CLLocation *)location destinationName:(NSString *)destinationName {
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:place];
    if(destinationName) {
        destination.name = destinationName;
    }
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}

@end
