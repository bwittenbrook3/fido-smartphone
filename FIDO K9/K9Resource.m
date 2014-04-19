//
//  K9Resource.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Resource.h"
#import "K9ModelUtilities.h"
#import "K9Photo.h"

#define IMAGE_NAME_KEY @"image_name"
#define URL_PATH_KEY @"image_uid"

static NSString * const baseURLString = @"http://fido-api-bucket.s3.amazonaws.com";

@implementation K9Resource
+ (K9Resource *)resourceWithPropertyList:(id)propertyList {
    if(objectIsEmptyCheck([propertyList objectForKey:IMAGE_NAME_KEY])) {
        // TODO: Support for other resource types
        return nil;
    } else {
        K9Photo *photo = [K9Photo new];
        photo.URL = [NSURL URLWithString:[propertyList objectForKey:URL_PATH_KEY] relativeToURL:[NSURL URLWithString:baseURLString]];
        photo.uploaded = YES;
        
        return (photo.URL ? photo : nil);
    }
}
@end
