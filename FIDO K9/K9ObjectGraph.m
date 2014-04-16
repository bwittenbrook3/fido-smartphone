//
//  K9ObjectGraph.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9ObjectGraph.h"
#import "AFHTTPSessionManager.h"
#import "K9Dog.h"
#import "K9Attachment.h"
#import "K9Event.h"
#import "K9Training.h"

NSString *const K9EventWasAddedNotification = @"K9EventWasAddedNotification";
NSString *const K9ModifiedEventKey = @"K9ModifiedEventKey";

NSString *const K9TrainingWasAddedNotification = @"K9TrainingWasAddedNotification";


static NSString * const baseURLString = @"http://fido-api.herokuapp.com/api/";
static NSString * const fidoUsername = @"FiDo";
static NSString * const fidoPassword = @"b40eb04e7874876cc72f0475b6b6efc3";

@interface K9ObjectGraph()
@property (strong) AFHTTPSessionManager *sessionManager;
@property (strong) NSMutableDictionary *eventDictionary;
@property (strong) NSMutableDictionary *dogDictionary;
@property (strong) NSMutableDictionary *trainingDictionary;
@property (strong) NSMutableDictionary *attachmentDictionary;
@end

// TODO: Use CoreData instead for persistence.
@implementation K9ObjectGraph

- (id)init {
    if(self = [super init]) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        [_sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:fidoUsername password:fidoPassword];
        _eventDictionary = [NSMutableDictionary dictionary];
        _dogDictionary = [NSMutableDictionary dictionary];
        _attachmentDictionary = [NSMutableDictionary dictionary];
        _trainingDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

static K9ObjectGraph *sharedObjectGraph = nil;
+ (K9ObjectGraph *)sharedObjectGraph {
    if(sharedObjectGraph == nil) {
        sharedObjectGraph = [[K9ObjectGraph alloc] init];
    }
    return sharedObjectGraph;
}

- (NSArray *)fetchAllDogsWithCompletionHandler:(void (^)(NSArray *dogs))completionHandler {
    [self.sessionManager GET:@"vests.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *dogs = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        for(NSDictionary *dogDictionary in responseObject) {
            // TODO: Don't create the dog if we already have it.. update it?
            K9Dog *dog = [K9Dog dogWithPropertyList:dogDictionary];
            if(dog) {
                [dogs addObject:dog];
                if(![[self dogDictionary] objectForKey:@([dog dogID])]) {
                    [[self dogDictionary] setObject:dog forKey:@([dog dogID])];
                }
            }
        }
        // TODO: Remove cached dogs that aren't reported?
        if(completionHandler) completionHandler([self allDogs]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self allDogs];
}

- (NSArray *)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler {
    [self.sessionManager GET:@"events.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        for(NSDictionary *eventDictionary in responseObject) {
            if(![[self eventDictionary] objectForKey:[eventDictionary objectForKey:@"id"]]) {
                // TODO: Don't create the event if we already have it.. update it?
                K9Event *event = [K9Event eventWithPropertyList:eventDictionary];
                if(event) {
                    if(![[self eventDictionary] objectForKey:@([event eventID])]) {
                        [[self eventDictionary] setObject:event forKey:@([event eventID])];
                    }
                }
            }
        }
        // TODO: Remove cached events that aren't reported?
        if(completionHandler) completionHandler([self allEvents]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self allEvents];
}

- (NSArray *)fetchAllAttachmentsWithCompletionHandler:(void (^)(NSArray *events))completionHandler {
    [self.sessionManager GET:@"attachments.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *attachments = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        for(NSDictionary *attachmentDictionary in responseObject) {
            K9Attachment *attachment = [K9Attachment attachmentWithPropertyList:attachmentDictionary];
            if(attachment) {
                [attachments addObject:attachment];
                if(![[self attachmentDictionary] objectForKey:@([attachment attachmentID])]) {
                    [[self attachmentDictionary] setObject:attachment forKey:@([attachment attachmentID])];
                }
            }
        }
        // TODO: Remove cached events that aren't reported?
        if(completionHandler) completionHandler(attachments);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self allEvents];
}

- (K9Event *)fetchEventWithID:(NSInteger)eventID completionHandler:(void (^)(K9Event *event))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"events/%ld.json", eventID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]]) {
            responseObject = [responseObject objectAtIndex:0];
        }
        K9Event *event = [K9Event eventWithPropertyList:responseObject];
        if(event && ![[self eventDictionary] objectForKey:@([event eventID])]) {
            [[self eventDictionary] setObject:event forKey:@([event eventID])];
            
            NSDictionary *userInfo = @{K9ModifiedEventKey: event};
            [[NSNotificationCenter defaultCenter] postNotificationName:K9EventWasAddedNotification object:self userInfo:userInfo];
        }
        if(completionHandler) completionHandler(event);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self eventWithID:eventID];
}

- (K9Dog *)fetchDogWithID:(NSInteger)dogID completionHandler:(void (^)(K9Dog *dog))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"vests/%ld.json", dogID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]]) {
            responseObject = [responseObject objectAtIndex:0];
        }
        K9Dog *dog = [K9Dog dogWithPropertyList:responseObject];
        if(dog) {
            [[self dogDictionary] setObject:dog forKey:@([dog dogID])];
        }
        if(completionHandler) completionHandler(dog);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self dogWithID:dogID];
}

- (K9Event *)eventWithID:(NSInteger)eventID {
    return [[self eventDictionary] objectForKey:@(eventID)];
}

- (K9Dog *)dogWithID:(NSInteger)dogID {
    return [[self dogDictionary] objectForKey:@(dogID)];
}

- (NSArray *)allDogs {
    return [[self dogDictionary] allValues];
}

- (NSArray *)allEvents {
    return [[self eventDictionary] allValues];
}

- (NSArray *)allAttachments {
    return [[self attachmentDictionary] allValues];
}


- (NSArray *)eventsForDogWithID:(NSInteger)dogID {
    NSMutableArray *events = [NSMutableArray array];
    for(K9Event *event in [self allEvents]) {
        if([[[event associatedDogs] valueForKey:@"dogID"] containsObject:@(dogID)]) {
            [events addObject:event];
        }
    }
    return events;
}

- (NSArray *)fetchEventsForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSArray *))completionHandler {
    // TODO: Do this better when the web API supports it.
    [self fetchAllEventsWithCompletionHandler:^(NSArray *events) {
        if(completionHandler) {
            completionHandler([self eventsForDogWithID:dogID]);            
        }
    }];
    return [self eventsForDogWithID:dogID];
}

- (NSArray *)attachmentsForDogWithID:(NSInteger)dogID {
    NSMutableArray *events = [NSMutableArray array];
    for(K9Attachment *attachment in [self allAttachments]) {
        if([[[attachment associatedDogs] valueForKey:@"dogID"] containsObject:@(dogID)]) {
            [events addObject:attachment];
        }
    }
    return events;
}

- (NSArray *)fetchAttachmentsForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSArray *))completionHandler {
    // TODO: Do this better when the web API supports it.
    [self fetchAllAttachmentsWithCompletionHandler:^(NSArray *events) {
        if(completionHandler) {
            completionHandler([self eventsForDogWithID:dogID]);
        }
    }];
    return [self eventsForDogWithID:dogID];
}

- (NSArray *)allTraining {
    return [[self trainingDictionary] allValues];
}

- (void)addTraining:(K9Training *)training {
    [[self trainingDictionary] setObject:training forKey:@([training trainingID])];
    [[NSNotificationCenter defaultCenter] postNotificationName:K9TrainingWasAddedNotification object:self userInfo:nil];
}

@end
