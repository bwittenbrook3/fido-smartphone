//
//  K9ObjectGraph.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9ObjectGraph.h"
#import "AFHTTPSessionManager.h"

static NSString * const baseURLString = @"http://fido-api.herokuapp.com/";
static NSString * const fidoUsername = @"fido";
static NSString * const fidoPassword = @"password";

@interface K9ObjectGraph()
@property (strong) AFHTTPSessionManager *sessionManager;
@end

// TODO: Use CoreData instead?
@implementation K9ObjectGraph

- (id)init {
    if(self = [super init]) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        [_sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:fidoUsername password:fidoPassword];

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

- (BOOL)fetchAllDogsWithCallback:(void (^)(NSArray *dogs))completionHandler {
    [self.sessionManager GET:@"/events" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"json: %@", responseObject);
//        [resources addObjectsFromArray:responseObject[@"resources"]];
//        [manager SUBSCRIBE:@"/resources" usingBlock:^(NSArray *operations, NSError *error) {
//            for (AFJSONPatchOperation *operation in operations) {
//                switch (operation.type) {
//                    case AFJSONAddOperationType:
//                        [resources addObject:operation.value];
//                        break;
//                    default:
//                        break;
//                }
//            }
//        } error:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    return TRUE;
}


@end
