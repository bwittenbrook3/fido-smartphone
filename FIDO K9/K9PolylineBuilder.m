//
//  K9PolylineBuilder.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9PolylineBuilder.h"
#import <MapKit/MapKit.h>
#import "K9MapAnnotation.h"

@interface K9DynamicPolylineRenderer : MKOverlayPathRenderer

@end

@interface K9PolylineBuilder() {
    NSUInteger _pointSpace;
    MKMapRect _boundingMapRect;

}

@property (readonly) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;

@property K9DynamicPolylineRenderer *dynamicRenderer;

@end

#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@implementation K9PolylineBuilder

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if(self = [super init]) {
        _pointSpace = INITIAL_POINT_SPACE;
        _points = malloc(sizeof(MKMapPoint) * _pointSpace);
        _points[0] = MKMapPointForCoordinate(coordinate);
        _pointCount = 1;
        
        // bite off up to 1/4 of the world to draw into.
        MKMapPoint origin = _points[0];
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        _boundingMapRect = (MKMapRect) { origin, size };
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        _boundingMapRect = MKMapRectIntersection(_boundingMapRect, worldRect);
    }
    return self;
}

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coordinate {
    // Acquire the write lock because we are going to be changing the list of points
    
    // Convert a CLLocationCoordinate2D to an MKMapPoint
    MKMapPoint newPoint = MKMapPointForCoordinate(coordinate);
    MKMapPoint prevPoint = _points[_pointCount - 1];
    
    // Get the distance between this new point and the previous point.
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;
    
    if (metersApart > MINIMUM_DELTA_METERS)
    {
        // Grow the points array if necessary
        if (_pointSpace == _pointCount) {
            _pointSpace *= 2;
            _points = realloc(_points, sizeof(MKMapPoint) * _pointSpace);
        }
        
        // Add the new point to the points array
        _points[_pointCount] = newPoint;
        _pointCount++;
        
        // Compute MKMapRect bounding prevPoint and newPoint
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    }
        
    return updateRect;
}


- (CLLocationCoordinate2D)coordinate {
    return MKCoordinateForMapPoint(_points[0]);
}

- (MKMapRect)boundingMapRect {
    return _boundingMapRect;
}

- (MKOverlayPathRenderer *)renderer {
    if(!self.dynamicRenderer) {
        self.dynamicRenderer = [[K9DynamicPolylineRenderer alloc] initWithOverlay:self];
        self.dynamicRenderer.lineWidth = DEFAULT_MAP_ANNOTATION_WIDTH;
        self.dynamicRenderer.strokeColor = [UIColor redColor];
    }
    return self.dynamicRenderer;
}

- (MKPolyline *)polyline {
    return [MKPolyline polylineWithPoints:self.points count:self.pointCount];
}

@end


@implementation K9DynamicPolylineRenderer

- (void)createPath {
    K9PolylineBuilder *builder = [self overlay];
    self.path = [self newPathForPoints:builder.points pointCount:builder.pointCount];
}

- (CGPathRef)newPathForPoints:(MKMapPoint *)points
                   pointCount:(NSUInteger)pointCount {
    // The fastest way to draw a path in an MKOverlayView is to simplify the
    // geometry for the screen by eliding points that are too close together
    // and to omit any line segments that do not intersect the clipping rect.
    // While it is possible to just add all the points and let CoreGraphics
    // handle clipping and flatness, it is much faster to do it yourself:
    //
    if (pointCount < 2)
        return NULL;
    
    CGMutablePathRef path = NULL;
    
    BOOL needsMove = YES;
    
    // Calculate the minimum distance between any two points by figuring out
    // how many map points correspond to MIN_POINT_DELTA of screen points
    // at the current zoomScale.
    MKMapPoint point, lastPoint = points[0];
    NSUInteger i;
    for (i = 1; i < pointCount - 1; i++)
    {
        point = points[i];
//        double a2b2 = POW2(point.x - lastPoint.x) + POW2(point.y - lastPoint.y);
//        if (a2b2 >= c2) {
//            if (lineIntersectsRect(point, lastPoint, mapRect))
//            {
                if (!path)
                    path = CGPathCreateMutable();
                if (needsMove)
                {
                    CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
                    CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
                }
                CGPoint cgPoint = [self pointForMapPoint:point];
                CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
//            } else {
//                // discontinuity, lift the pen
//                needsMove = YES;
//            }
            lastPoint = point;
//        }
    }
    
    // If the last line segment intersects the mapRect at all, add it unconditionally
    point = points[pointCount - 1];
//    if (lineIntersectsRect(lastPoint, point, mapRect))
//    {
        if (!path)
            path = CGPathCreateMutable();
        if (needsMove)
        {
            CGPoint lastCGPoint = [self pointForMapPoint:lastPoint];
            CGPathMoveToPoint(path, NULL, lastCGPoint.x, lastCGPoint.y);
        }
        CGPoint cgPoint = [self pointForMapPoint:point];
        CGPathAddLineToPoint(path, NULL, cgPoint.x, cgPoint.y);
//    }
    
    return path;
}

@end