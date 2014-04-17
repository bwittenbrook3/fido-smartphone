//
//  K9Dog.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLLocation;
@interface K9Dog : NSObject

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList;

@property (nonatomic) NSInteger dogID;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *status;

@property (nonatomic) NSUInteger ageInMonths;
@property (readonly, nonatomic) NSString *formattedAge;

@property (copy, nonatomic) NSString *officerName;
@property (copy, nonatomic) NSArray *certifications;

@property (readonly, nonatomic) NSArray *events;
@property (readonly, nonatomic) NSArray *attachments;

@property (copy, nonatomic) CLLocation *lastKnownLocation;



@end
