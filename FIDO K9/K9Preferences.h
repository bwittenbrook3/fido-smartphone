//
//  K9Preferences.h
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, K9PreferencesLocation) {
    K9PreferencesLocationNoStatus,
    K9PreferencesLocationLocalDenied,
    K9PreferencesLocationAbsoluteAccepted,
    K9PreferencesLocationAbsoluteDenied,
};

@interface K9Preferences : NSObject

+ (K9Preferences *)sharedPreferences;

+ (K9PreferencesLocation)locationPreference;
+ (void)setLocationPreference:(K9PreferencesLocation)locationPreference;

@end
