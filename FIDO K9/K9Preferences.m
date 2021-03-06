//
//  K9Preferences.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Preferences.h"

#define LOCATION_PREFERENCES_KEY @"K9PreferencesLocation"
#define OPEN_IMAGE_DRAWER_PREFERENCES_KEY @"K9PreferencesEventImageDrawerIsOpen"

@implementation K9Preferences

static K9Preferences *_sharedPreferences;
+ (K9Preferences *)sharedPreferences {
    if(!_sharedPreferences) {
        _sharedPreferences = [K9Preferences new];
    }
    return _sharedPreferences;
}

+ (K9PreferencesLocation)locationPreference {
    return [[NSUserDefaults standardUserDefaults] integerForKey:LOCATION_PREFERENCES_KEY];
}

+ (void)setLocationPreference:(K9PreferencesLocation)locationPreference {
    [[NSUserDefaults standardUserDefaults] setInteger:locationPreference forKey:LOCATION_PREFERENCES_KEY];
}

+ (BOOL)eventImageDrawerIsOpen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:OPEN_IMAGE_DRAWER_PREFERENCES_KEY];
}

+ (void)setEventImageDrawerIsOpen:(BOOL)isOpen {
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:OPEN_IMAGE_DRAWER_PREFERENCES_KEY];
}


@end
