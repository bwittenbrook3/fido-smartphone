//
//  K9DogDetailViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogDetailViewController.h"
#import "K9Dog.h"
#import "K9RecentEventsViewController.h"

@interface K9DogDetailViewController ()

@property (weak) IBOutlet UILabel *officerNameLabel;

@property (weak) IBOutlet UILabel *recentEventCountLabel;
@property (weak) IBOutlet UITableViewCell *recentEventTableViewCell;
@property (weak) IBOutlet NSLayoutConstraint *recentEventsTableViewCellTrailingConstraint;

@end

@implementation K9DogDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.dog) {
        [self loadDogViews];
    }
}

- (void)setDog:(K9Dog *)dog {
    _dog = dog;
    if(self.isViewLoaded) {
        [self loadDogViews];
    }
}

- (void)loadDogViews {
    [self.officerNameLabel setText:[self.dog officerName]];
    [self.recentEventCountLabel setText:[NSString stringWithFormat:@"%ld", [[self.dog events] count]]];
    if([[self.dog events] count]) {
        [self.recentEventTableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self.recentEventTableViewCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        [self.recentEventsTableViewCellTrailingConstraint setConstant:0];
    } else {
        [self.recentEventTableViewCell setAccessoryType:UITableViewCellAccessoryNone];
        [self.recentEventTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.recentEventsTableViewCellTrailingConstraint setConstant:10];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"recentEventsSegue"]) {
        K9RecentEventsViewController *destination = [segue destinationViewController];
        [destination setEvents:[self.dog events]];
        [[destination navigationItem] setTitle:[NSString stringWithFormat:@"%@'s Events", [self.dog name]]];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"recentEventsSegue"]) {
        return [self.recentEventTableViewCell selectionStyle] != UITableViewCellSelectionStyleNone;
    } else {
        return YES;
    }
}

@end
