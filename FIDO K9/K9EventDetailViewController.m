//
//  K9EventDetailViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9EventDetailViewController.h"
#import "K9ResourcesCollectionViewController.h"
#import "K9DogAvatarViewController.h"

#import "K9Event.h"
#import "K9Dog.h"

@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9EventDetailViewController () <K9DogAvatarViewControllerDelegate>

@property (strong, nonatomic) K9ResourcesCollectionViewController *resourcesViewController;

@property (weak) IBOutlet UIView *dogAvatarStackView;

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
    
    if(self.event) {
        [self reloadEventViews];
    }
}

- (void)setEvent:(K9Event *)event {
    if(_event != event) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:K9EventDidModifyResourcesNotification object:_event];
        _event = event;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidModifyResources:) name:K9EventDidModifyResourcesNotification object:_event];
        
        if(self.isViewLoaded) [self reloadEventViews];
    }
}

- (void)eventDidModifyResources:(NSNotification *)notification {
    self.resourcesViewController.resources = [[notification object] resources];
    NSLog(@"updating resources");
}

- (void)reloadEventViews {
    self.resourcesViewController.resources = [self.event resources];

    
    for(UIView *subview in [self.dogAvatarStackView subviews]) {
        [subview removeFromSuperview];
    }
    
    UIView *previousView = nil;
    for(K9Dog *dog in [self.event associatedDogs]) {
        K9DogAvatarViewController *avatarVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"avatarVC"];
        [avatarVC setDelegate:self];
        [avatarVC setDog:dog];
        [self addChildViewController:avatarVC];
        UIView *avatarView = [avatarVC view];
        [avatarView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.dogAvatarStackView addSubview:avatarView];
        
        if(previousView) {
            [self.dogAvatarStackView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-[avatarView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView, avatarView)]];
            
        } else {
            [self.dogAvatarStackView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[avatarView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(avatarView)]];
            
        }
        [self.dogAvatarStackView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[avatarView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(avatarView)]];
        previousView = avatarView;
    }
    [self.dogAvatarStackView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView)]];

}

- (void)dogAvatarViewControllerToggledSelected:(K9DogAvatarViewController *)dogAvatarViewController {
    if(dogAvatarViewController.selected) {
        K9DogAvatarViewController *oldSelected = nil;
        for(id childViewController in [self childViewControllers]) {
            if([childViewController isKindOfClass:[K9DogAvatarViewController class]] && childViewController != dogAvatarViewController) {
                [childViewController setSelected:NO];
                oldSelected = childViewController;
            }
        }
        [self.delegate eventDetailViewController:self didFocusOnDog:dogAvatarViewController.dog wasFocusedOnDog:oldSelected.dog];
    }
    
    if(!dogAvatarViewController.selected) {
        BOOL anySelected = NO;
        for(id childViewController in [self childViewControllers]) {
            if([childViewController isKindOfClass:[K9DogAvatarViewController class]] && [childViewController isSelected]) {
                anySelected = YES;
            }
        }
        if(!anySelected) {
            [self.delegate eventDetailViewController:self didFocusOnDog:nil wasFocusedOnDog:dogAvatarViewController.dog];
        }
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
