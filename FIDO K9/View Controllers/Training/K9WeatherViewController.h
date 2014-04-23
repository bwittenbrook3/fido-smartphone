//
//  K9WeatherViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>


@class K9Weather;
@protocol K9WeatherViewControllerDelegate;
@interface K9WeatherViewController : UITableViewController

@property (weak) id<K9WeatherViewControllerDelegate> delegate;
@property (strong, nonatomic) K9Weather *weather;
@property BOOL editable;

@end


@protocol K9WeatherViewControllerDelegate <NSObject>

- (void)weatherViewController:(K9WeatherViewController *)weatherViewController didUpdateWeather:(K9Weather *)weather;

@end