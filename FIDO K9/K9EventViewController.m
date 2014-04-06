//
//  K9EventViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/5/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9EventViewController.h"
#import "K9Event.h"

@interface K9EventViewController ()

@end

@implementation K9EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)setEvent:(K9Event *)event {
    self.navigationItem.title = [event title];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
