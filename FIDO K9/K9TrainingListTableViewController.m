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

@interface K9TrainingListTableViewController ()

@end

@implementation K9TrainingListTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trainings = @[[K9Training sampleTraining], [K9Training sampleTraining]];
    
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
}

@end
