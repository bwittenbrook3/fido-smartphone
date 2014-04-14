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

#define RAND ((((float)rand() / RAND_MAX)-0.5)*0.0002)

NSString *const K9EventDidModifyResourcesNotification = @"K9EventDidModifyResourcesNotification";

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
        // TODO: Remove the extra test dog when the API supports it
        K9Dog *dog2 = [K9Dog new];
        dog2.name = @"Long Dog Name";
        dog2.image = [UIImage imageNamed:@"Sample Dog Image"];
        dog2.color = [UIColor blueColor];
        event.associatedDogs = @[dog, dog2];
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
    NSMutableArray *paths = [NSMutableArray array];
    for(K9Dog *dog in event.associatedDogs) {
        K9DogPath *path = [K9DogPath new];
        path.dog = dog;
        path.event = event;
        NSUInteger numCoordinates = arc4random_uniform(50) + 2;
        CLLocationCoordinate2D coordinates[numCoordinates];
        for(int i = 0; i < numCoordinates; i++) {
            CLLocationCoordinate2D lastCoord = CLLocationCoordinate2DMake(event.location.coordinate.latitude + RAND, event.location.coordinate.longitude + RAND);
            if(i != 0) {
                lastCoord = coordinates[i - 1];
            }
            coordinates[i] = CLLocationCoordinate2DMake(lastCoord.latitude + RAND, lastCoord.longitude + RAND);
        }
        [path setCoordinates:coordinates count:numCoordinates];
        [paths addObject:path];
    }
    event.dogPaths = paths;

    
    return event;
}

- (void)addResource:(id)resource {
    // TODO: Upload to server when web API supports it.
    self.resources = [self.resources arrayByAddingObject:resource];
    [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self];
}

@end

@implementation K9DogPath {
    __strong MKPolyline *polyline;
}
/*
MKMapPoint *points = self.points;
NSData *pointData = [NSData dataWithBytes:points length:self.pointCount * sizeof(MKMapPoint)];
[aCoder encodeObject:pointData forKey:@"points"];

NSData *pointData = [aCode decodeObjectForKey:@"points"];
MKMapPoint *points = malloc(pointData.length);
memcpy([pointData bytes], points);
self.points = points;
 */

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count {
    polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
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

- (MKPolyline *)polyline {
    return polyline;
}

@end
