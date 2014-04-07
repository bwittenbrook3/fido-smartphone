//
//  K9RecentEventsViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9RecentEventsViewController.h"
#import "K9Event.h"
#import "K9ObjectGraph.h"
#import "K9EventViewController.h"

@interface K9RecentEventsViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *prototypeCell;
@end

static inline NSArray *sortEvents(NSArray *events) {
    return [events sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 creationDate] compare:[obj1 creationDate]];
    }];
}

@implementation K9RecentEventsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.events) {
        self.events = sortEvents([[K9ObjectGraph sharedObjectGraph] fetchAllEventsWithCompletionHandler:^(NSArray *events) {
            self.events = sortEvents(events);
            [[self tableView] reloadData];
        }]);
    }
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    K9EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventTableCell" forIndexPath:indexPath];
    
    K9Event *event = [self.events objectAtIndex:indexPath.row];
    
    [[cell eventTitleView] setText:[event title]];
    
    NSDate *creationDate = [event creationDate];
    NSDate *now = [NSDate date];
    
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:creationDate];
    
    NSString *timeIntervalText;
    
    NSInteger seconds = (NSInteger)timeInterval;
    NSInteger minutes = (seconds / 60);
    NSInteger hours = (minutes / 60);
    NSInteger days = (hours / 24);

    if(days) {
        if(days > 1) {
            timeIntervalText = [NSString stringWithFormat:@"%ld days ago", days];
        } else {
            timeIntervalText = [NSString stringWithFormat:@"1 day ago"];
        }
    } else if(hours) {
        if(hours > 1) {
            timeIntervalText = [NSString stringWithFormat:@"%ld hours ago", hours];
        } else {
            timeIntervalText = [NSString stringWithFormat:@"1 hour ago"];
        }
    } else if(minutes) {
        if(minutes > 1) {
            timeIntervalText = [NSString stringWithFormat:@"%ld minutes ago", minutes];
        } else {
            timeIntervalText = [NSString stringWithFormat:@"1 minute ago"];
        }
    } else {
        timeIntervalText = @"Just now";
    }
    
    
    [[cell eventDescriptionView] setText:timeIntervalText];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.prototypeCell;

    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"selectedEventSegue"]) {
        K9Event *event = nil;
        if([sender isKindOfClass:[NSNumber class]]) {
            event = [[K9ObjectGraph sharedObjectGraph] eventWithID:[sender integerValue]];
        } else {
            event = [self.events objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
    
        K9EventViewController *destination = segue.destinationViewController;
        [destination setEvent:event];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end

@implementation K9EventTableViewCell

@end
