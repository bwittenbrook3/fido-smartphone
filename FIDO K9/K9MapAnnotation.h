//
//  K9MapAnnotation.h
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Resource.h"


#define DEFAULT_MAP_ANNOTATION_WIDTH (3.0)

@class MKPolyline;
@interface K9MapAnnotation : K9Resource

+ (K9MapAnnotation *)mapAnnotationWithData:(NSString *)serializedData;

@property (readonly) NSArray *polylines;
- (void)addPolyline:(MKPolyline *)polyline withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

@property (readonly) NSString *serializedAnnotation;

@end
