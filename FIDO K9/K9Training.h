//
//  K9Training.h
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, K9TrainingType) {
    K9TrainingTypeStandard
};

@class K9Dog, K9Weather, CLLocation;
@interface K9Training : NSObject

@property K9Dog *trainedDog;
@property K9TrainingType trainingType;
@property (readonly) NSString *formattedTrainingType;

@property NSDate *startTime;
@property NSDate *endTime;

@property CLLocation *location;
@property K9Weather *weather;

@property NSArray *trainingAidList;

+ (K9Training *)sampleTraining;

@end


@interface K9TrainingAid : NSObject

@end