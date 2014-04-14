//
//  K9TrainingViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9TrainingViewController.h"

@interface K9TrainingViewController ()

@end

@implementation K9TrainingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITabBarItem *)tabBarItem {
    UITabBarItem *item = [super tabBarItem];
    item.selectedImage = [UIImage imageNamed:@"Whistle Selected"];
    item.image = [UIImage imageNamed:@"Whistle"];
    return item;
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
