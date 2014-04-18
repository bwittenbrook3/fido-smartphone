//
//  UIColor+DefaultTintColor.m
//  FIDO K9
//
//  Created by Taylor on 4/17/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "UIColor+DefaultTintColor.h"

@implementation UIColor (DefaultTintColor)

+ (UIColor *)defaultSystemTintColor {
    static UIColor* systemTintColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView* view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    });
    return systemTintColor;
}

@end
