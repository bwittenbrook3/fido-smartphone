//
//  K9DogViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogViewController.h"
#import "K9DogDetailViewController.h"
#import "K9Dog.h"

@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9DogViewController ()

@property (strong) NSLayoutConstraint *heightConstraint;
@property (strong) K9DogDetailViewController *detailsViewController;
@property (strong) UIDynamicAnimator *animator;


@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
- (IBAction)showInfo:(id)sender;
- (IBAction)closeInfo:(id)sender;

@end

@implementation K9DogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self subheaderBar] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add the detail content to our subheader bar
    self.detailsViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"k9Details"];
    [self addChildViewController:[self detailsViewController]];
    [[self detailsViewController] setDog:[self dog]];
    UIView *detailsView = [[self detailsViewController] view];
    [[self subheaderBar] addSubview:detailsView];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    
    // Add the initial height constraint for our subheader bar
    UIView *statusLabel = [[self detailsViewController] statusLabel];
    CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
    CGFloat initialHeight = labelRect.origin.y*2 + labelRect.size.height;
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:[self subheaderBar] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:initialHeight];
    [[self subheaderBar] addConstraint:[self heightConstraint]];
    
    [[self subheaderBar] setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    UIView *detailsView = [[self detailsViewController] view];
    UIView *statusLabel = [[self detailsViewController] statusLabel];
    CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
    CGFloat initialHeight = labelRect.origin.y*2 + labelRect.size.height;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.heightConstraint.constant = initialHeight;
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)setDog:(K9Dog *)dog {
    _dog = dog;
    [[self detailsViewController] setDog:dog];
    [self.navigationItem setTitle:[dog name]];
}

- (IBAction)showInfo:(id)sender {
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    CGFloat finalHeight = self.view.window.frame.size.height - self.subheaderBar.frame.origin.y;
    
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
    
    UIView *detailsView = [[self detailsViewController] view];
    UIView *statusLabel = [[self detailsViewController] statusLabel];
    CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
    CGFloat finalHeight = labelRect.origin.y*2 + labelRect.size.height;

    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [[self heightConstraint] setConstant:finalHeight];
        [self showTabBar:self.tabBarController];
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    // Bounce the label towards the end of the animation, since constraints fail at doing this...
    [self performSelector:@selector(doLabelPush) withObject:nil afterDelay:0.29];
}

- (void)doLabelPush {
    UILabel *label = self.detailsViewController.statusLabel;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:label.superview];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[label] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.magnitude = 0.001f;
    pushBehavior.pushDirection = CGVectorMake(0.0f, -1.0f);
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[label]];
    itemBehaviour.elasticity = 0.4;
    itemBehaviour.resistance = 2;
    itemBehaviour.density = 5;
    itemBehaviour.allowsRotation = NO;
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[label]];
    gravity.magnitude = 1.4f;
    UICollisionBehavior *bounds = [[UICollisionBehavior alloc] initWithItems:@[label]];
    bounds.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:itemBehaviour];
    [self.animator addBehavior:gravity];
    [self.animator addBehavior:bounds];
    [self.animator addBehavior:pushBehavior];
    
    [self performSelector:@selector(removeLabelPush) withObject:nil afterDelay:0.5];
}

- (void)removeLabelPush {
    [self.animator removeAllBehaviors];
    self.animator = nil;
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller{
    [UIView beginAnimations:nil context:NULL];
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
