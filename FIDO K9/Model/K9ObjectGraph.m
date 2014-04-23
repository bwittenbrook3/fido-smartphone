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
#import "K9Resource.h"
#import "K9Photo.h"
#import "K9MapAnnotation.h"
#import "AFHTTPRequestOperationManager.h"
#import <CoreLocation/CLLocation.h>

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
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        _sessionManager.responseSerializer.acceptableContentTypes = [_sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];

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
        __block NSInteger numberOfCompletedDogs = 0;
        __block NSInteger numberOfDogsToComplete = [responseObject count];
        for(NSDictionary *dogDictionary in responseObject) {
            NSMutableDictionary *mutableDogDictionary = [dogDictionary mutableCopy];
            
            K9Dog *dog = [K9Dog dogWithPropertyList:mutableDogDictionary];
            if(dog && ![[self dogDictionary] objectForKey:@([dog dogID])]) {
                [[self dogDictionary] setObject:dog forKey:@([dog dogID])];
            }
            // Make the URL fetching process seamless, make it seem like the url was always there.
            [self fetchImageURLForDogWithID:[[mutableDogDictionary objectForKey:@"id"] integerValue] completionHandler:^(NSURL *url) {
                if(url) [mutableDogDictionary setObject:url forKey:@"url"];
                dog.imageURL = url;

                // Because we're asynchronously completing each dog, we need to find out when we've finished updating every dog, and send the final completionHandler then. Note that the URL fetching completion handlers could be in a different order than the order of dogs, so just keep count
                numberOfCompletedDogs += 1;
                if(numberOfCompletedDogs == numberOfDogsToComplete) {
                    if(completionHandler) completionHandler([self allDogs]);
                    
                    // TODO: Remove once the web API supports training
                    for(int i = 0; i < 4; i++) {
                        K9Training *training = [K9Training sampleTraining];
                        [self addTraining:training];
                    }
                }
            }];
        }
        // TODO: Remove cached dogs that aren't reported?
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
    
    return [self allDogs];
}

- (void)fetchEventPusherChannelWithCompletionHandler:(void (^)(NSString *pusherChannel))completionHandler {
    [self.sessionManager GET:@"events/new_channel.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *channel = [responseObject objectForKey:@"channel"];
        if(completionHandler) completionHandler(channel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
}

- (void)fetchEventResourcePusherChannelForEventWithID:(NSInteger)eventID withCompletionHandler:(void (^)(NSString *pusherChannel))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"events/%ld/new_resource_channel.json", eventID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *channel = [responseObject objectForKey:@"channel"];
        if(completionHandler) completionHandler(channel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
}

- (void)fetchDogLocationChangeChannelForDogWithID:(NSInteger)dogID withCompletionHandler:(void (^)(NSString *pusherChannel))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"vests/%ld/location_updated_channel.json", dogID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *channel = [responseObject objectForKey:@"channel"];
        if(completionHandler) completionHandler(channel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
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
        BOOL alreadyThere = [[self eventDictionary] objectForKey:@([event eventID])];
        if(event) [[self eventDictionary] setObject:event forKey:@([event eventID])];
        if(event && !alreadyThere) {
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

- (void)fetchResourcesForEventWithID:(NSInteger)eventID completionHandler:(void (^)(NSArray *))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"events/%ld/resources.json", eventID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *resources = [NSMutableArray arrayWithCapacity:[responseObject count]];
        for(NSDictionary *resourceDictionary in responseObject) {
            K9Resource *resource = [K9Resource resourceWithPropertyList:resourceDictionary];
            if(resource) {
                [resources addObject:resource];
            }
        }
        if(completionHandler) completionHandler(resources);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
}

- (void)uploadResource:(K9Resource *)resource forEvent:(K9Event *)event progressHandler:(void (^)(CGFloat))progressHandler completionHandler:(void (^)(NSInteger resourceID))completionHandler {
    NSString *postURLPath = [NSString stringWithFormat:@"events/%ld/resources.json", event.eventID];
    NSString *absoluteURL = [baseURLString stringByAppendingPathComponent:postURLPath];
    
    if([resource isKindOfClass:[K9Photo class]]) {
        K9Photo *photo = (K9Photo *)resource;
        NSDictionary *parameters = @{@"id": @(event.eventID), @"resource" : @{@"type": @"image",
                                                                              @"data": @"."}};
        
        // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
        // bug in NSURLSessionTask.
        NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];

        NSMutableURLRequest *multipartRequest = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                            URLString:absoluteURL
                                                                                                           parameters:parameters
                                                                                            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:photo.URL name:@"resource[image]" fileName:[[photo.URL lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]  mimeType:@"image/jpg" error:nil];
        } error:nil];
        
        [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:multipartRequest
                                                  writingStreamContentsToFile:tmpFileUrl
                                                            completionHandler:^(NSError *error) {
                                                                // Once the multipart form is serialized into a temporary file, we can initialize
                                                                // the actual HTTP request using session manager.
                                                                
                                                                // Create default session manager.
                                                                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                                
                                                                // Show progress.
                                                                NSProgress *progress = nil;
                                                                // Here note that we are submitting the initial multipart request. We are, however,
                                                                // forcing the body stream to be read from the temporary file.
                                                                NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:multipartRequest
                                                                                                                           fromFile:tmpFileUrl
                                                                                                                           progress:&progress
                                                                                                                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                                                                      {
                                                                                                          // Cleanup: remove temporary file.
                                                                                                          [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                                                                          if(progressHandler) {
                                                                                                              [progress removeObserver:self forKeyPath:@"fractionCompleted"];
                                                                                                          }
                                                                                                          NSInteger resourceID = -1;
                                                                                                          if(!error) {
                                                                                                              resourceID = [[responseObject valueForKey:@"id"] integerValue];
                                                                                                          }
                                                                                                          completionHandler(resourceID);
                                                                                                      }];
                                                                if(progressHandler) {
                                                                    // Add the observer monitoring the upload progress.
                                                                    [progress addObserver:self
                                                                               forKeyPath:@"fractionCompleted"
                                                                                  options:NSKeyValueObservingOptionNew
                                                                                  context:(__bridge void *)(progressHandler)];
                                                                }
                                                                // Start the file upload.
                                                                [uploadTask resume];
                                                            }];
    } else if ([resource isKindOfClass:[K9MapAnnotation class]]) {
        K9MapAnnotation *mapAnnotation = (K9MapAnnotation *)resource;
        NSDictionary *parameters = @{@"id": @(event.eventID), @"resource" : @{@"type": @"annotation",
                                                                              @"data": [mapAnnotation serializedAnnotation]}};
        NSMutableURLRequest *multipartRequest = [self.sessionManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                                            URLString:absoluteURL
                                                                                                           parameters:parameters
                                                                                            constructingBodyWithBlock:nil error:nil];
        
        NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
        NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];

        [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:multipartRequest
                                                  writingStreamContentsToFile:tmpFileUrl
                                                            completionHandler:^(NSError *error) {
                                                                // Once the multipart form is serialized into a temporary file, we can initialize
                                                                // the actual HTTP request using session manager.
                                                                
                                                                // Create default session manager.
                                                                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                                                                
                                                                // Show progress.
                                                                NSProgress *progress = nil;
                                                                // Here note that we are submitting the initial multipart request. We are, however,
                                                                // forcing the body stream to be read from the temporary file.
                                                                NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:multipartRequest
                                                                                                                           fromFile:tmpFileUrl
                                                                                                                           progress:&progress
                                                                                                                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                                                                      {
                                                                                                          // Cleanup: remove temporary file.
                                                                                                          [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                                                                          if(progressHandler) {
                                                                                                              [progress removeObserver:self forKeyPath:@"fractionCompleted"];
                                                                                                          }
                                                                                                          
                                                                                                          NSInteger resourceID = -1;
                                                                                                          if(!error) {
                                                                                                              resourceID = [[responseObject valueForKey:@"id"] integerValue];
                                                                                                          }
                                                                                                          completionHandler(resourceID);
                                                                                                      }];
                                                                if(progressHandler) {
                                                                    // Add the observer monitoring the upload progress.
                                                                    [progress addObserver:self
                                                                               forKeyPath:@"fractionCompleted"
                                                                                  options:NSKeyValueObservingOptionNew
                                                                                  context:(__bridge void *)(progressHandler)];
                                                                }
                                                                // Start the file upload.
                                                                [uploadTask resume];
                                                            }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat progress = (CGFloat)[object fractionCompleted];
    void (^progressHandler)(CGFloat) = (__bridge void (^)(CGFloat))(context);
    progressHandler(progress);
}

- (void)fetchImageURLForDogWithID:(NSInteger)dogID completionHandler:(void (^)(NSURL *))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"vests/%ld/image_path.json", dogID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSURL *url = [NSURL URLWithString:[[responseObject objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if(completionHandler) completionHandler(url);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(nil);
    }];
}

- (void)fetchLocationForDogWithID:(NSInteger)dogID withCompletionHandler:(void (^)(CLLocationCoordinate2D coordinate))completionHandler {
    NSString *getURLPath = [NSString stringWithFormat:@"vests/%ld/recent_location.json", dogID];
    [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *locationDictionary = [responseObject objectForKey:@"location"];
        CGFloat latitude = [[locationDictionary objectForKey:@"latitude"] floatValue];
        CGFloat longitude = [[locationDictionary objectForKey:@"longitude"] floatValue];
        if(completionHandler) completionHandler(CLLocationCoordinate2DMake(latitude, longitude));
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if(completionHandler) completionHandler(CLLocationCoordinate2DMake(-1, -1));
    }];
}

- (K9Dog *)fetchDogWithID:(NSInteger)dogID completionHandler:(void (^)(K9Dog *dog))completionHandler {
    if(![self dogWithID:dogID]) {
        NSString *getURLPath = [NSString stringWithFormat:@"vests/%ld.json", dogID];
        [self.sessionManager GET:getURLPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if([responseObject isKindOfClass:[NSArray class]]) {
                responseObject = [responseObject objectAtIndex:0];
            }
            NSMutableDictionary *mutableDogDictionary = [responseObject mutableCopy];
            // Make the URL fetching process seamless, make it seem like the url was always there.
            [self fetchImageURLForDogWithID:[[mutableDogDictionary objectForKey:@"id"] integerValue] completionHandler:^(NSURL *url) {
                if(url) [mutableDogDictionary setObject:url forKey:@"url"];
                
                K9Dog *dog = [K9Dog dogWithPropertyList:mutableDogDictionary];
                if(dog) {
                    [[self dogDictionary] setObject:dog forKey:@([dog dogID])];
                }
                if(completionHandler) completionHandler(dog);
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error: %@", error);
            if(completionHandler) completionHandler(nil);
        }];
    }
    
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
        if([[[event assignedDogs] valueForKey:@"dogID"] containsObject:@(dogID)]) {
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

- (NSArray *)trainingForDogWithID:(NSInteger)dogID {
    NSMutableArray *trainingList = [NSMutableArray array];
    for(K9Training *training in [self allTraining]) {
        if([[training trainedDog] dogID] == dogID) {
            [trainingList addObject:training];
        }
    }
    return trainingList;
}

@end
