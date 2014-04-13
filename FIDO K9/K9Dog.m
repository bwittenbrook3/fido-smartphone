//
//  K9Dog.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Dog.h"
#import "K9Event.h"
#import "K9ObjectGraph.h"

#define NAME_KEY @"K9"
#define ID_KEY @"id"
#define OFFICER_NAME_KEY @"officer"

@implementation K9Dog

+ (K9Dog *)dogWithPropertyList:(NSDictionary *)propertyList {
    NSLog(@"%@", propertyList);
    
    K9Dog *dog = [K9Dog new];

    dog.dogID = [[propertyList objectForKey:ID_KEY] integerValue];
    dog.name = [propertyList objectForKey:NAME_KEY];
    dog.officerName = [propertyList objectForKey:OFFICER_NAME_KEY];
    
    // TODO: Do this at some later point once the web APIs supports these kind of queries
    [[K9ObjectGraph sharedObjectGraph] fetchEventsForDogWithID:dog.dogID completionHandler:nil];
    [[K9ObjectGraph sharedObjectGraph] fetchAttachmentsForDogWithID:dog.dogID completionHandler:nil];
    
    dog.color = [UIColor redColor];
    
    // TODO: Grab URL when web API supports it.
    UIImage *image = [UIImage imageNamed:@"TestDog.jpg"];
    dog.image = [K9Dog centerCircularImage:image];

    
    return dog;
}

- (NSArray *)events {
    return [[K9ObjectGraph sharedObjectGraph] eventsForDogWithID:self.dogID];
}

- (NSArray *)attachments {
    return [[K9ObjectGraph sharedObjectGraph] attachmentsForDogWithID:self.dogID];
}

+ (UIImage *)centerCircularImage:(UIImage *)sourceImage {
    CGSize size = [sourceImage size];
    if(size.width < size.height) {
        size.height = size.width;
    } else {
        size.width = size.height;
    }
    CGRect centerRect = CGRectMake((sourceImage.size.width - size.width)/2, (sourceImage.size.height - size.height)/2, size.width, size.height);
    return [self circularScaleAndCropImage:sourceImage frame:centerRect];
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
