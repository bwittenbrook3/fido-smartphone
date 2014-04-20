//
//  UIColor+Hex.m
//  FIDO K9
//
//  Created by Taylor on 4/20/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithColorCode:(NSInteger)colorCode {
    return [UIColor colorWithRed:((float)((colorCode & 0xFF0000) >> 16))/255.0 green:((float)((colorCode & 0xFF00) >> 8))/255.0 blue:((float)(colorCode & 0xFF))/255.0 alpha:1.0];
}

- (NSUInteger)colorCode {
    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:NULL]) {
        NSUInteger redInt = (NSUInteger)(red * 255 + 0.5);
        NSUInteger greenInt = (NSUInteger)(green * 255 + 0.5);
        NSUInteger blueInt = (NSUInteger)(blue * 255 + 0.5);
        
        return (redInt << 16) | (greenInt << 8) | blueInt;
    }
    
    return 0;
}

@end
