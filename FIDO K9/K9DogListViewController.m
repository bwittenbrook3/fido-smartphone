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

@implementation K9DogListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setClearsSelectionOnViewWillAppear:YES];
    
    self.dogs = [[K9ObjectGraph sharedObjectGraph] allDogs];
    
    [[K9ObjectGraph sharedObjectGraph] fetchAllDogsWithCompletionHandler:^(NSArray *dogs) {
        self.dogs = dogs;
        [[self tableView] reloadData];
    }];
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
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    K9DogViewController *destination = [segue destinationViewController];
    [destination setDog:[self.dogs objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end

@implementation K9DogTableViewCell
@end
