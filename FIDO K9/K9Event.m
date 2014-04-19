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
NSString *const K9EventAddedResourcesNotificationKey = @"K9EventAddedResourcesNotificationKey";

@implementation K9Event

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList {    

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
        dog2.color = [UIColor colorWithHue:((float)rand() / RAND_MAX) saturation:0.9 brightness:1.0 alpha:1.0];
        event.associatedDogs = @[dog, dog2];
    }

    event.eventID = [[propertyList valueForKeyPath:ID_KEY] integerValue];
    event.title = [propertyList objectForKey:TITLE_KEY];
    event.eventDescription = [propertyList objectForKey:DETAIL_KEY];
    
    // TODO: Get event type from web api when it supports it
    event.eventType = K9EventTypeSuspiciousBag;
    if ([[event.title lowercaseString] rangeOfString:@"item"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousItem;
    } else if ([[event.title lowercaseString] rangeOfString:@"person"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousPerson;
    } else if ([[event.title lowercaseString] rangeOfString:@"gun"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousPerson;
    } else if ([[event.title lowercaseString] rangeOfString:@"box"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousItem;
    }
        
    if((id)event.eventDescription == [NSNull null]) {
        event.eventDescription = nil;
    }
    
    [[K9ObjectGraph sharedObjectGraph] fetchResourcesForEventWithID:event.eventID completionHandler:^(NSArray *resources) {
        event.resources = resources;
    }];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    event.creationDate = [formatter dateFromString:[propertyList objectForKey:CREATION_DATE]];
    event.updateDate = [formatter dateFromString:[propertyList objectForKey:UPDATE_DATE]];
    
    CGFloat latitude = [[propertyList objectForKey:LATITUDE_KEY] floatValue];
    CGFloat longitude = [[propertyList objectForKey:LONGITUDE_KEY] floatValue];
    
    if(abs(latitude) < 0.001) latitude = 33.7721200;
    if(abs(longitude)  < 0.001) longitude = -84.392942;
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

- (void)addResource:(K9Resource *)resource progressHandler:(void (^)(CGFloat progress))progressHandler{
    self.resources = [self.resources arrayByAddingObject:resource];
    
    NSDictionary *userInfo = @{K9EventAddedResourcesNotificationKey : @[resource]};
    [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self userInfo:userInfo];
    
    resource.uploaded = NO;
    [[K9ObjectGraph sharedObjectGraph] uploadResource:resource forEvent:self progressHandler:^(CGFloat progress) {
        NSDictionary *progressInfo = @{@"progress": @(progress)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progress" object:resource userInfo:progressInfo];
        if(progress > 0.99) {
            resource.uploaded = YES;
        }
    }];
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
