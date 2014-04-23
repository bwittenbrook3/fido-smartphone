//
//  K9DogDetailViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9Dog;
@interface K9DogDetailViewController : UITableViewController

@property (weak) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) K9Dog *dog;

@end
