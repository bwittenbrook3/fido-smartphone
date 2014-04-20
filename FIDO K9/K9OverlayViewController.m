//
//  K9OverlayViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9OverlayViewController.h"
#import <MapKit/MapKit.h>
#import "K9MapAnnotation+AnnotationSnapshot.h"

@interface K9OverlayViewController () <MKMapViewDelegate>

@property (weak) MKMapView *mapView;
@end

@implementation K9OverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)loadView {
    MKMapView *mapView = [[MKMapView alloc] init];
    self.mapView = mapView;
    self.mapView.delegate = self;
    self.mapView.scrollEnabled = NO;
    self.view = mapView;
    if(_mapAnnotation) [self updatePolylines];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMapAnnotation:(K9MapAnnotation *)mapAnnotation {
    _mapAnnotation = mapAnnotation;
    if(self.isViewLoaded) {
        [self updatePolylines];
    }
}

- (void)updatePolylines {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    MKMapRect zoomRect = MKMapRectNull;
    for (MKPolyline *polyline in self.mapAnnotation.polylines) {
        MKMapRect mapRect = [polyline boundingMapRect];
        zoomRect = MKMapRectUnion(zoomRect, mapRect);
    }
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(64 + 20, 20, 50 + 20, 20) animated:NO];
    
//    [self.mapView setRegion:MKCoordinateRegionForMapRect(zoomRect)];
    
    [self.mapView addOverlays:self.mapAnnotation.polylines];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    MKMapRect zoomRect = MKMapRectNull;
    for (MKPolyline *polyline in self.mapAnnotation.polylines) {
        MKMapRect mapRect = [polyline boundingMapRect];
        zoomRect = MKMapRectUnion(zoomRect, mapRect);
    }
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(64 + 20, 20, 50 + 20, 20) animated:YES];
    
//    [self.mapView setRegion:MKCoordinateRegionForMapRect(zoomRect) animated:YES];
   
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    if(self.view.window) {
//        [self snapshotOverlayView:^(UIImage *snapshot) {
//            [self.mapAnnotation setMapAnnotationSnapshot:snapshot];
//        }];
//    }
//}

- (void)snapshotOverlayView:(void (^)(UIImage *snapshot))completionHandler {
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.size = self.mapView.frame.size;
    options.scale = [[UIScreen mainScreen] scale];
    
    //    NSURL *fileURL = [NSURL fileURLWithPath:@"path/to/snapshot.png"];
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithQueue:dispatch_get_main_queue()
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  if (error) {
                      NSLog(@"[Error] %@", error);
                      return;
                  }
            
                  UIImage *image = snapshot.image;
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  {
                      [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                      
//                      CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
                      for (MKPolyline *polyline in self.mapAnnotation.polylines) {
                          [[self.mapAnnotation colorForPolyline:polyline] set];
                          CGContextRef context = UIGraphicsGetCurrentContext();
                          CGContextSetLineWidth(context, [self.mapAnnotation lineWidthForPolyline:polyline]);
                          CGContextBeginPath(context);
                          
                          CLLocationCoordinate2D coordinates[[polyline pointCount]];
                          [polyline getCoordinates:coordinates range:NSMakeRange(0, [polyline pointCount])];
                          
                          for(int i=0;i<[polyline pointCount];i++)
                          {
                              CGPoint point = [snapshot pointForCoordinate:coordinates[i]];
                              
                              if(i==0)
                              {
                                  CGContextMoveToPoint(context,point.x, point.y);
                              }
                              else{
                                  CGContextAddLineToPoint(context,point.x, point.y);
                                  
                              }
                          }
                          
                          CGContextStrokePath(context);

                      }
                      
                      
                      UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                      completionHandler(image);
                      NSLog(@"updated cached snapshot");
                  }
                  UIGraphicsEndImageContext();
              }];
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.lineWidth = [self.mapAnnotation lineWidthForPolyline:overlay];
    renderer.strokeColor = [self.mapAnnotation colorForPolyline:overlay];
    return renderer;
}



@end
