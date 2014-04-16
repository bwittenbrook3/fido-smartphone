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


@property NSInteger trainingID;

@property (weak) K9Dog *trainedDog;
@property K9TrainingType trainingType;
@property (copy, readonly) NSString *formattedTrainingType;

@property (copy) NSDate *startTime;
@property (copy) NSDate *endTime;

@property (strong) CLLocation *location;
@property (strong) K9Weather *weather;

@property (strong) NSArray *trainingAidList;

+ (K9Training *)sampleTraining;

@end


@interface K9TrainingAid : NSObject

@end