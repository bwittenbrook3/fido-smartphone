//
//  K9Photo.h
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9Photo : NSObject

@property (copy) NSURL *thumbnailURL;
@property (copy) NSURL *imageURL;

@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) UIImage *image;

@end
