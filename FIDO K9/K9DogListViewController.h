//
//  K9K9ListViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface K9DogListViewController : UITableViewController

@end

@class K9CircularBorderImageView;
@interface K9DogTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet K9CircularBorderImageView *dogProfileView;
@property (strong, nonatomic) IBOutlet UILabel *dogNameView;

@end