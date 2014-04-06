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
@property (copy) NSArray *events;
@end

@implementation K9RecentEventsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.events = [[K9ObjectGraph sharedObjectGraph] allEvents];
    
    [[K9ObjectGraph sharedObjectGraph] fetchAllEventsWithCompletionHandler:^(NSArray *events) {
        self.events = events;
        [[self tableView] reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventTableCell" forIndexPath:indexPath];

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
