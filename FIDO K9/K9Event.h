//
//  K9Event.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, K9EventType) {
    K9EventTypeSuspiciousItem,
    
};

@interface K9Event : NSObject

@property (nonatomic) NSInteger eventID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *description;
@property (nonatomic) K9EventType eventType;
@property (copy, nonatomic) NSArray *associatedDogs;

@end
