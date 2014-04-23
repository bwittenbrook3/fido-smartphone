//
//  K9Training.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Training.h"
#import "K9ObjectGraph.h"
#import "K9Dog.h"
#import "K9Weather.h"

@interface NSArray (RandomObject)

- (id)randomObject;

@end


@implementation K9Training

static NSInteger globalTrainingID = 0;


- (id)init {
    if(self = [super init]) {
        _trainingID = globalTrainingID++;
    }
    return self;
}

- (NSString *)formattedTrainingType {
    return @"Explosive Detection";
}


+ (K9Training *)sampleTraining {
    K9Training *training = [K9Training new];
    
    training.trainedDog = [[[K9ObjectGraph sharedObjectGraph] allDogs] randomObject];
    
    NSTimeInterval startTimeInterval = -((float)rand() / RAND_MAX) * 60 * 60 * 24 * 7 * 2;
    training.startTime = [NSDate dateWithTimeIntervalSinceNow:startTimeInterval];
    
    NSTimeInterval trainingDuration = (((float)rand() / RAND_MAX)/2 + 0.5) * 60 * 60 * 2;
    training.endTime = [training.startTime dateByAddingTimeInterval:trainingDuration];
    
    training.location =  training.trainedDog.lastKnownLocation;
    training.weather = [K9Weather new];
    [K9Weather fetchWeatherForLocation:training.location atTime:training.startTime completionHandler:^(K9Weather *weather) {
        training.weather = weather;
    }];

    
    NSMutableArray *trainingAidList = [NSMutableArray array];
    for(int i = 0; i < (arc4random_uniform(8)+2); i++) {
        [trainingAidList addObject:[K9TrainingAid new]];
    }
    training.trainingAidList = trainingAidList;

    
    return training;
}

@end

@implementation K9TrainingAid

- (NSString *)status {
    return @"Pass";
}

@end

@implementation NSArray (RandomObject)

- (id)randomObject {
    if(![self count]) return nil;
    
    return [self objectAtIndex:arc4random() % [self count]];
}

@end
