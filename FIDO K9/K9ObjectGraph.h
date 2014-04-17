//
//  K9ObjectGraph.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class K9Event, K9Dog, K9Training;


extern NSString *const K9EventWasAddedNotification;
extern NSString *const K9ModifiedEventKey;

extern NSString *const K9TrainingWasAddedNotification;

@interface K9ObjectGraph : NSObject

+ (K9ObjectGraph *)sharedObjectGraph;


// Events
@property (readonly, nonatomic) NSArray *allEvents;
- (NSArray *)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler;

- (K9Event *)eventWithID:(NSInteger)eventID;
- (K9Event *)fetchEventWithID:(NSInteger)eventID completionHandler:(void (^)(K9Event *event))completionHandler;


// Dogs
@property (readonly, nonatomic) NSArray *allDogs;
- (NSArray *)fetchAllDogsWithCompletionHandler:(void (^)(NSArray *dogs))completionHandler;

- (K9Dog *)dogWithID:(NSInteger)eventID;
- (K9Dog *)fetchDogWithID:(NSInteger)dogID completionHandler:(void (^)(K9Dog *dog))completionHandler;

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
