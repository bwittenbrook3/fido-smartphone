//
//  K9DogViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "K9MapViewController.h"

@class K9Dog;
@interface K9DogViewController : K9MapViewController

@property (strong, nonatomic) K9Dog *dog;

@end
