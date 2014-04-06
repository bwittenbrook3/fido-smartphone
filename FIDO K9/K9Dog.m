//
//  K9Dog.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Dog.h"

#define NAME_KEY @"K9"
#define ID_KEY @"id"
#define OFFICER_NAME_KEY @"officer"

@implementation K9Dog

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList {
    K9Dog *dog = [K9Dog new];

    dog.dogID = [[propertyList objectForKey:ID_KEY] integerValue];
    dog.name = [propertyList objectForKey:NAME_KEY];
    dog.officerName = [propertyList objectForKey:OFFICER_NAME_KEY];
    
    return dog;
}

@end
