//
//  K9CircularBorderImageView.m
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9CircularBorderImageView.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+CircularCenteredImage.m"

@interface K9CircularBorderImageView ()

@property (strong) UIImageView *imageView;

@end

@implementation K9CircularBorderImageView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
    }
    return self;
}


- (void)setImage:(UIImage *)image {
    [[self imageView] setImage:[image circularCenteredImage]];
}

- (UIImage *)image {
    return [[self imageView] image];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completion:(void(^)(void))completionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [[self imageView] setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self setImage:[image circularCenteredImage]];
        [self setNeedsDisplay];
        if(completionHandler) completionHandler();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage {
    [self setImageWithURL:url placeholderImage:placeholderImage completion:nil];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    
    CGFloat strokeWidth = self.borderWidth;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    
    UIImage *image = [self image];
    CGRect imageRect = [self bounds];
    
    // calculate resize ratio, and apply to rect
    CGFloat ratio = MIN(self.bounds.size.width / image.size.width, self.bounds.size.height / image.size.height);
    imageRect.size.width = image.size.width * ratio;
    imageRect.size.height = image.size.height * ratio;
    imageRect.origin.x = ([self bounds].size.width - imageRect.size.width)/2;
    imageRect.origin.y = ([self bounds].size.height - imageRect.size.height)/2;
    
    // draw the image
    [image drawInRect:imageRect];
    
    CGFloat radius = imageRect.size.width/2;
    CGRect rrect = imageRect;
    rrect.size.width = rrect.size.width - strokeWidth;
    rrect.size.height = rrect.size.height - strokeWidth;
    rrect.origin.x = rrect.origin.x + (strokeWidth / 2);
    rrect.origin.y = rrect.origin.y + (strokeWidth / 2);
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

- (CGSize)intrinsicContentSize {
    return [[self image] size];
}

@end