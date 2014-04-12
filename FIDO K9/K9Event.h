//
//  K9Event.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

typedef NS_ENUM(NSInteger, K9EventType) {
    K9EventTypeSuspiciousItem,
    
};

@interface K9Event : NSObject

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList;

@property (nonatomic) NSInteger eventID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *eventDescription;
@property (nonatomic) K9EventType eventType;

@property (copy) NSDate *creationDate;
@property (copy) NSDate *updateDate;
@property (copy, nonatomic) NSArray *associatedDogs;

@property (copy, nonatomic) CLLocation *location;

@end
