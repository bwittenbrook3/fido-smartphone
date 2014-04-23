//
//  K9Dog.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Dog.h"
#import "K9Event.h"
#import "K9ObjectGraph.h"
#import "UIColor+Hex.h"

#import "K9ModelUtilities.h"

#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "PTPusher.h"
#import "K9ObjectGraph.h"

#define NAME_KEY @"K9"
#define ID_KEY @"id"
#define OFFICER_NAME_KEY @"officer"
#define AGE_KEY @"age"
#define STATUS_KEY @"status"
#define URL_KEY @"url"
#define COLOR_KEY @"color"


#define RECENT_LOCATIONS_KEY @"recent_locations"


#define RAND ((((float)rand() / RAND_MAX)-0.5)*0.008)


NSString *const K9DogDidChangeLocationNotificationKey = @"K9DogDidChangeLocationNotificationKey";


@interface K9Dog() <PTPusherDelegate>
@end

@implementation K9Dog {
    __strong PTPusher *_client;
}


static UIImage *_defaultSharedImage;
+ (UIImage *)defaultDogImage {
    if(!_defaultSharedImage) {
        _defaultSharedImage = [UIImage imageNamed:@"Sample Dog Image"];
    }
    return _defaultSharedImage;
}

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList {
    K9Dog *dog = [K9Dog new];

    dog.dogID = [[propertyList objectForKey:ID_KEY] integerValue];
    
    NSLog(@"created dog with id: %ld", dog.dogID);
    
    dog.name = objectWithEmptyCheck([propertyList objectForKey:NAME_KEY], @"Scout");
    dog.officerName = objectWithEmptyCheck([propertyList objectForKey:OFFICER_NAME_KEY], @"Officer Chad Michaels");
    dog.imageURL = [propertyList objectForKey:URL_KEY];
    
    dog.ageInMonths = [objectWithEmptyCheck([propertyList objectForKey:AGE_KEY], @(33)) integerValue];
    dog.status = objectWithEmptyCheck([propertyList objectForKey:STATUS_KEY], @"Off Duty");
    
    // TODO: Do this at some later point once the web APIs supports these kind of queries
    [[K9ObjectGraph sharedObjectGraph] fetchEventsForDogWithID:dog.dogID completionHandler:nil];
    [[K9ObjectGraph sharedObjectGraph] fetchAttachmentsForDogWithID:dog.dogID completionHandler:nil];
    
    id colorInt = objectWithEmptyCheck([propertyList objectForKey:COLOR_KEY],nil);
    dog.color = [UIColor colorWithColorCode:[colorInt integerValue]];
    
    dog.certifications = @[@"Explosive Detection"];
    
    NSArray *locations = locationsArrayFromBizarreLocationsString(objectWithEmptyCheck([propertyList objectForKey:RECENT_LOCATIONS_KEY], nil));
    if(locations) {
        NSDictionary *location = [locations lastObject];
        CGFloat latitude = [[location objectForKey:@"latitude"] floatValue];
        CGFloat longitude = [[location objectForKey:@"longitude"] floatValue];
        
        if(abs(latitude) < 1.1) {
            latitude = 33.774708 + RAND;
        }
        if(abs(longitude)  < 1.1) {
            longitude = -84.394912 + RAND;
        }
        
        dog.lastKnownLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    } else {
        CGFloat latitude = 33.774708 + RAND;
        CGFloat longitude = -84.394912 + RAND;
        dog.lastKnownLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    
    
    if(!dog->_client) {
#define PUSHER_API_KEY @"e7b137a34da31bed01d9"
        dog->_client = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:dog encrypted:YES];
        [dog->_client connect];
        
        [[K9ObjectGraph sharedObjectGraph] fetchDogLocationChangeChannelForDogWithID:dog.dogID withCompletionHandler:^(NSString *pusherChannel) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [dog->_client subscribeToChannelNamed:pusherChannel];
                [dog->_client bindToEventNamed:@"sync" handleWithBlock:^(PTPusherEvent *event) {
                    
                    [[K9ObjectGraph sharedObjectGraph] fetchLocationForDogWithID:dog.dogID withCompletionHandler:^(CLLocationCoordinate2D coordinate) {
                        dog.lastKnownLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                        [[NSNotificationCenter defaultCenter] postNotificationName:K9DogDidChangeLocationNotificationKey object:dog userInfo:nil];
                    }];
                }];
            });
        }];
    }
    
    return dog;
}

- (NSString *)formattedAge {
    NSUInteger years = self.ageInMonths/12;
    NSUInteger months = self.ageInMonths%12;
    
    NSString *formattedAge;
    
    NSString *yearString = years == 1 ? @"year" : @"years";
    NSString *monthString = months == 1 ? @"month" : @"months";
    
    if(years) {
        if(months) {
            formattedAge = [NSString stringWithFormat:@"%d %@, %d %@", (int)years, yearString, (int)months, monthString];
        } else {
            formattedAge = [NSString stringWithFormat:@"%d %@", (int)years, yearString];
        }
    } else {
        formattedAge = [NSString stringWithFormat:@"%d %@", (int)months, monthString];
    }
    
    return formattedAge;
}


- (NSArray *)events {
    return [[K9ObjectGraph sharedObjectGraph] eventsForDogWithID:self.dogID];
}

- (NSArray *)attachments {
    return [[K9ObjectGraph sharedObjectGraph] attachmentsForDogWithID:self.dogID];
}

@end
