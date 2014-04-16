//
//  K9Weather.h
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;


typedef NS_ENUM(NSUInteger, K9WeatherPrecipitation) {
    K9WeatherPrecipitationNone,
    K9WeatherPrecipitationRain,
    K9WeatherPrecipitationSnow,
    K9WeatherPrecipitationSleet,
    K9WeatherPrecipitationHail,
};

@interface K9Weather : NSObject

@property CGFloat temperatureInCelsius;
@property CGFloat temperatureInFahrenheit;

@property CGFloat humidity;

@property CGFloat cloudCoverage;

@property K9WeatherPrecipitation precipitation;
@property CGFloat precipitationIntensity;

@property CGFloat windSpeedInMilesPerHour;
@property CGFloat windBearingInDegrees;

@property (readonly) NSString *formattedDescription;

+ (void)fetchWeatherForLocation:(CLLocation *)location completionHandler:(void (^)(K9Weather *weather))completionHandler;

@end
