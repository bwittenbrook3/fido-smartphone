//
//  K9NewTrainingNavigationViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/15/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9NewTrainingViewController.h"
#import "K9ObjectGraph.h"
#import "K9Dog.h"
#import "K9Weather.h"
#import "K9Training.h"
#import "K9Preferences.h"
#import <MapKit/MapKit.h>
#import "K9WeatherViewController.h"

@interface K9NewTrainingViewController () <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, K9WeatherViewControllerDelegate>

@property NSArray *cachedDogs;
@property IBOutlet UITableViewCell *k9PickerTableViewCell;
@property IBOutlet UIPickerView *k9Picker;
@property (getter = isShowingK9Picker)BOOL showingK9Picker;

@property (strong) CLLocationManager *locationManager;
@property (strong) CLGeocoder *geocoder;
@property BOOL loadingLocation;
@property BOOL permissionAlertIsUp;
@end


@interface K9Training (TrainingValidation)

- (BOOL)isValidTraining;

@end

static inline NSArray *sortDogs(NSArray *dogs) {
    return [dogs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];
}

@implementation K9NewTrainingViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a new mutable training object to build
    self.training = [K9Training new];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [super tableView:tableView numberOfRowsInSection:section];
    switch (section) {
        case 0:
            numberOfRows += ([self isShowingK9Picker] ? 1 : 0);
            break;
        case 1:
        default:
            numberOfRows += 1;
            break;
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0) {
        NSUInteger trueRow = indexPath.row;
        if(trueRow > 0 && [self isShowingK9Picker]) {
            trueRow -= 1;
        }
        
        if([self isShowingK9Picker] && indexPath.row == 1) {
            cell = self.k9PickerTableViewCell;
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trueRow inSection:indexPath.section]];
            switch (trueRow) {
                case 1:
                    if(self.loadingLocation) {
                        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        [activityView startAnimating];
                        [cell setAccessoryView:activityView];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    
                    break;
                case 3:
                    if(self.loadingLocation) {
                        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        [activityView startAnimating];
                        [cell setAccessoryView:activityView];
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    }
                    break;
            }
        }
    } else if (indexPath.section == 1) {
        if(indexPath.row < self.training.trainingAidList.count) {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"newAidTableCell" forIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL wasShowingK9Picker = [self isShowingK9Picker];
    
    if(indexPath.section == 0 && indexPath.row == (wasShowingK9Picker ? 2 : 1)) {
        [self didSelectLocationCell];
    } else if(indexPath.section == 0 && indexPath.row == (wasShowingK9Picker ? 4 : 3)) {
        [self didSelectWeatherCell];
    }
    
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL wasShowingK9Picker = [self isShowingK9Picker];

    if ([self isShowingK9Picker]){
        [self hideK9Picker];
    }
    
    if(indexPath.section == 0 && indexPath.row == 0 && !wasShowingK9Picker){
        [self showK9Picker];
    }
    if(indexPath.section == 1 && indexPath.row == self.training.trainingAidList.count) {
        if(!self.training.trainingAidList) self.training.trainingAidList = @[];
        self.training.trainingAidList = [self.training.trainingAidList arrayByAddingObject:[K9TrainingAid new]];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.training.trainingAidList.count-1) inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        [self checkForValidTraining];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"weatherSegue"]) {
        if(self.permissionAlertIsUp || self.loadingLocation) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"weatherSegue"]) {
        K9WeatherViewController *destination = segue.destinationViewController;
        destination.delegate = self;
        if(!self.training.weather) {
            self.training.weather = [K9Weather new];
        }
        [destination setWeather:self.training.weather];
        [destination setEditable:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)weatherViewController:(K9WeatherViewController *)weatherViewController didUpdateWeather:(K9Weather *)weather {
    self.training.weather = weather;
    NSIndexPath *weatherIndexPath = [NSIndexPath indexPathForRow:(self.isShowingK9Picker ? 4 : 3) inSection:0];
    [self updateCell:[self.tableView cellForRowAtIndexPath:weatherIndexPath] withWeather:self.training.weather];
}

- (BOOL)didSelectLocationCell {
    BOOL shouldDeselectCell = YES;
    if(!self.training.location && !self.loadingLocation) {
        // We don't have a location, so the user has to either manually enter it or we can fetch it.
        if([K9Preferences locationPreference] == K9PreferencesLocationNoStatus) {
            // If we haven't asked before, ask if we can use their location using our own UI
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Use Current Location?" message:@"FIDO will automatically fill out location and weather information" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
            shouldDeselectCell = NO;
            self.permissionAlertIsUp = YES;
        } else if([K9Preferences locationPreference] == K9PreferencesLocationAbsoluteAccepted) {
            // If we've asked before and they've accepted everything, we're free to go.
            [self getCurrentLocationAndUpdateTable];
        } else {
            // We've asked before and they've denied either locally or absolutely. Either way, don't ask again.
        }
    }
    return shouldDeselectCell;
}

- (BOOL)didSelectWeatherCell {
    BOOL shouldDeselectCell = YES;
    if(!self.training.weather && !self.training.location && !self.loadingLocation) {
        // We don't have a location, so the user has to either manually enter it or we can fetch it.
        if([K9Preferences locationPreference] == K9PreferencesLocationNoStatus) {
            // If we haven't asked before, ask if we can use their location using our own UI
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Use Current Location?" message:@"FIDO will automatically fill out location and weather information" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
            shouldDeselectCell = NO;
            self.permissionAlertIsUp = YES;
        } else if([K9Preferences locationPreference] == K9PreferencesLocationAbsoluteAccepted) {
            // If we've asked before and they've accepted everything, we're free to go.
            [self getCurrentLocationAndUpdateTable];
        } else {
            // We've asked before and they've denied either locally or absolutely. Either way, don't ask again.
        }
    }
    return shouldDeselectCell;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        // YES Button
        [self getCurrentLocationAndUpdateTable];
    } else {
        // NO Button -- show alternate UI.
        
        [K9Preferences setLocationPreference:K9PreferencesLocationLocalDenied];
        
        BOOL selectedWeatherCell = self.tableView.indexPathForSelectedRow.row == (self.isShowingK9Picker ? 4 : 3);
        
        if(selectedWeatherCell) {
            [self performSegueWithIdentifier:@"weatherSegue" sender:nil];
        }
        
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    self.permissionAlertIsUp = NO;
}

- (void)getCurrentLocationAndUpdateTable {
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    [locationCell setAccessoryView:activityView];
    [locationCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    UITableViewCell *weatherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 4 : 3) inSection:0]];
    UIActivityIndicatorView *activityView2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView2 startAnimating];
    [weatherCell setAccessoryView:activityView2];
    [weatherCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager startUpdatingLocation];
    
    self.loadingLocation = YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = self.tableView.rowHeight;
    if ([self isShowingK9Picker] && (indexPath.section == 0 && indexPath.row == 1)){
        rowHeight = self.k9PickerTableViewCell.frame.size.height;
    }
    
    return rowHeight;
}


- (void)showK9Picker {
    if(![self isShowingK9Picker]) {
        self.showingK9Picker = YES;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (void)hideK9Picker {
    if([self isShowingK9Picker]) {
        self.showingK9Picker = NO;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(![self.training trainedDog]) {
        row -= 1;
    }
    if(row != -1) {
        K9Dog *selectedDog = [self.cachedDogs objectAtIndex:row];
        
        UITableViewCell *k9NameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        k9NameCell.detailTextLabel.text = [selectedDog name];
        self.training.trainedDog = selectedDog;
        [pickerView reloadComponent:component];
        [pickerView selectRow:row inComponent:component animated:NO];
        [self checkForValidTraining];
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(!self.cachedDogs) {
        self.cachedDogs = sortDogs([[K9ObjectGraph sharedObjectGraph] allDogs]);
    }
    return [self.cachedDogs count] + ([self.training trainedDog] ? 0 : 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(!self.cachedDogs) {
        self.cachedDogs = sortDogs([[K9ObjectGraph sharedObjectGraph] allDogs]);
    }
    
    if(![self.training trainedDog]) {
        row -= 1;
    }
    
    
    NSString *pickerTitle = @"";
    if(row != -1) {
        pickerTitle = [[self.cachedDogs objectAtIndex:row] name];
    }

    return pickerTitle;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    self.training.location = newLocation;
    [self checkForValidTraining];
    
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
    [self updateCell:locationCell withLocation:self.training.location completionHandler:^{
        self.loadingLocation = NO;
    }];
    [K9Weather fetchWeatherForLocation:self.training.location completionHandler:^(K9Weather *weather) {
        UITableViewCell *weatherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 4 : 3) inSection:0]];
        self.training.weather = weather;
        [self checkForValidTraining];
        [self updateCell:weatherCell withWeather:weather];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
    locationCell.accessoryView = nil;
    locationCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.loadingLocation = NO;
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [K9Preferences setLocationPreference:K9PreferencesLocationAbsoluteDenied];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        [K9Preferences setLocationPreference:K9PreferencesLocationAbsoluteAccepted];
    }
}


- (void)checkForValidTraining {
    if(self.training.isValidTraining) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (IBAction)submitTraining:(id)sender {
    if(self.training.isValidTraining) {
        self.training.startTime = [NSDate date];
        [[K9ObjectGraph sharedObjectGraph] addTraining:self.training];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}


@end


@implementation K9Training (TrainingValidation)

- (BOOL)isValidTraining {
    return self.trainedDog && self.location && self.weather && self.trainingAidList.count;//(self.trainingType != K9TrainingTypeNone)
}

@end
