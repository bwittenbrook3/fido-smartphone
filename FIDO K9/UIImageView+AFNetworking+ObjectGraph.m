//
//  UIImageView+AFNetworking_ObjectGraph.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "UIImageView+AFNetworking+ObjectGraph.h"
#import "UIImageView+AFNetworking.h"
#import "K9ObjectGraph.h"

@implementation UIImageView (AFNetworking_ObjectGraph)


- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                success:(void (^)(UIImage *image))success
                failure:(void (^)(NSError *error))failure {
    
    NSLog(@"set");
    if(url) {
        [K9ObjectGraph startDoingNetworkingActivity];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        [self setImageWithURLRequest:urlRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSLog(@"success");

            [K9ObjectGraph stopDoingNetworkingActivity];
            
            if(success) success(image);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"fail");

            [K9ObjectGraph stopDoingNetworkingActivity];

            if(failure) failure(error);
        }];
    } else {
        self.image = placeholderImage;
        if(failure) failure(nil);
    }
    
}

@end
