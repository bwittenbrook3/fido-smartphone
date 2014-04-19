//
//  K9OverlayViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9MapAnnotation;
@interface K9OverlayViewController : UIViewController

@property (strong) K9MapAnnotation *mapAnnotation;


- (void)snapshotOverlayView:(void (^)(UIImage *snapshot))completionHandler;

@end
