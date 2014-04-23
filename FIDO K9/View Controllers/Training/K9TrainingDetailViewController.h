//
//  K9TrainingDetailViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9Training;
@interface K9TrainingDetailViewController : UITableViewController

@property (strong) K9Training *training;


@end

@class K9Weather, CLLocation;
@interface K9TrainingDetailViewController (ProtectedMethods)
- (void)updateCell:(UITableViewCell *)weatherCell withWeather:(K9Weather *)weather;
- (void)updateCell:(UITableViewCell *)locationCell withLocation:(CLLocation *)location completionHandler:(void (^)())completionHandler;

@end
