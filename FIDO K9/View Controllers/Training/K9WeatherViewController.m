//
//  K9WeatherViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9WeatherViewController.h"
#import "K9Weather.h"
#import "K9Preferences.h"
#import "WLHorizontalSegmentedControl.h"

#define TEMPERATURE_CELL_IDENTIFIER @"temperatureViewCell"
#define HUMIDITY_CELL_IDENTIFIER @"humidityViewCell"
#define OVERCAST_CELL_IDENTIFIER @"overcastViewCell"
#define PRECIPITATION_CELL_IDENTIFIER @"precipitationViewCell"
#define WIND_CELL_IDENTIFIER @"windViewCell"


#define EXTRA_VIEW_TAG (3141)
#define TEMPERATURE_SLIDER_TAG (EXTRA_VIEW_TAG)
#define HUMIDITY_SLIDER_TAG (EXTRA_VIEW_TAG)
#define OVERCAST_SLIDER_TAG (EXTRA_VIEW_TAG)
#define WIND_SPEED_SLIDER_TAG (EXTRA_VIEW_TAG)

#import <CoreLocation/CLLocationManager.h>

@interface K9WeatherViewController () <UIActionSheetDelegate, CLLocationManagerDelegate>

@property (strong) IBOutlet UIBarButtonItem *editButton;
@property (strong) IBOutlet UIBarButtonItem *doneButton;
@property (strong) IBOutlet UIBarButtonItem *useLocationBarButton;

@property (strong) IBOutlet UISegmentedControl *precipitationWeatherControl;
@property (strong) IBOutlet WLHorizontalSegmentedControl *windDirectionControl;

@property BOOL editMode;

@property (strong) CLLocationManager *locationManager;
@property BOOL loadingLocation;


@end

@interface K9Weather (StringFormats)

@property (readonly) NSString *precipitationString;
@property (readonly) NSString *windBearingShortString;

@end

@implementation K9WeatherViewController

static NSArray *_tableCellIdentifiers;
+ (NSArray *)tableCellIdentifiers {
    if(!_tableCellIdentifiers) {
        _tableCellIdentifiers = @[TEMPERATURE_CELL_IDENTIFIER, HUMIDITY_CELL_IDENTIFIER, OVERCAST_CELL_IDENTIFIER, PRECIPITATION_CELL_IDENTIFIER, WIND_CELL_IDENTIFIER];
    }
    return _tableCellIdentifiers;
}


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.editable) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItems = @[self.editButton];
    }
    
    self.windDirectionControl = [[WLHorizontalSegmentedControl alloc] initWithItems:@[@"N", @"S", @"W", @"E"]];
	self.windDirectionControl.allowsMultiSelection = YES;
	[self.windDirectionControl addTarget:self action:@selector(changeWindDirection:) forControlEvents:UIControlEventValueChanged];
	self.windDirectionControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.windDirectionControl.tintColor = [UIColor darkGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeWindDirection:(WLHorizontalSegmentedControl *)sender {
    NSMutableIndexSet *indexSet = [[sender selectedSegmentIndice] mutableCopy];
    K9WeatherWindBearing oldBearing = self.weather.windBearing;
    
    if([indexSet containsIndex:0] && [indexSet containsIndex:1]) {
        BOOL wasNorth = oldBearing & K9WeatherWindBearingNorth;
        if(wasNorth) {
            [indexSet removeIndex:0];
        } else {
            [indexSet removeIndex:1];
        }
    }
    if([indexSet containsIndex:2] && [indexSet containsIndex:3]) {
        BOOL wasWest = oldBearing & K9WeatherWindBearingWest;
        if(wasWest) {
            [indexSet removeIndex:2];
        } else {
            [indexSet removeIndex:3];
        }
    }
    
    if(![indexSet count]) {
        if(oldBearing & K9WeatherWindBearingNorth) {
            [indexSet addIndex:0];
        } else if(oldBearing & K9WeatherWindBearingSouth) {
            [indexSet addIndex:1];
        } else if(oldBearing & K9WeatherWindBearingWest) {
            [indexSet addIndex:2];
        } else if(oldBearing & K9WeatherWindBearingEast) {
            [indexSet addIndex:3];
        }
    }
    
    __block K9WeatherWindBearing newBearing = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        newBearing |= (1 << idx);
    }];
    self.weather.windBearing = newBearing;
    
    [sender setSelectedSegmentIndice:indexSet];
}

- (void)updateWindDirectionControl:(WLHorizontalSegmentedControl *)control withWindBearing:(K9WeatherWindBearing)windBearing {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if (windBearing & K9WeatherWindBearingNorth) {
        [indexSet addIndex:0];
    } else if (windBearing & K9WeatherWindBearingSouth) {
        [indexSet addIndex:1];
    }
    if (windBearing & K9WeatherWindBearingWest) {
        [indexSet addIndex:2];
    } else if (windBearing & K9WeatherWindBearingEast) {
        [indexSet addIndex:3];
    }
    [control setSelectedSegmentIndice:indexSet];
}

- (IBAction)changePrecipitation:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.weather.precipitation = K9WeatherPrecipitationNone;
            break;
        case 1:
            self.weather.precipitation = K9WeatherPrecipitationRain;
            break;
        case 2:
            self.weather.precipitation = K9WeatherPrecipitationSnow;
            break;
    }
}

- (IBAction)changeHumidity:(UISlider *)sender {
    CGFloat humidity = [sender value];
    self.weather.humidity = humidity;
    [self.tableView reloadData];
}

- (IBAction)changeOvercast:(UISlider *)sender {
    CGFloat overcast = [sender value];
    self.weather.cloudCoverage = overcast;
    [self.tableView reloadData];
}

- (IBAction)changeTemperature:(UISlider *)sender {
    CGFloat temperature = [sender value];
    self.weather.temperatureInFahrenheit = temperature;
    [self.tableView reloadData];
}

- (IBAction)changeWindSpeed:(UISlider *)sender {
    CGFloat windSpeed = [sender value];
    self.weather.windSpeedInMilesPerHour = windSpeed;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self class] tableCellIdentifiers] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [[[self class] tableCellIdentifiers] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *textLabel = cell.textLabel;
    if([textLabel translatesAutoresizingMaskIntoConstraints]) {
        // Normally the text label takes up more width than it should, lets make it just use constraints
        [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[textLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textLabel)]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }

    UILabel *detailLabel = cell.detailTextLabel;

    if(self.loadingLocation) {
        [[cell.contentView viewWithTag:EXTRA_VIEW_TAG] removeFromSuperview];
        [self.windDirectionControl removeFromSuperview];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        [cell setAccessoryView:activityView];
        [detailLabel setText:@" "];
        [textLabel setHidden:NO];
    } else {
        if([[cell accessoryView] isKindOfClass:[UIActivityIndicatorView class]]) [cell setAccessoryView:nil];
        
        if ([identifier isEqualToString:TEMPERATURE_CELL_IDENTIFIER]) {
            detailLabel.text = [NSString stringWithFormat:@"%.1f °F", self.weather.temperatureInFahrenheit];

            if(self.editMode && ![cell.contentView viewWithTag:TEMPERATURE_SLIDER_TAG]) {
                UISlider *temperatureSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
                [temperatureSlider setTag:TEMPERATURE_SLIDER_TAG];
                [temperatureSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
                [temperatureSlider setMinimumValue:-10.0];
                [temperatureSlider setMaximumValue:100.0];
                [temperatureSlider setValue:self.weather.temperatureInFahrenheit];
                [temperatureSlider addTarget:self action:@selector(changeTemperature:) forControlEvents:UIControlEventValueChanged];

                [cell.contentView addSubview:temperatureSlider];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textLabel]-(>=30)-[temperatureSlider]-(>=8)-[detailLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textLabel, temperatureSlider, detailLabel)]];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[temperatureSlider(==100@900)]-(==70@720)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(temperatureSlider)]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:temperatureSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            } else if(!self.editMode) {
                detailLabel.text = [NSString stringWithFormat:@"%.2f °F", self.weather.temperatureInFahrenheit];
                [[cell.contentView viewWithTag:TEMPERATURE_SLIDER_TAG] removeFromSuperview];
            }
        } else if ([identifier isEqualToString:HUMIDITY_CELL_IDENTIFIER]) {
            detailLabel.text = [NSString stringWithFormat:@"%.1f%%", (self.weather.humidity*100)];
            [detailLabel sizeToFit];

            if(self.editMode && ![cell.contentView viewWithTag:HUMIDITY_SLIDER_TAG]) {
                UISlider *humiditySlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
                [humiditySlider setTag:HUMIDITY_SLIDER_TAG];
                [humiditySlider setTranslatesAutoresizingMaskIntoConstraints:NO];
                [humiditySlider setMinimumValue:0.0];
                [humiditySlider setMaximumValue:1.0];
                [humiditySlider setValue:self.weather.humidity];
                [humiditySlider addTarget:self action:@selector(changeHumidity:) forControlEvents:UIControlEventValueChanged];
                
                [cell.contentView addSubview:humiditySlider];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textLabel]-(>=30)-[humiditySlider]-(>=8)-[detailLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textLabel, humiditySlider, detailLabel)]];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[humiditySlider(==100@900)]-(==70@720)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(humiditySlider)]];

                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:humiditySlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            } else if(!self.editMode) {
                [[cell.contentView viewWithTag:HUMIDITY_SLIDER_TAG] removeFromSuperview];
            }
        } else if ([identifier isEqualToString:OVERCAST_CELL_IDENTIFIER]) {
            detailLabel.text = [NSString stringWithFormat:@"%.1f%%", (self.weather.cloudCoverage*100)];
            [detailLabel sizeToFit];
            
            if(self.editMode && ![cell.contentView viewWithTag:OVERCAST_SLIDER_TAG]) {
                UISlider *overcastSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
                [overcastSlider setTag:OVERCAST_SLIDER_TAG];
                [overcastSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
                [overcastSlider setMinimumValue:0.0];
                [overcastSlider setMaximumValue:1.0];
                [overcastSlider setValue:self.weather.cloudCoverage];
                [overcastSlider addTarget:self action:@selector(changeOvercast:) forControlEvents:UIControlEventValueChanged];

                
                [cell.contentView addSubview:overcastSlider];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textLabel]-(>=30)-[overcastSlider]-(>=8)-[detailLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textLabel, overcastSlider, detailLabel)]];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[overcastSlider(==100@900)]-(==70@720)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(overcastSlider)]];
                
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overcastSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            } else if(!self.editMode) {
                [[cell.contentView viewWithTag:OVERCAST_SLIDER_TAG] removeFromSuperview];
            }        
        } else if ([identifier isEqualToString:PRECIPITATION_CELL_IDENTIFIER]) {
            
            if(self.editMode && ![cell.accessoryView isKindOfClass:[UISegmentedControl class]]) {
                cell.accessoryView = self.precipitationWeatherControl;
                
                NSInteger selectedSegment = UISegmentedControlNoSegment;
                
                switch(self.weather.precipitation) {
                    case K9WeatherPrecipitationNone:
                        selectedSegment = 0;
                        break;
                    case K9WeatherPrecipitationRain:
                        selectedSegment = 1;
                        break;
                    case K9WeatherPrecipitationSnow:
                    case K9WeatherPrecipitationHail:
                    case K9WeatherPrecipitationSleet:
                        selectedSegment = 2;
                        break;
                }
                
                [self.precipitationWeatherControl setSelectedSegmentIndex:selectedSegment];

                detailLabel.text = @"";
            } else if(!self.editMode) {
                cell.accessoryView = nil;
                detailLabel.text = self.weather.precipitationString;
            }
        } else if ([identifier isEqualToString:WIND_CELL_IDENTIFIER]) {
            detailLabel.text = [NSString stringWithFormat:@"%.0f mph", self.weather.windSpeedInMilesPerHour];

            if(self.editMode && ![cell.contentView viewWithTag:WIND_SPEED_SLIDER_TAG]) {
                [detailLabel sizeToFit];

                UISlider *windSpeedSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
                [windSpeedSlider setTag:WIND_SPEED_SLIDER_TAG];
                [windSpeedSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
                [windSpeedSlider setMinimumValue:0];
                [windSpeedSlider setMaximumValue:40];
                [windSpeedSlider setValue:self.weather.windSpeedInMilesPerHour];
                [windSpeedSlider addTarget:self action:@selector(changeWindSpeed:) forControlEvents:UIControlEventValueChanged];
                
                [cell.contentView addSubview:windSpeedSlider];
                [cell.contentView addSubview:self.windDirectionControl];
                [self updateWindDirectionControl:self.windDirectionControl withWindBearing:self.weather.windBearing];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_windDirectionControl]-(>=30)-[windSpeedSlider]-(>=8)-[detailLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_windDirectionControl, windSpeedSlider, detailLabel)]];
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[windSpeedSlider(==100@900)]-(==70@720)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(windSpeedSlider)]];
                
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[_windDirectionControl]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_windDirectionControl)]];
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_windDirectionControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

                
                [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:windSpeedSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
                
                [textLabel setHidden:YES];            
            } else if(!self.editMode) {
                [[cell.contentView viewWithTag:WIND_SPEED_SLIDER_TAG] removeFromSuperview];
                [self.windDirectionControl removeFromSuperview];
                detailLabel.text = [NSString stringWithFormat:@"%.1f mph, %@", self.weather.windSpeedInMilesPerHour, self.weather.windBearingShortString];
                [textLabel setHidden:NO];
            }

        }
    }
    return cell;
}


- (IBAction)enterEditMode:(id)sender {
    self.editMode = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    if([K9Preferences locationPreference] != K9PreferencesLocationAbsoluteDenied) {
        [self.navigationItem setRightBarButtonItems:@[self.doneButton, self.useLocationBarButton] animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItems:@[self.doneButton] animated:YES];
    }

    [self.tableView reloadData];
}

- (IBAction)exitEditMode:(id)sender {
    self.editMode = NO;
    
    [self.delegate weatherViewController:self didUpdateWeather:self.weather];
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.navigationItem setRightBarButtonItems:@[self.editButton] animated:YES];
    
    [self.tableView reloadData];
}

- (IBAction)updateWeatherUsingLocation:(id)sender {
    if([K9Preferences locationPreference] == K9PreferencesLocationAbsoluteAccepted) {
        [self doUpdateWeatherUsingLocation];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Use Current Location?" message:@"FIDO will automatically fill out location and weather information" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        // YES Button
        [self doUpdateWeatherUsingLocation];
    } else {
        // NO Button..
    }
}

- (void)doUpdateWeatherUsingLocation {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager startUpdatingLocation];
    
    self.loadingLocation = YES;
    
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    
    [K9Weather fetchWeatherForLocation:newLocation completionHandler:^(K9Weather *weather) {
        self.weather = weather;
        self.loadingLocation = NO;
        [self.tableView reloadData];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    
    self.loadingLocation = NO;
    [self.tableView reloadData];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [K9Preferences setLocationPreference:K9PreferencesLocationAbsoluteDenied];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        [K9Preferences setLocationPreference:K9PreferencesLocationAbsoluteAccepted];
    }
}

@end

@implementation K9Weather (StringFormats)

- (NSString *)precipitationString {
    switch (self.precipitation) {
        case K9WeatherPrecipitationNone:
            return @"None";
        case K9WeatherPrecipitationHail:
            return @"Hail";
        case K9WeatherPrecipitationRain:
            return @"Rain";
        case K9WeatherPrecipitationSleet:
            return @"Sleet";
        case K9WeatherPrecipitationSnow:
            return @"Snow";
    }
}

- (NSString *)windBearingShortString {
    
    NSString *string = @"";
    
    if(self.windBearing & K9WeatherWindBearingNorth) {
        string = @"N";
    } else if(self.windBearing & K9WeatherWindBearingSouth) {
        string = @"S";
    }
    
    if(self.windBearing & K9WeatherWindBearingWest) {
        string = [string stringByAppendingString:@"W"];
    } else if(self.windBearing & K9WeatherWindBearingEast) {
        string = [string stringByAppendingString:@"E"];
    }
    
    return string;
}

@end