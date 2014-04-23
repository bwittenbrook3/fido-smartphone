//
//  K9TrainingListTableViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9TrainingListTableViewController.h"
#import "K9Training.h"
#import "K9Dog.h"
#import "K9TrainingDetailViewController.h"
#import "K9ObjectGraph.h"

@interface K9TrainingListTableViewController ()

@end


static inline NSArray *sortTraining(NSArray *events) {
    return [events sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 startTime] compare:[obj1 startTime]];
    }];
}

@implementation K9TrainingListTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if(!self.trainings) {
        self.trainings = sortTraining([[K9ObjectGraph sharedObjectGraph] allTraining]);

        [[NSNotificationCenter defaultCenter] addObserverForName:K9TrainingWasAddedNotification object:[K9ObjectGraph sharedObjectGraph] queue:nil usingBlock:^(NSNotification *note) {
            self.trainings = sortTraining([[K9ObjectGraph sharedObjectGraph] allTraining]);
            [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.trainings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trainingTableCell" forIndexPath:indexPath];
    
    K9Training *training = [self.trainings objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d @ hh:mm"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ Training", training.trainedDog.name];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:training.startTime];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"trainingSegue"]) {
        K9TrainingDetailViewController *destination = [segue destinationViewController];
        K9Training *training = [self.trainings objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        [destination setTraining:training];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

@end
