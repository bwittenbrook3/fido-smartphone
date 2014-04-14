//
//  K9Event.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <MapKit/MKOverlay.h>

@class MKPolyline;
typedef NS_ENUM(NSInteger, K9EventType) {
    K9EventTypeSuspiciousItem,
    
};


extern NSString *const K9EventDidModifyResourcesNotification;

@class K9Dog;
@interface K9Event : NSObject

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList;

@property (nonatomic) NSInteger eventID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *eventDescription;
@property (nonatomic) K9EventType eventType;

@property (copy) NSDate *creationDate;
@property (copy) NSDate *updateDate;
@property (copy, nonatomic) NSArray *associatedDogs;

@property (copy, nonatomic) NSArray *dogPaths;

@property (copy, nonatomic) NSArray *resources;
- (void)addResource:(id)resource;

@property (copy, nonatomic) CLLocation *location;

@end


@interface K9DogPath : NSObject <MKOverlay>

@property (weak) K9Event *event;
@property (weak) K9Dog *dog;

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@property (readonly) MKPolyline *polyline;

@end