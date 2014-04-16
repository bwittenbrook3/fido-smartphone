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
#import <MapKit/MapKit.h>

@interface K9NewTrainingViewController () <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

@property IBOutlet UITableViewCell *k9PickerTableViewCell;
@property IBOutlet UIPickerView *k9Picker;

@property NSArray *aidList;
@property K9Dog *trainedDog;
@property K9Weather *weather;

@property NSArray *cachedDogs;

@property (getter = isShowingK9Picker)BOOL showingK9Picker;


@property (strong) CLLocationManager *locationManager;
@property (strong) CLGeocoder *geocoder;
@property (strong) CLLocation *location;
@property BOOL loadingLocation;
@end


static inline NSArray *sortDogs(NSArray *dogs) {
    return [dogs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];
}

@implementation K9NewTrainingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4 + ([self isShowingK9Picker] ? 1 : 0);
        case 1:
        default:
            return self.aidList.count + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Info";
        case 1:
            return @"Aids";
        default:
            return @"";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0) {
        NSUInteger row = indexPath.row;
        if(row > 0 && [self isShowingK9Picker]) {
            row -= 1;
        }
        
        switch (row) {
            case 0:
                if(![self isShowingK9Picker]) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"nameTableCell" forIndexPath:indexPath];
                    if(self.trainedDog) {
                        cell.detailTextLabel.text = [self.trainedDog name];
                    }
                } else {
                    cell = self.k9PickerTableViewCell;
                }
                break;
            case 1:
                cell = [tableView dequeueReusableCellWithIdentifier:@"locationTableCell" forIndexPath:indexPath];
                
                if(self.location) {
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [self updateCell:cell withLocation:self.location completionHandler:^{
                        self.loadingLocation = NO;
                    }];
                } else if(self.loadingLocation) {
                    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                break;
            case 2:
                cell = [tableView dequeueReusableCellWithIdentifier:@"trainingTypeTableCell" forIndexPath:indexPath];
                break;
            case 3:
                cell = [tableView dequeueReusableCellWithIdentifier:@"weatherTableCell" forIndexPath:indexPath];
                if(self.weather) {
                    [self updateCell:cell withWeather:self.weather];
                }
                break;
        }
    } else {
        if(indexPath.row < self.aidList.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aidTableCell" forIndexPath:indexPath];            
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"newAidTableCell" forIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    
    BOOL wasShowingK9Picker = [self isShowingK9Picker];
    
    if ([self isShowingK9Picker]){
        [self hideK9Picker];
    }
    
    if(indexPath.section == 0 && indexPath.row == 0 && !wasShowingK9Picker){
        [self showK9Picker];
    } else if(indexPath.section == 0 && indexPath.row == (wasShowingK9Picker ? 2 : 1)) {
        [self didSelectLocationCell];
    }
              

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
}

- (void)didSelectLocationCell {
    if(!self.location && !self.loadingLocation) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Use Current Location?" message:@"FIDO will automatically fill out location and weather information" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        // YES Button
        
        UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        [locationCell setAccessoryView:activityView];
        [locationCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        
        [self.locationManager startUpdatingLocation];
        
        self.loadingLocation = YES;
    } else {
        // NO Button -- show alternate UI.
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
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(![self trainedDog]) {
        row -= 1;
    }
    if(row != -1) {
        K9Dog *selectedDog = [self.cachedDogs objectAtIndex:row];
        
        UITableViewCell *k9NameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        k9NameCell.detailTextLabel.text = [selectedDog name];
        self.trainedDog = selectedDog;
        [pickerView reloadComponent:component];
        [pickerView selectRow:row inComponent:component animated:NO];
    }
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(!self.cachedDogs) {
        self.cachedDogs = sortDogs([[K9ObjectGraph sharedObjectGraph] allDogs]);
    }
    return [self.cachedDogs count] + ([self trainedDog] ? 0 : 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(!self.cachedDogs) {
        self.cachedDogs = sortDogs([[K9ObjectGraph sharedObjectGraph] allDogs]);
    }
    
    if(![self trainedDog]) {
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
    self.location = newLocation;
    
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
    [self updateCell:locationCell withLocation:self.location completionHandler:^{
        self.loadingLocation = NO;
    }];
    [K9Weather fetchWeatherForLocation:self.location completionHandler:^(K9Weather *weather) {
        UITableViewCell *weatherCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 4 : 3) inSection:0]];
        self.weather = weather;
        [self updateCell:weatherCell withWeather:weather];
    }];
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
         
         completionHandler();
     }];
}

- (void)updateCell:(UITableViewCell *)weatherCell withWeather:(K9Weather *)weather {
    weatherCell.detailTextLabel.text = [weather formattedDescription];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    
    UITableViewCell *locationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self isShowingK9Picker] ? 2 : 1) inSection:0]];
    locationCell.accessoryView = nil;
    locationCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.loadingLocation = NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
