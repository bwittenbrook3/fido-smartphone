//
//  K9TrainingDetailViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9TrainingDetailViewController.h"

#import "K9Training.h"
#import "K9Dog.h"
#import "K9Weather.h"
#import "K9WeatherViewController.h"

#import <CoreLocation/CLGeocoder.h>

@interface K9TrainingDetailViewController()

@property (strong) CLGeocoder *geocoder;

@end

@implementation K9TrainingDetailViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.training.trainedDog) {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ Training", self.training.trainedDog.name]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
        default:
            return self.training.trainingAidList.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Info";
        case 1:
            return @"Training Aids";
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NSUInteger row = indexPath.row;
        switch (row) {
            case 0:
                cell = [tableView dequeueReusableCellWithIdentifier:@"nameTableCell" forIndexPath:indexPath];
                if(self.training.trainedDog) {
                    cell.detailTextLabel.text = [self.training.trainedDog name];
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"locationTableCell" forIndexPath:indexPath];
                if(self.training.location) {
                    [self updateCell:cell withLocation:self.training.location completionHandler:nil];
                }
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"trainingTypeTableCell" forIndexPath:indexPath];
                cell.detailTextLabel.text = self.training.formattedTrainingType;
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:@"weatherTableCell" forIndexPath:indexPath];
                if(self.training.weather) {
                    [self updateCell:cell withWeather:self.training.weather];
                }
                break;
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"aidTableCell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Aid %ld", (indexPath.row+1)];
        cell.detailTextLabel.text = [[self.training.trainingAidList objectAtIndex:indexPath.row] status];
    }
    
    return cell;
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

- (void)updateCell:(UITableViewCell *)locationCell withLocation:(CLLocation *)location completionHandler:(void (^)())completionHandler {
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error){
         locationCell.accessoryView = nil;
         locationCell.accessoryType = UITableViewCellAccessoryNone;
         
         // TODO: Use other placemark details instead of name?
         locationCell.detailTextLabel.text = [[placemarks firstObject] name];
         
         if(completionHandler) completionHandler();
     }];
}

- (void)updateCell:(UITableViewCell *)weatherCell withWeather:(K9Weather *)weather {
    weatherCell.accessoryView = nil;
    weatherCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    weatherCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    weatherCell.detailTextLabel.text = [weather formattedDescription];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"weatherSegue"]) {
        K9WeatherViewController *destination = segue.destinationViewController;
        [destination setWeather:self.training.weather];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

@end
