//
//  UIView+Screenshot.m
//  PhotoBrowserMini
//
//  Created by Taylor Kelly on 7/12/13.
//  Copyright (c) 2013 Taylor Kelly. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

//- (UIImage *)screenshot {
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
//    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

- (UIImage *)screenshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
