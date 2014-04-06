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


- (NSArray *)fetchAllDogsWithCompletionHandler:(void (^)(NSArray *dogs))completionHandler;
- (NSArray *)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler;

- (K9Event *)fetchEventWithID:(NSInteger)eventID completionHandler:(void (^)(K9Event *event))completionHandler;


@property (readonly, nonatomic) NSArray *allEvents;
@property (readonly, nonatomic) NSArray *allDogs;

- (K9Event *)eventWithID:(NSInteger)eventID;
- (K9Event *)dogWithID:(NSInteger)eventID;

@end
