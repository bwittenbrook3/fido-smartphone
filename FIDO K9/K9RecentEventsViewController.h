//
//  K9RecentEventsViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface K9RecentEventsViewController : UITableViewController
@property (copy) NSArray *events;
@end

@interface K9EventTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventTitleView;
@property (strong, nonatomic) IBOutlet UILabel *eventDescriptionView;

@end