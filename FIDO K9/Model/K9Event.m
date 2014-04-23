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
#import <Foundation/NSJSONSerialization.h>


#import "K9Photo.h"
#import "K9ModelUtilities.h"

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

#define RECENT_LOCATIONS_KEY @"recent_locations"

#define STABLE_KEY @"event_type"

#define RAND ((((float)rand() / RAND_MAX)-0.5)*0.0002)

NSString *const K9EventDidModifyResourcesNotification = @"K9EventDidModifyResourcesNotification";
NSString *const K9EventAddedResourcesNotificationKey = @"K9EventAddedResourcesNotificationKey";

@implementation K9Event

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList {
    NSLog(@"%@", propertyList);


    K9Event *event = [K9Event new];
    
    NSInteger dogID = [[propertyList objectForKey:DOG_KEY] integerValue];
    NSInteger attachmentID = [[propertyList objectForKey:ATTACHMENT_ID] integerValue];
    
    NSArray *locations = locationsArrayFromBizarreLocationsString(objectWithEmptyCheck([propertyList objectForKey:RECENT_LOCATIONS_KEY], nil));

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
    
    event.resources = @[];
    
    [[K9ObjectGraph sharedObjectGraph] fetchResourcesForEventWithID:event.eventID completionHandler:^(NSArray *resources) {
        [event addResources:resources];
    }];
    
    
    NSString *stableString =  objectWithEmptyCheck([propertyList valueForKeyPath:STABLE_KEY], nil);
    if(stableString && [[stableString lowercaseString] rangeOfString:@"unstable"].location != NSNotFound) {
        event.stable = NO;
    } else {
        event.stable = YES;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    event.creationDate = [formatter dateFromString:[propertyList objectForKey:CREATION_DATE]];
    event.updateDate = [formatter dateFromString:[propertyList objectForKey:UPDATE_DATE]];
    
    CGFloat latitude = [[propertyList objectForKey:LATITUDE_KEY] floatValue];
    CGFloat longitude = [[propertyList objectForKey:LONGITUDE_KEY] floatValue];
    
    if(abs(latitude) < 1.1) {
        latitude = 33.773451;
    }
    if(abs(longitude)  < 1.1) {
        longitude = -84.392783;
#if !PRESENTING
        event.title = [event.title stringByAppendingString:@"*"];
#endif
    }
    event.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    K9Dog *dog = [[K9ObjectGraph sharedObjectGraph] dogWithID:dogID];
    if(!dog) {
        // TODO: Delay loading of dog objects until requested
        [[K9ObjectGraph sharedObjectGraph] fetchDogWithID:dogID completionHandler:^(K9Dog *dog) {
            if(dog) {
                event.assignedDogs = @[dog];
            }
            if(dog && locations) {
                event.dogPaths = @[[self _generateDogPathFromLocationArray:locations forEvent:event withDog:dog]];
            } else {
                [event _generatePaths];
            }
        }];
    } else {
        // TODO: Remove the extra test dog when the API supports it
        K9Dog *dog2 = [[K9ObjectGraph sharedObjectGraph] dogWithID:(dogID+1)];
        if(!locations && dog2) {
            K9Dog *dog3 = [[K9ObjectGraph sharedObjectGraph] dogWithID:(dogID+2)];
            if(dog3) {
                event.assignedDogs = @[dog, dog2, dog3];
            } else {
                event.assignedDogs = @[dog, dog2];
            }
        } else {
            event.assignedDogs = @[dog];
        }
        
        
        if(locations) {
            event.dogPaths = @[[self _generateDogPathFromLocationArray:locations forEvent:event withDog:dog]];
        } else {
            // TODO: Get the real paths when web API can give them
            [event _generatePaths];
        }
    }
    
    return event;
}

- (void)_generatePaths {
    NSMutableArray *paths = [NSMutableArray array];
    for(K9Dog *dog in self.assignedDogs) {
        K9DogPath *path = [K9DogPath new];
        path.dog = dog;
        path.event = self;
        NSUInteger numCoordinates = arc4random_uniform(50) + 2;
        CLLocationCoordinate2D coordinates[numCoordinates];
        for(int i = 0; i < numCoordinates; i++) {
            CLLocationCoordinate2D lastCoord = CLLocationCoordinate2DMake(self.location.coordinate.latitude + RAND, self.location.coordinate.longitude + RAND);
            if(i != 0) {
                lastCoord = coordinates[i - 1];
            }
            coordinates[i] = CLLocationCoordinate2DMake(lastCoord.latitude + RAND, lastCoord.longitude + RAND);
        }
        [path setCoordinates:coordinates count:numCoordinates];
        [paths addObject:path];
    }
    
#if !PRESENTING
    self.title = [self.title stringByAppendingString:@"-"];
#endif
    
    self.dogPaths = paths;
}

- (void)addResources:(NSArray *)resources {
    self.resources = [self.resources arrayByAddingObjectsFromArray:resources];
    
    NSDictionary *userInfo = @{K9EventAddedResourcesNotificationKey : resources};
    [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self userInfo:userInfo];
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

+ (K9DogPath *)_generateDogPathFromLocationArray:(NSArray *)locations forEvent:(K9Event *)event withDog:(K9Dog *)dog {
    
    K9DogPath *dogPath = [K9DogPath new];
    dogPath.dog = dog;
    dogPath.event = event;

    NSUInteger numCoordinates = locations.count;
    CLLocationCoordinate2D coordinates[numCoordinates];
    
    CLLocationCoordinate2D lastGoodLocation = event.location.coordinate;
    
    for(int i = 0; i < numCoordinates; i++) {
        NSDictionary *point = [locations objectAtIndex:i];
        CGFloat latitude = [[point objectForKey:@"latitude"] floatValue];
        CGFloat longitude = [[point objectForKey:@"longitude"] floatValue];
        
        if(abs(latitude) < 1.1) latitude = lastGoodLocation.latitude;
        if(abs(longitude)  < 1.1) {
            longitude = lastGoodLocation.longitude;
            
#if !PRESENTING
            if([event.title rangeOfString:@"+"].location == NSNotFound) {
               event.title = [event.title stringByAppendingString:@"+"];
            }
#endif
        }

        coordinates[i] = CLLocationCoordinate2DMake(latitude, longitude);
        lastGoodLocation = coordinates[i];
    }

    
    [dogPath setCoordinates:coordinates count:numCoordinates];

    
    return dogPath;
}

@end

@implementation K9DogPath {
    __strong MKPolyline *polyline;
}

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
