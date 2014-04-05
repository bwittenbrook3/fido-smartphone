//
//  K9DogViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogViewController.h"
#import "K9DogDetailViewController.h"

@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9DogViewController ()

@property (strong) NSLayoutConstraint *heightConstraint;
@property (strong) K9DogDetailViewController *detailsViewController;


@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
- (IBAction)showInfo:(id)sender;
- (IBAction)closeInfo:(id)sender;

@end

@implementation K9DogViewController

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
    
    [[self subheaderBar] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self subheaderBar] setClipsToBounds:YES];

    self.detailsViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"k9Details"];
    UIView *details = [[self detailsViewController] view];
    
    [[self subheaderBar] addSubview:details];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[details]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(details)]];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[details]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(details)]];
    
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:[self subheaderBar] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:30];
    [[self subheaderBar] addConstraint:[self heightConstraint]];
    
    
    
    
    NSLog(@"%@", [self.view recursiveDescription]);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)showInfo:(id)sender {
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    CGFloat finalHeight = self.view.window.frame.size.height - self.topLayoutGuide.length;
    
    
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [[self heightConstraint] setConstant:finalHeight];
        [self hideTabBar:self.tabBarController];
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)closeInfo:(id)sender {
    [self.navigationItem setRightBarButtonItem:self.infoBarButtonItem animated:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [[self heightConstraint] setConstant:30];
        [self showTabBar:self.tabBarController];
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller{
    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, tabbarcontroller.view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tabbarcontroller.view.frame.size.height)];
        }
    }
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller {
    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, tabbarcontroller.view.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tabbarcontroller.view.frame.size.height - tabbarcontroller.tabBar.frame.size.height)];
        }
    }
    [UIView commitAnimations];
}
    
@end
