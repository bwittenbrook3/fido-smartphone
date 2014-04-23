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
#import "K9MapAnnotation.h"

#define IMAGE_NAME_KEY @"image_name"
#define URL_PATH_KEY @"image_uid"
#define DATA_KEY @"data"

static NSString * const baseURLString = @"http://fido-api-bucket.s3.amazonaws.com";

@implementation K9Resource
+ (K9Resource *)resourceWithPropertyList:(id)propertyList {
    if(objectIsEmptyCheck([propertyList objectForKey:IMAGE_NAME_KEY])) {
        // Assume it's an annotation
        
        // TODO: Web API has to vend out the type so we can tell annotations apart from other data types
        
        K9MapAnnotation *annotation = [K9MapAnnotation mapAnnotationWithData:[propertyList objectForKey:DATA_KEY]];
        
        return annotation;
    } else {
        // Assume it's a photo
        
        K9Photo *photo = [K9Photo new];
        photo.URL = [NSURL URLWithString:[propertyList objectForKey:URL_PATH_KEY] relativeToURL:[NSURL URLWithString:baseURLString]];
        photo.uploaded = YES;
        
        return (photo.URL ? photo : nil);
    }
}
@end
