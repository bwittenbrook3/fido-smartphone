//
//  K9Photo.m
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Photo.h"

#define THUMBNAIL_SIZE CGSizeMake(100, 100)

@implementation K9Photo
@synthesize thumbnail = _thumbnail;

- (void)setImage:(UIImage *)image {
    if(_image != image) {
        _image = image;
    }
}

- (void)setThumbnail:(UIImage *)thumbnail {
    if(_thumbnail != thumbnail) {
        _thumbnail = thumbnail;
    }
}

- (UIImage *)thumbnail {
    if(!_thumbnail) {
//        return _image;
        [self setThumbnail:[K9Photo imageWithImage:_image scaledToFillSize:THUMBNAIL_SIZE]];
    }
    return _thumbnail;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size {
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
