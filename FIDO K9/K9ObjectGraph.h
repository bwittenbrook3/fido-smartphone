//
//  K9ObjectGraph.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class K9Event;
@interface K9ObjectGraph : NSObject

+ (K9ObjectGraph *)sharedObjectGraph;


- (BOOL)fetchAllDogsWithCompletionHandler:(void (^)(NSArray *dogs))completionHandler;
- (BOOL)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler;

- (BOOL)fetchEventWithID:(NSInteger)eventID completionHandler:(void (^)(K9Event *event))completionHandler;


@property (copy, nonatomic) NSArray *allEvents;
@property (copy, nonatomic) NSArray *allDogs;

- (K9Event *)eventWithID:(NSInteger)eventID;

@end
