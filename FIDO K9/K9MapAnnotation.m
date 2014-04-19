//
//  K9MapAnnotation.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9MapAnnotation.h"
#import <Foundation/NSJSONSerialization.h>
#import <MapKit/MKPolyline.h>

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

- (NSString *)serializedAnnotation {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:self.mutablePolylines.count];
    
    for(MKPolyline *polyline in self.mutablePolylines) {
        NSMutableArray *polylineArray = [NSMutableArray arrayWithCapacity:polyline.pointCount];
        
        for(int i = 0 ; i < polyline.pointCount; i++) {
            CLLocationCoordinate2D coordinate;
            [polyline getCoordinates:&coordinate range:NSMakeRange(i, 1)];
            [polylineArray addObject:@[@(coordinate.latitude), @(coordinate.longitude)]];
        }
        
        [jsonArray addObject:polylineArray];
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
