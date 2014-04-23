//
//  K9PhotoBrowserViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface K9ResourceBrowserViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (copy, nonatomic) NSArray *resources;
@property (nonatomic) NSInteger currentIndex;


@property (strong) UIImageView *backgroundImageView;

@end
