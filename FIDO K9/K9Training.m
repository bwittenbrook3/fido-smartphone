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

@implementation K9Training


- (NSString *)formattedTrainingType {
    return @"XYZ";
}


+ (K9Training *)sampleTraining {
    K9Training *training = [K9Training new];
    
    training.trainedDog = [[[K9ObjectGraph sharedObjectGraph] allDogs] firstObject];
    training.startTime = [NSDate date];
    training.endTime = [NSDate date];
    
    training.location =  training.trainedDog.lastKnownLocation;
    [K9Weather fetchWeatherForLocation:training.location completionHandler:^(K9Weather *weather) {
        training.weather = weather;
    }];
    
    //@property NSArray *trainingAidList;

    return training;
}


@end
