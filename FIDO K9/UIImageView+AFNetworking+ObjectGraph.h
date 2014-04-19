//
//  UIImageView+AFNetworking_ObjectGraph.h
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImageView (AFNetworking_ObjectGraph)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure;

@end
