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

#import "K9ModelUtilities.h"

#define NAME_KEY @"K9"
#define ID_KEY @"id"
#define OFFICER_NAME_KEY @"officer"
#define AGE_KEY @"age"
#define STATUS_KEY @"status"
#define URL_KEY @"url"


#define RAND ((((float)rand() / RAND_MAX)-0.5)*0.008)


@interface K9Dog()

@end

@implementation K9Dog


static UIImage *_defaultSharedImage;
+ (UIImage *)defaultDogImage {
    if(!_defaultSharedImage) {
        _defaultSharedImage = [UIImage imageNamed:@"Sample Dog Image"];
    }
    return _defaultSharedImage;
}

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList {
    NSLog(@"%@", propertyList);
    
    K9Dog *dog = [K9Dog new];

    dog.dogID = [[propertyList objectForKey:ID_KEY] integerValue];
    dog.name = objectWithEmptyCheck([propertyList objectForKey:NAME_KEY], @"Scout");
    dog.officerName = objectWithEmptyCheck([propertyList objectForKey:OFFICER_NAME_KEY], @"Officer Chad Michaels");
    dog.imageURL = [propertyList objectForKey:URL_KEY];
    
    dog.ageInMonths = [objectWithEmptyCheck([propertyList objectForKey:AGE_KEY], @(33)) integerValue];
    dog.status = objectWithEmptyCheck([propertyList objectForKey:STATUS_KEY], @"Off Duty");
    
    // TODO: Do this at some later point once the web APIs supports these kind of queries
    [[K9ObjectGraph sharedObjectGraph] fetchEventsForDogWithID:dog.dogID completionHandler:nil];
    [[K9ObjectGraph sharedObjectGraph] fetchAttachmentsForDogWithID:dog.dogID completionHandler:nil];
    
    // TODO: Use real dog color when web api supports it
    dog.color = [UIColor colorWithHue:(dog.dogID/8.0) saturation:0.9 brightness:1.0 alpha:1.0];
    
    dog.certifications = @[@"Explosive Detection"];
    
    
    // TODO: Get last known location when web API supports it.
    CGFloat latitude = 33.7721200 + RAND;
    CGFloat longitude = -84.392942 + RAND;
    dog.lastKnownLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
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
