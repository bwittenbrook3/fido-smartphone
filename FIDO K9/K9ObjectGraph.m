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
#import "K9Event.h"

static NSString * const baseURLString = @"http://fido-api.herokuapp.com/api/";
static NSString * const fidoUsername = @"FiDo";
static NSString * const fidoPassword = @"b40eb04e7874876cc72f0475b6b6efc3";

@interface K9ObjectGraph()
@property (strong) AFHTTPSessionManager *sessionManager;
@property (strong) NSMutableDictionary *eventDictionary;
@property (strong) NSMutableDictionary *dogDictionary;
@end

// TODO: Use CoreData instead?
@implementation K9ObjectGraph

- (id)init {
    if(self = [super init]) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        [_sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:fidoUsername password:fidoPassword];
        _eventDictionary = [NSMutableDictionary dictionary];
        _dogDictionary = [NSMutableDictionary dictionary];
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
            K9Dog *dog = [K9Dog dogWithPropertyList:dogDictionary];
            if(dog) {
                [dogs addObject:dog];
                if(![[self dogDictionary] objectForKey:@([dog dogID])]) {
                    [[self dogDictionary] setObject:dog forKey:@([dog dogID])];
                }
            }
        }
        // TODO: Remove cached dogs that aren't reported?
        completionHandler(dogs);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        completionHandler(nil);
    }];
    
    return [self allDogs];
}

- (NSArray *)fetchAllEventsWithCompletionHandler:(void (^)(NSArray *events))completionHandler {
    [self.sessionManager GET:@"events.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:[responseObject count]];
        for(NSDictionary *eventDictionary in responseObject) {
            K9Event *event = [K9Event eventWithPropertyList:eventDictionary];
            if(event) {
                [events addObject:event];
                if(![[self eventDictionary] objectForKey:@([event eventID])]) {
                    [[self eventDictionary] setObject:event forKey:@([event eventID])];
                }
            }
        }
        // TODO: Remove cached events that aren't reported?
        completionHandler(events);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        completionHandler(nil);
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
        if(event) {
            [[self eventDictionary] setObject:event forKey:@([event eventID])];
        }
        completionHandler(event);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        completionHandler(nil);
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
        completionHandler(dog);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        completionHandler(nil);
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
    [self fetchAllEventsWithCompletionHandler:^(NSArray *events) {
        if(completionHandler) {
            completionHandler([self eventsForDogWithID:dogID]);            
        }
    }];
    return [self eventsForDogWithID:dogID];
}

@end
