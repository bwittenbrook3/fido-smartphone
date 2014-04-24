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
#import "K9DogViewController.h"

static inline NSArray *sortDogs(NSArray *dogs) {
    return [dogs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];
}

@interface K9DogMapViewController()

@property (strong) NSMutableDictionary *precachedDogImages;

@end

@implementation K9DogMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.dogs) {
        self.dogs = sortDogs([[K9ObjectGraph sharedObjectGraph] fetchAllDogsWithCompletionHandler:^(NSArray *dogs) {
            self.dogs = sortDogs(dogs);
        }]);
    } else {
        [self reloadDogViewsAnimated:NO updateRegion:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDogs:(NSArray *)dogs {
    if(_dogs != dogs) {
        
        if(_dogs) {
            for(K9Dog *dog in _dogs) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:K9DogDidChangeLocationNotificationKey object:dog];
            }
        }
        
        _dogs = dogs;
        
        // Let's generate the dog images now, rather than on request (which could be when we're trying to animate our map view)
        [self precacheDogImages];
        
        if(self.isViewLoaded) {
            [self reloadDogViewsAnimated:YES updateRegion:YES];
        }
        
        for(K9Dog *dog in dogs) {
            __weak typeof(self) weakSelf = self;
            [[NSNotificationCenter defaultCenter] addObserverForName:K9DogDidChangeLocationNotificationKey object:dog queue:nil usingBlock:^(NSNotification *note) {
                [weakSelf reloadDogViewsAnimated:YES updateRegion:NO];
            }];
        }
    }
}

- (void)precacheDogImages {
    self.precachedDogImages = [NSMutableDictionary dictionaryWithCapacity:self.dogs.count];
    for(K9Dog *dog in self.dogs) {
        __block K9CircularBorderImageView *dogProfile = [[K9CircularBorderImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        dogProfile.backgroundColor = [UIColor clearColor];
        dogProfile.opaque = NO;
        
        __weak typeof(dogProfile) weakDogProfile = dogProfile;
        [dogProfile setImageWithURL:dog.imageURL placeholderImage:[K9Dog defaultDogImage] completion:^{
            weakDogProfile.borderColor = dog.color;
            weakDogProfile.borderWidth = 1;
            
            UIImage *dogProfileImage = [weakDogProfile screenshot];
            
            if([self.mapView viewForAnnotation:dog]) {
                MKAnnotationView* aView = [self.mapView viewForAnnotation:dog];
                aView.image = dogProfileImage;
            }

            [self.precachedDogImages setObject:dogProfileImage forKey:@(dog.dogID)];
        }];
    }
}

- (void)reloadDogViewsAnimated:(BOOL)animated updateRegion:(BOOL)updateRegion {
    
    NSMutableArray *annotationsToRemove = [NSMutableArray array];
    for(K9Dog *dog in self.mapView.annotations) {
        if(![self.dogs containsObject:dog]) {
            [annotationsToRemove addObject:dog];
        }
    }
    [self.mapView removeAnnotations:annotationsToRemove];
    
    if(updateRegion) {
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in self.dogs) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 50, 50);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(64 + 30, 30, 50 + 30, 30) animated:animated];
    }
    
    for(K9Dog *dog in self.dogs) {
        [self.mapView addAnnotation:dog];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listModeSegue"]) {
        K9DogListViewController *destination = [segue destinationViewController];
        [destination setDogs:self.dogs];
    } else if ([segue.identifier isEqualToString:@"selectDogSegue"]) {
        K9DogViewController *destination = [segue destinationViewController];
        [destination setDog:sender];
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
    
    annotationView.canShowCallout = YES;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = rightButton;
    
    annotationView.image = [self.precachedDogImages objectForKey:@(dog.dogID)]; //[[UIImage imageNamed:@"Paw"] replaceBlueWithColor:self.dog.color];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    K9Dog *dog = view.annotation;
    [self performSegueWithIdentifier:@"selectDogSegue" sender:dog];
}

@end
