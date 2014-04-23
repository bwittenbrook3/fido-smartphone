//
//  K9CircularBorderImageView.h
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface K9CircularBorderImageView : UIView

@property (copy) UIImage *image;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completion:(void(^)(void))completionHandler;


@property (copy) UIColor *borderColor;
@property CGFloat borderWidth;

@end