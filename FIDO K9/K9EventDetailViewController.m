//
//  K9EventDetailViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9EventDetailViewController.h"
#import "K9ResourcesCollectionViewController.h"

@interface K9EventDetailViewController ()

@property (strong, nonatomic) K9ResourcesCollectionViewController *resourcesViewController;

@end

@implementation K9EventDetailViewController

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
    self.resourcesViewController = [[self childViewControllers] lastObject];
    self.resourcesViewController.resources = [self.event resources];
}

- (void)setEvent:(K9Event *)event {
    if(_event != event) {
        _event = event;
        self.resourcesViewController.resources = [event resources];
    }
}

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
