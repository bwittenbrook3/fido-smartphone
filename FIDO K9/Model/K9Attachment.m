//
//  K9Attachment.m
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Attachment.h"
#import "K9ObjectGraph.h"


#define NAME_KEY @"name"
#define ID_KEY @"id"
#define DESCRIPTION_KEY @"description"
#define DOG_ID_KEY @"vest_id"


@implementation K9Attachment

+ (K9Attachment *)attachmentWithPropertyList:(NSDictionary *)propertyList {
    K9Attachment *attachment = [K9Attachment new];
    
    attachment.attachmentID = [[propertyList objectForKey:ID_KEY] integerValue];
    attachment.name = [propertyList objectForKey:NAME_KEY];
    attachment.attachmentDescription = [propertyList objectForKey:DESCRIPTION_KEY];
    
    NSInteger dogID = [[propertyList objectForKey:DOG_ID_KEY] integerValue];
    
    K9Dog *dog = [[K9ObjectGraph sharedObjectGraph] dogWithID:dogID];
    if(!dog) {
        // TODO: Delay loading of dog objects until requested
        [[K9ObjectGraph sharedObjectGraph] fetchDogWithID:dogID completionHandler:^(K9Dog *dog) {
            if(dog) {
                attachment.associatedDogs = @[dog];
            }
        }];
    } else {
        attachment.associatedDogs = @[dog];
    }
    
    return attachment;
}

@end
