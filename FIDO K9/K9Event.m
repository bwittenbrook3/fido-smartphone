//
//  K9Event.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Event.h"
#import "K9ObjectGraph.h"
#import "K9Dog.h"

#import "K9Photo.h"

#import <MapKit/MapKit.h>

#define ID_KEY @"id"
#define DOG_KEY @"vest_id"
#define ATTACHMENT_ID @"attachment_id"
#define CREATION_DATE @"created_at"
#define UPDATE_DATE @"updated_at"

#define TITLE_KEY @"alert"
#define DETAIL_KEY @"details"

#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"

@implementation K9Event

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList {    
    NSLog(@"%@", propertyList);

    K9Event *event = [K9Event new];
    
    NSInteger dogID = [[propertyList objectForKey:DOG_KEY] integerValue];
    NSInteger attachmentID = [[propertyList objectForKey:ATTACHMENT_ID] integerValue];
    
    K9Dog *dog = [[K9ObjectGraph sharedObjectGraph] dogWithID:dogID];
    if(!dog) {
        // TODO: Delay loading of dog objects until requested
        [[K9ObjectGraph sharedObjectGraph] fetchDogWithID:dogID completionHandler:^(K9Dog *dog) {
            if(dog) {
                event.associatedDogs = @[dog];
            }
        }];
    } else {
        event.associatedDogs = @[dog];
    }

    event.eventID = [[propertyList valueForKeyPath:ID_KEY] integerValue];
    event.title = [propertyList objectForKey:TITLE_KEY];
    event.eventDescription = [propertyList objectForKey:DETAIL_KEY];
    if((id)event.eventDescription == [NSNull null]) {
        event.eventDescription = nil;
    }
    
    // TODO: Get real resources when web API can give them.
    K9Photo *photo = [K9Photo new];
    photo.image = [UIImage imageNamed:@"SamplePhoto"];
    K9Photo *photo2 = [K9Photo new];
    photo2.image = [UIImage imageNamed:@"SamplePhoto"];
    event.resources = @[photo, photo2];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    event.creationDate = [formatter dateFromString:[propertyList objectForKey:CREATION_DATE]];
    event.updateDate = [formatter dateFromString:[propertyList objectForKey:UPDATE_DATE]];
    
    CGFloat latitude = [[propertyList objectForKey:LATITUDE_KEY] floatValue];
    CGFloat longitude = [[propertyList objectForKey:LONGITUDE_KEY] floatValue];
    
    latitude = 33.7721200;
    longitude = -84.392942;
    event.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    // TODO: Get the real paths when web API can give them
    K9DogPath *path = [K9DogPath new];
    path.dog = [event.associatedDogs firstObject];
    path.event = event;
    CLLocationCoordinate2D coord = event.location.coordinate;
    CLLocationCoordinate2D coordinates[4] = {
        CLLocationCoordinate2DMake(coord.latitude + 0.0005, coord.longitude - 0.0005),
        CLLocationCoordinate2DMake(coord.latitude + 0.0005, coord.longitude),
        CLLocationCoordinate2DMake(coord.latitude + 0.0005, coord.longitude + 0.0005),
        CLLocationCoordinate2DMake(coord.latitude + 0.001, coord.longitude + 0.001)
    };
    [path setCoordinates:coordinates count:4];
    event.dogPaths = @[path];

    
    return event;
}

@end

@implementation K9DogPath {
    __strong MKPolyline *polyline;
}

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count {
    polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
}

- (MKOverlayRenderer *)overlayRenderer {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
    [renderer setStrokeColor:[[[self dog] color] colorWithAlphaComponent:0.7]];
    return renderer;
}

- (CLLocationCoordinate2D)coordinate {
    return [polyline coordinate];
}

- (MKMapRect)boundingMapRect {
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [polyline intersectsMapRect:mapRect];
}

@end
