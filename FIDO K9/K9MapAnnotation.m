//
//  K9MapAnnotation.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9MapAnnotation.h"

@interface K9MapAnnotation()

@property (strong) NSMutableArray *mutablePolylines;

@end
@implementation K9MapAnnotation

+ (K9MapAnnotation *)mapAnnotationWithData:(NSString *)serializedData {
    return nil;
}

- (id)init {
    if(self = [super init]) {
        self.mutablePolylines = [NSMutableArray array];
    }
    return self;
}

- (void)addPolyline:(MKPolyline *)polyline {
    [self.mutablePolylines addObject:polyline];
}

- (NSArray *)polylines {
    return [self.mutablePolylines copy];
}
@end
