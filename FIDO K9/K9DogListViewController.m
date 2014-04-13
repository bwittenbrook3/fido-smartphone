//
//  K9K9ListViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogListViewController.h"
#import "K9Dog.h"
#import "K9ObjectGraph.h"

#import "K9DogViewController.h"


@interface K9DogListViewController ()
@property (copy) NSArray *dogs;
@end

static inline NSArray *sortDogs(NSArray *dogs) {
    return [dogs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] compare:[obj2 name]];
    }];
}

@implementation K9DogListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setClearsSelectionOnViewWillAppear:YES];
    
    
    self.dogs = sortDogs([[K9ObjectGraph sharedObjectGraph] fetchAllDogsWithCompletionHandler:^(NSArray *dogs) {
        self.dogs = sortDogs(dogs);
        [[self tableView] reloadData];
    }]);
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dogs] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    K9DogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DogCell" forIndexPath:indexPath];
    [[cell dogNameView] setText:[(K9Dog *)[[self dogs] objectAtIndex:indexPath.row] name]];
    [[cell dogProfileView] setImage:[(K9Dog *)[[self dogs] objectAtIndex:indexPath.row] image]];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"selectedDogSegue"]) {
        K9DogViewController *destination = [segue destinationViewController];
        [destination setDog:[self.dogs objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end

@implementation K9DogTableViewCell
@end
