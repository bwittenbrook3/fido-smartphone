//
//  K9MapViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/17/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

typedef NS_ENUM(NSInteger, K9MapDirectionsMethod) {
    K9MapDirectionsMethodMapsApp,
    K9MapDirectionsMethodGoogleGlass,
};


@interface K9MapViewController : UIViewController <MKMapViewDelegate>

@property (weak) IBOutlet MKMapView *mapView;

@end


@interface K9MapViewController (K9Protected)

- (UIView *)newDirectionsCalloutView;
- (void)getDirections:(id)sender;

- (void)addMapParallaxEffect;
- (void)removeMapParallaxEffect;

- (void)sendDirectionsTo:(K9MapDirectionsMethod)method withLocation:(CLLocation *)location destinationName:(NSString *)destinationName;

@end