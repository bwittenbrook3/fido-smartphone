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
    K9EventTypeSuspiciousPerson,
    K9EventTypeSuspiciousBag
    
};

extern NSString *const K9EventDidModifyResourcesNotification;
extern NSString *const K9EventAddedResourcesNotificationKey;

@class K9Dog;
@interface K9Event : NSObject

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList;

@property (nonatomic) NSInteger eventID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *eventDescription;
@property (nonatomic) K9EventType eventType;

@property (copy) NSDate *creationDate;
@property (copy) NSDate *updateDate;
@property (copy, nonatomic) NSArray *assignedDogs;

@property (getter = isStable) BOOL stable;

@property (copy, nonatomic) NSArray *dogPaths;
- (void)refreshDogPathsWithCompletionHandler:(void (^)(void))completionHandler;

@property (copy, nonatomic) NSArray *activations;

@property (copy, nonatomic) NSArray *resources;
- (void)addResource:(id)resource progressHandler:(void (^)(CGFloat progress))progressHandler;

@property (copy, nonatomic) CLLocation *location;

@end


@interface K9DogPath : NSObject <MKOverlay>

@property (weak) K9Event *event;
@property (weak) K9Dog *dog;

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

@property (readonly) MKPolyline *polyline;

@end