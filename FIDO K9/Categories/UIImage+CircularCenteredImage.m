//
//  UIImage+CircularCenteredImage.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "UIImage+CircularCenteredImage.h"

@implementation UIImage (CircularCenteredImage)


- (UIImage *)circularCenteredImage {
    CGSize size = [self size];
    if(size.width < size.height) {
        size.height = size.width;
    } else {
        size.width = size.height;
    }
    CGRect centerRect = CGRectMake((self.size.width - size.width)/2, (self.size.height - size.height)/2, size.width, size.height);
    return [UIImage circularScaleAndCropImage:self frame:centerRect];
}

+ (UIImage *)circularScaleAndCropImage:(UIImage *)image frame:(CGRect)frame {
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(-frame.origin.x, -frame.origin.y, image.size.width, image.size.height);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
