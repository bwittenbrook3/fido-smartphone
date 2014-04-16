//
//  K9Weather.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Weather.h"
#import "Forecastr+CLLocation.h"



static inline K9WeatherPrecipitation precipitationFromString(NSString *stringValue) {
    K9WeatherPrecipitation precipitation = K9WeatherPrecipitationNone;
    
    if([[stringValue lowercaseString] isEqualToString:@"rain"]) {
        precipitation = K9WeatherPrecipitationRain;
    } else if([[stringValue lowercaseString] isEqualToString:@"sleet"]) {
        precipitation = K9WeatherPrecipitationSleet;
    } else if([[stringValue lowercaseString] isEqualToString:@"snow"]) {
        precipitation = K9WeatherPrecipitationSnow;
    } else if([[stringValue lowercaseString] isEqualToString:@"hail"]) {
        precipitation = K9WeatherPrecipitationHail;
    }
    
    return precipitation;
};


@implementation K9Weather

- (NSString *)formattedDescription {
    
    NSString *overcast = @"Clear";
    
    switch (self.precipitation) {
        case K9WeatherPrecipitationNone:
            if (self.cloudCoverage > 0.9) {
                overcast = @"Overcast";
            } else if (self.cloudCoverage > 0.65) {
                overcast = @"Cloudy";
            } else if (self.cloudCoverage > 0.3) {
                overcast = @"Partly Cloudy";
            }
            break;
        case K9WeatherPrecipitationRain:
            overcast = @"Rain";
            break;
        case K9WeatherPrecipitationSleet:
            overcast = @"Sleet";
            break;
        case K9WeatherPrecipitationSnow:
            overcast = @"Snow";
            break;
        case K9WeatherPrecipitationHail:
            overcast = @"Hail";
            break;
    }

    return [NSString stringWithFormat:@"%.1f° & %@", self.temperatureInFahrenheit, overcast];
}

+ (void)fetchWeatherForLocation:(CLLocation *)location completionHandler:(void (^)(K9Weather *weather))completionHandler {
    NSArray *exclusions = @[kFCAlerts, kFCFlags, kFCMinutelyForecast, kFCHourlyForecast, kFCDailyForecast];
    [[Forecastr sharedManager] getForecastForLocation:location time:nil exclusions:exclusions extend:nil success:^(id JSON) {
        K9Weather *weather = [K9Weather new];
        
        id currentWeather = [JSON objectForKey:kFCCurrentlyForecast];
        
        weather.temperatureInFahrenheit = [[currentWeather objectForKey:kFCTemperature] floatValue];
        weather.humidity = [[currentWeather objectForKey:kFCHumidity] floatValue];
        weather.cloudCoverage = [[currentWeather objectForKey:kFCCloudCover] floatValue];
        weather.precipitationIntensity = [[currentWeather objectForKey:kFCPrecipIntensity] floatValue];
        weather.precipitation = precipitationFromString([currentWeather objectForKey:kFCPrecipType]);
        weather.windSpeedInMilesPerHour = [[currentWeather objectForKey:kFCWindSpeed] floatValue];
        weather.windBearingInDegrees = [[currentWeather objectForKey:kFCWindBearing] floatValue];
        
        completionHandler(weather);
    } failure:^(NSError *error, id response) {
        completionHandler(nil);
    }];
}
@end
