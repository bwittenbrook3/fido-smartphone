//
//  K9ObjectGraph.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9ObjectGraph : NSObject

+ (K9ObjectGraph *)sharedObjectGraph;


- (BOOL)fetchAllDogsWithCallback:(void (^)(NSArray *dogs))completionHandler;



@property (copy, nonatomic) NSArray *allEvents;
@property (copy, nonatomic) NSArray *allDogs;



@end
