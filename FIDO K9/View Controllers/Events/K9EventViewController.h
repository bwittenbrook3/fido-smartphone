//
//  K9EventViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "K9MapViewController.h"

@class K9Event;
@interface K9EventViewController : K9MapViewController

@property (strong, nonatomic) K9Event *event;

@end
