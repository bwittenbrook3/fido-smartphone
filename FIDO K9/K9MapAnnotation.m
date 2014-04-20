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
#import "UIColor+Hex.h"

@interface K9MapAnnotation()

@property (strong) NSMutableArray *mutablePolylines;
@property (strong) NSMutableArray *mutableColors;
@property (strong) NSMutableArray *mutableLineWidths;

@end
@implementation K9MapAnnotation

+ (K9MapAnnotation *)mapAnnotationWithData:(NSString *)serializedData {
    NSData *jsonData = [serializedData dataUsingEncoding:NSUTF8StringEncoding];
    
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    NSMutableArray *polylines = nil;
    NSMutableArray *colors = nil;
    NSMutableArray *lineWidths = nil;
    
    if([object isKindOfClass:[NSArray class]]) {
        polylines = [NSMutableArray arrayWithCapacity:[object count]];
        colors = [NSMutableArray arrayWithCapacity:[object count]];
        lineWidths = [NSMutableArray arrayWithCapacity:[object count]];

        for(id polylineData in object) {
            if([polylineData isKindOfClass:[NSDictionary class]]) {
                id inColor = [polylineData objectForKey:@"color"];
                id inLineWidth = [polylineData objectForKey:@"lineWidth"];
                id inPoints = [polylineData objectForKey:@"points"];
                
                UIColor *polylineColor = nil;
                NSNumber *lineWidth = nil;
                MKPolyline *polyline = nil;
                
                if([inColor isKindOfClass:[NSNumber class]]) {
                    polylineColor = [UIColor colorWithColorCode:[inColor integerValue]];
                }
                if([inLineWidth isKindOfClass:[NSNumber class]]) {
                    lineWidth = inLineWidth;
                }
                
                NSMutableArray *santizedPoints = nil;
                if([inPoints isKindOfClass:[NSArray class]]) {
                    santizedPoints = [NSMutableArray arrayWithCapacity:[inPoints count]];
                    for(id point in inPoints) {
                        if([point isKindOfClass:[NSArray class]] && [point count] == 2) {
                            if([[point objectAtIndex:0] isKindOfClass:[NSNumber class]] && [[point objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
                                [santizedPoints addObject:point];
                            }
                        }
                    }
                }
                if([santizedPoints count]) {
                    NSUInteger pointCount = [santizedPoints count];
                    CLLocationCoordinate2D coordinates[pointCount];
                    
                    for(NSUInteger idx = 0; idx < pointCount; idx++) {
                        NSArray *point = [santizedPoints objectAtIndex:idx];
                        coordinates[idx] = CLLocationCoordinate2DMake([[point firstObject] floatValue], [[point lastObject] floatValue]);
                    }
                    
                    polyline  = [MKPolyline polylineWithCoordinates:coordinates count:pointCount];
                }
                
                if(polylineColor && lineWidth && polyline) {
                    [polylines addObject:polyline];
                    [colors addObject:polylineColor];
                    [lineWidths addObject:lineWidth];
                }
            }
        }
    }

    K9MapAnnotation *mapAnnotation = nil;
    if([polylines count]) {
        mapAnnotation = [[K9MapAnnotation alloc] initWithMutablePolylines:polylines colors:colors lineWidths:lineWidths];
        mapAnnotation.uploaded = YES;
    }

    return mapAnnotation;
}

- (id)init {
    return [self initWithMutablePolylines:[NSMutableArray array] colors:[NSMutableArray array] lineWidths:[NSMutableArray array]];
}

- (id)initWithMutablePolylines:(NSMutableArray *)mutablePolylines colors:(NSMutableArray *)colors lineWidths:(NSMutableArray *)lineWidths {
    if(self = [super init]) {
        self.mutablePolylines = mutablePolylines;
        self.mutableColors = colors;
        self.mutableLineWidths = lineWidths;
    }
    return self;
}

- (void)addPolyline:(MKPolyline *)polyline withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    [self.mutablePolylines addObject:polyline];
    [self.mutableColors addObject:color];
    [self.mutableLineWidths addObject:@(lineWidth)];
}

- (NSArray *)polylines {
    return [self.mutablePolylines copy];
}

- (NSString *)serializedAnnotation {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:self.mutablePolylines.count];
    
    [self.mutablePolylines enumerateObjectsUsingBlock:^(MKPolyline *polyline, NSUInteger idx, BOOL *stop) {
        NSMutableArray *polylineArray = [NSMutableArray arrayWithCapacity:polyline.pointCount];
        
        for(int i = 0 ; i < polyline.pointCount; i++) {
            CLLocationCoordinate2D coordinate;
            [polyline getCoordinates:&coordinate range:NSMakeRange(i, 1)];
            [polylineArray addObject:@[@(coordinate.latitude), @(coordinate.longitude)]];
        }
        
        [jsonArray addObject:@{@"color": @([[self.mutableColors objectAtIndex:idx] colorCode]),
                               @"lineWidth": [self.mutableLineWidths objectAtIndex:idx],
                               @"points": polylineArray}];
    }];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:nil];
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
