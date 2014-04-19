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

typedef NS_OPTIONS(NSUInteger, K9WeatherWindBearing) {
    K9WeatherWindBearingNorth = 1 << 0,
    K9WeatherWindBearingSouth = 1 << 1,
    K9WeatherWindBearingWest = 1 << 2,
    K9WeatherWindBearingEast = 1 << 3,
};

@interface K9Weather : NSObject

//@property (nonatomic) CGFloat temperatureInCelsius;
@property (nonatomic) CGFloat temperatureInFahrenheit;

@property (nonatomic) CGFloat humidity;

@property (nonatomic) CGFloat cloudCoverage;

@property (nonatomic) K9WeatherPrecipitation precipitation;
@property (nonatomic) CGFloat precipitationIntensity;

@property (nonatomic) CGFloat windSpeedInMilesPerHour;
@property (nonatomic) CGFloat windBearingInDegrees;
@property (nonatomic) K9WeatherWindBearing windBearing;

@property (readonly) NSString *formattedDescription;

+ (void)fetchWeatherForLocation:(CLLocation *)location completionHandler:(void (^)(K9Weather *weather))completionHandler;

@end
