//
//  K9ObjectGraph.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class K9Event, K9Dog, K9Training, K9Resource;


extern NSString *const K9EventWasAddedNotification;
extern NSString *const K9ModifiedEventKey;

extern NSString *const K9TrainingWasAddedNotification;

@interface K9ObjectGraph : NSObject

+ (K9ObjectGraph *)sharedObjectGraph;

// Events
- (void)fetchEventPusherChannelWithCompletionHandler:(void (^)(NSString *pusherChannel))completionHandler;

@property (readonly, nonatomic) NSArray *allEvents;
- (NSArray *)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler;

- (K9Event *)eventWithID:(NSInteger)eventID;
- (K9Event *)fetchEventWithID:(NSInteger)eventID completionHandler:(void (^)(K9Event *event))completionHandler;
- (void)fetchResourcesForEventWithID:(NSInteger)eventID completionHandler:(void (^)(NSArray *resources))completionHandler;
- (void)uploadResource:(K9Resource *)resource forEvent:(K9Event *)event;

// Dogs
@property (readonly, nonatomic) NSArray *allDogs;
- (NSArray *)fetchAllDogsWithCompletionHandler:(void (^)(NSArray *dogs))completionHandler;

- (K9Dog *)dogWithID:(NSInteger)eventID;
- (K9Dog *)fetchDogWithID:(NSInteger)dogID completionHandler:(void (^)(K9Dog *dog))completionHandler;

- (void)fetchImageURLForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSURL *url))completionHandler;

- (NSArray *)eventsForDogWithID:(NSInteger)dogID;
- (NSArray *)fetchEventsForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSArray *events))completionHandler;

- (NSArray *)attachmentsForDogWithID:(NSInteger)dogID;
- (NSArray *)fetchAttachmentsForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSArray *events))completionHandler;

- (NSArray *)trainingForDogWithID:(NSInteger)dogID;


// Attachments
@property (readonly, nonatomic) NSArray *allAttachments;


// Training
@property (readonly, nonatomic) NSArray *allTraining;
- (void)addTraining:(K9Training *)training;

@end
