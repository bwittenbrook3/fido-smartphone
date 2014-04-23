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

static inline CGFloat windBearingDegreesForWindBearing(K9WeatherWindBearing windBearing) {
    if(windBearing == K9WeatherWindBearingNorth) {
        return 0;
    } else if (windBearing == (K9WeatherWindBearingNorth |K9WeatherWindBearingEast)) {
        return 45;
    } else if (windBearing == K9WeatherWindBearingEast) {
        return 90;
    } else if (windBearing == (K9WeatherWindBearingSouth | K9WeatherWindBearingEast)) {
        return 135;
    } else if (windBearing == K9WeatherWindBearingSouth) {
        return 180;
    } else if (windBearing == (K9WeatherWindBearingSouth | K9WeatherWindBearingWest)) {
        return 225;
    } else if (windBearing == K9WeatherWindBearingWest) {
        return 270;
    } else if (windBearing == (K9WeatherWindBearingNorth | K9WeatherWindBearingWest)) {
        return 315;
    } else {
        return -1;
    }
};

static inline K9WeatherWindBearing windBearingForWindBearingDegrees(CGFloat windBearingDegrees) {
    if (windBearingDegrees < 0 + 22.5 || windBearingDegrees > 315 + 22.5) {
        return K9WeatherWindBearingNorth;
    } else if (windBearingDegrees < 45 + 22.5) {
        return (K9WeatherWindBearingNorth | K9WeatherWindBearingEast);
    } else if (windBearingDegrees < 90 + 22.5) {
        return K9WeatherWindBearingEast;
    } else if (windBearingDegrees < 135 + 22.5) {
        return (K9WeatherWindBearingSouth | K9WeatherWindBearingEast);
    } else if (windBearingDegrees < 180 + 22.5) {
        return K9WeatherWindBearingSouth;
    } else if (windBearingDegrees < 225 + 22.5) {
        return (K9WeatherWindBearingSouth | K9WeatherWindBearingWest);
    } else if (windBearingDegrees < 270 + 22.5) {
        return K9WeatherWindBearingWest;
    } else {
        return (K9WeatherWindBearingNorth | K9WeatherWindBearingWest);
    }
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

- (void)setWindBearing:(K9WeatherWindBearing)windBearing {
    [self setWindBearingInDegrees:windBearingDegreesForWindBearing(windBearing)];
}

- (K9WeatherWindBearing)windBearing {
    return windBearingForWindBearingDegrees(_windBearingInDegrees);
}

- (void)setWindBearingInDegrees:(CGFloat)windBearingInDegrees {
    if(_windBearingInDegrees != windBearingInDegrees) {
        _windBearingInDegrees = windBearingInDegrees;
    }
}

+ (void)fetchWeatherForLocation:(CLLocation *)location atTime:(NSDate *)dateTime completionHandler:(void (^)(K9Weather *weather))completionHandler {
    NSNumber *time = nil;
    if(dateTime) {
        time = @((time_t)[dateTime timeIntervalSince1970]);
    }
    
    NSArray *exclusions = @[kFCAlerts, kFCFlags, kFCMinutelyForecast, kFCHourlyForecast, kFCDailyForecast];
    [[Forecastr sharedManager] getForecastForLocation:location time:time exclusions:exclusions extend:nil success:^(id JSON) {
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

+ (void)fetchWeatherForLocation:(CLLocation *)location completionHandler:(void (^)(K9Weather *weather))completionHandler {
    [self fetchWeatherForLocation:location atTime:nil completionHandler:completionHandler];
}
@end
