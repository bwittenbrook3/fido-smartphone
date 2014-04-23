 //
//  K9CertificationAndTrainingListViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9CertificationAndTrainingListViewController.h"
#import "K9ObjectGraph.h"
#import "K9Dog.h"

@interface K9CertificationAndTrainingListViewController ()

@end

@implementation K9CertificationAndTrainingListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    self.trainings = @[];
    [super viewDidLoad];
    
    if(self.dog) [self reloadDogViews];
}


- (void)setDog:(K9Dog *)dog {
    if(_dog != dog) {
        _dog = dog;
        if(self.isViewLoaded) [self reloadDogViews];
    }
}

- (void)reloadDogViews {
    self.trainings = [[K9ObjectGraph sharedObjectGraph] trainingForDogWithID:[self.dog dogID]];
    [[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.dog.certifications.count;
        case 1:
        default:
            return [super tableView:tableView numberOfRowsInSection:0];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Certificates";
    } else {
        return @"Training";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"certificateTableCell" forIndexPath:indexPath];
        
        [[cell textLabel] setText:self.dog.certifications[indexPath.row]];
        
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Background color
    header.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.95];
    header.contentView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.95];
    header.contentView.alpha = 0.95;
}


@end
