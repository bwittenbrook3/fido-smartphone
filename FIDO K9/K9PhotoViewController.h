//
//  K9PhotoViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageScrollView.h"

@interface K9PhotoViewController : UIViewController

@property (strong) UIImage *image;
@property (weak) IBOutlet ImageScrollView *scrollView;

@end
