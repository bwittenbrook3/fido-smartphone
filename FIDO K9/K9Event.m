//
//  K9Event.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Event.h"

#define ID_KEY @"id"
#define DOG_KEY @"vest_id"
#define ATTACHMENT_ID @"attachment_id"
#define CREATION_DATE @"created_at"
#define UPDATE_DATE @"updated_at"

#define TITLE_KEY @"alert"
#define DETAIL_KEY @"details"

#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"


@implementation K9Event

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList {    
    NSLog(@"%@", propertyList);

    K9Event *event = [K9Event new];
    
    NSInteger dogID = [[propertyList objectForKey:DOG_KEY] integerValue];
    NSInteger attachmentID = [[propertyList objectForKey:ATTACHMENT_ID] integerValue];
    
    event.eventID = [[propertyList valueForKeyPath:ID_KEY] integerValue];
    event.title = [propertyList objectForKey:TITLE_KEY];
    event.description = [propertyList objectForKey:DETAIL_KEY];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    event.creationDate = [formatter dateFromString:[propertyList objectForKey:CREATION_DATE]];
    event.updateDate = [formatter dateFromString:[propertyList objectForKey:UPDATE_DATE]];
    
    CGFloat latitude = [[propertyList objectForKey:LATITUDE_KEY] floatValue];
    CGFloat longitude = [[propertyList objectForKey:LONGITUDE_KEY] floatValue];
    event.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    return event;
}

@end
