//
//  UIView+Screenshot.m
//  PhotoBrowserMini
//
//  Created by Taylor Kelly on 7/12/13.
//  Copyright (c) 2013 Taylor Kelly. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
