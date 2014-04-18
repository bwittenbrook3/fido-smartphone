//
//  K9DogMapViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogMapViewController.h"
#import "K9DogListViewController.h"
#import "K9ObjectGraph.h"
#import "K9Dog+Annotation.h"
#import "K9CircularBorderImageView.h"
#import <MapKit/MapKit.h>
#import "UIView+Screenshot.h"

static inline NSArray *sortDogs(NSArray *dogs) {
    return [dogs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];
}

@implementation K9DogMapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.dogs) {
        self.dogs = sortDogs([[K9ObjectGraph sharedObjectGraph] fetchAllDogsWithCompletionHandler:^(NSArray *dogs) {
            self.dogs = sortDogs(dogs);
        }]);
    } else {
        [self reloadDogViews];
    }
}

- (void)setDogs:(NSArray *)dogs {
    if(_dogs != dogs) {
        _dogs = dogs;
        if(self.isViewLoaded) {
            [self reloadDogViews];
        }
    }
}

- (void)reloadDogViews {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.dogs) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 50, 50);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(64 + 30, 30, 50 + 30, 30) animated:NO];
    
    for(K9Dog *dog in self.dogs) {
        [self.mapView addAnnotation:dog];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listModeSegue"]) {
        K9DogListViewController *destination = [segue destinationViewController];
        [destination setDogs:self.dogs];
    }
}

#define ANNOTATION_VIEW_ID (@"MKPinAnnotationView")
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    K9Dog *dog = annotation;
    
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_VIEW_ID];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_VIEW_ID];
    }
    
    annotationView.leftCalloutAccessoryView = [self newDirectionsCalloutView];
    annotationView.canShowCallout = YES;
    
    __block K9CircularBorderImageView *dogProfile = [[K9CircularBorderImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    dogProfile.backgroundColor = [UIColor clearColor];
    dogProfile.opaque = NO;
    
    __weak typeof(dogProfile) weakDogProfile = dogProfile;
    [dogProfile setImageWithURL:dog.imageURL placeholderImage:[K9Dog defaultDogImage] completion:^{
        weakDogProfile.borderColor = dog.color;
        weakDogProfile.borderWidth = 1;
        
        UIImage *dogProfileImage = [weakDogProfile screenshot];
        annotationView.image = dogProfileImage; //[[UIImage imageNamed:@"Paw"] replaceBlueWithColor:self.dog.color];
    }];
        
    return annotationView;
}

@end
