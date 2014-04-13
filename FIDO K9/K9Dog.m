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

#define NAME_KEY @"K9"
#define ID_KEY @"id"
#define OFFICER_NAME_KEY @"officer"

@implementation K9Dog

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList {
    NSLog(@"%@", propertyList);
    
    K9Dog *dog = [K9Dog new];

    dog.dogID = [[propertyList objectForKey:ID_KEY] integerValue];
    dog.name = [propertyList objectForKey:NAME_KEY];
    dog.officerName = [propertyList objectForKey:OFFICER_NAME_KEY];
    
    // TODO: Do this at some later point once the web APIs supports these kind of queries
    [[K9ObjectGraph sharedObjectGraph] fetchEventsForDogWithID:dog.dogID completionHandler:nil];
    [[K9ObjectGraph sharedObjectGraph] fetchAttachmentsForDogWithID:dog.dogID completionHandler:nil];
    
    dog.color = [UIColor redColor];
    
    return dog;
}

- (NSArray *)events {
    return [[K9ObjectGraph sharedObjectGraph] eventsForDogWithID:self.dogID];
}

- (NSArray *)attachments {
    return [[K9ObjectGraph sharedObjectGraph] attachmentsForDogWithID:self.dogID];
}

@end
