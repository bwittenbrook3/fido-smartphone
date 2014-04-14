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
#import "K9AttachmentListViewController.h"

@interface K9DogDetailViewController ()

@property (weak) IBOutlet UILabel *officerNameLabel;

@property (weak) IBOutlet UILabel *recentEventCountLabel;
@property (weak) IBOutlet UITableViewCell *recentEventTableViewCell;
@property (weak) IBOutlet NSLayoutConstraint *recentEventsTableViewCellTrailingConstraint;

@property (weak) IBOutlet UILabel *attachmentsCountLabel;
@property (weak) IBOutlet UITableViewCell *attachmentsTableViewCell;
@property (weak) IBOutlet NSLayoutConstraint *attachmentsTableViewCellTrailingConstraint;

@property (weak) IBOutlet UILabel *ageLabel;

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
    [self.statusLabel setText:[self.dog status]];
    [self.officerNameLabel setText:[self.dog officerName]];
    [self.ageLabel setText:[self.dog formattedAge]];
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
    
    [self.attachmentsCountLabel setText:[NSString stringWithFormat:@"%ld", [[self.dog attachments] count]]];
    if([[self.dog attachments] count]) {
        [self.attachmentsTableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self.attachmentsTableViewCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        [self.attachmentsTableViewCellTrailingConstraint setConstant:0];
    } else {
        [self.attachmentsTableViewCell setAccessoryType:UITableViewCellAccessoryNone];
        [self.attachmentsTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.attachmentsTableViewCellTrailingConstraint setConstant:10];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"recentEventsSegue"]) {
        K9RecentEventsViewController *destination = [segue destinationViewController];
        [destination setEvents:[self.dog events]];
        [[destination navigationItem] setTitle:[NSString stringWithFormat:@"%@'s Events", [self.dog name]]];
    } else if([[segue identifier] isEqualToString:@"attachmentsSegue"]) {
        K9AttachmentListViewController *destination = [segue destinationViewController];
        [destination setAttachments:[self.dog attachments]];
        [[destination navigationItem] setTitle:[NSString stringWithFormat:@"%@'s Attachments", [self.dog name]]];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"recentEventsSegue"]) {
        return [self.recentEventTableViewCell selectionStyle] != UITableViewCellSelectionStyleNone;
    } else if ([identifier isEqualToString:@"attachmentsSegue"]) {
        return [self.attachmentsTableViewCell selectionStyle] != UITableViewCellSelectionStyleNone;
    } else {
        return YES;
    }
}

@end
