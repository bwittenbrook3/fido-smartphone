//
//  K9PolylineBuilder.h
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKOverlay.h>

@class MKOverlayPathRenderer, MKPolyline;
@interface K9PolylineBuilder : NSObject  <MKOverlay>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coordinate;
- (MKOverlayPathRenderer *)renderer;

@property (readonly) MKPolyline *polyline;

@end
