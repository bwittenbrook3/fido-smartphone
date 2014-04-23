//
//  UIColor+Hex.h
//  FIDO K9
//
//  Created by Taylor on 4/20/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
// http://stackoverflow.com/questions/11914137/uicolor-to-unsigned-integer
// http://stackoverflow.com/questions/19405228/how-to-i-properly-set-uicolor-from-int
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)


+ (UIColor *)colorWithColorCode:(NSInteger)colorCode;
- (NSUInteger)colorCode;

@end
