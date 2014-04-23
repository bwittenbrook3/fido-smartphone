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
#import "K9Preferences.h"

#import "K9Event.h"
#import "K9Dog.h"
#import "K9Resource.h"

#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "PTPusher.h"
#import "K9ObjectGraph.h"

@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9EventDetailViewController () <K9DogAvatarViewControllerDelegate, PTPusherDelegate>

@property (strong, nonatomic) K9ResourcesCollectionViewController *resourcesViewController;

@property (weak) IBOutlet UIView *dogAvatarStackView;

@property (weak) IBOutlet UIView *resourceCollectionWrapperView;

@property (weak) IBOutlet UIButton *revealButton;
@property (weak) IBOutlet NSLayoutConstraint *resourceCollectionWrapperViewHeight;

@property BOOL ignoreDrawerToggleForPreferences;

@end


#define OPEN_IMAGE_DRAWER_HEIGHT (75)
#define OPEN_IMAGE_DRAWER_REVEAL_IMAGE (@"Reveal Reverse")
#define CLOSED_IMAGE_DRAWER_HEIGHT (0)
#define CLOSED_IMAGE_DRAWER_REVEAL_IMAGE (@"Reveal")


@implementation K9EventDetailViewController {
    __strong PTPusher *_client;
}

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
    [[self view] bringSubviewToFront:[self revealButton]];
    self.resourcesViewController = [[self childViewControllers] lastObject];
    
    self.resourceCollectionWrapperViewHeight.constant = CLOSED_IMAGE_DRAWER_HEIGHT;
    [self.revealButton setHidden:YES];

    if(self.event) {
        [self reloadEventViews];
        [[NSNotificationCenter defaultCenter] addObserver:self.resourcesViewController selector:@selector(eventDidModifyResources:) name:K9EventDidModifyResourcesNotification object:_event];
    }
}

- (void)setEvent:(K9Event *)event {
    if(_event != event) {
        if(self.resourcesViewController) [[NSNotificationCenter defaultCenter] removeObserver:self.resourcesViewController name:K9EventDidModifyResourcesNotification object:_event];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:K9EventDidModifyResourcesNotification object:_event];
        _event = event;
        if(self.resourcesViewController) [[NSNotificationCenter defaultCenter] addObserver:self.resourcesViewController selector:@selector(eventDidModifyResources:) name:K9EventDidModifyResourcesNotification object:_event];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidModifyResources:) name:K9EventDidModifyResourcesNotification object:_event];
        
        if(self.isViewLoaded) [self reloadEventViews];
        
        
        if(!_client) {
#define PUSHER_API_KEY @"e7b137a34da31bed01d9"
            _client = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
            [_client connect];
            
            [[K9ObjectGraph sharedObjectGraph] fetchEventResourcePusherChannelForEventWithID:event.eventID withCompletionHandler:^(NSString *pusherChannel) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_client subscribeToChannelNamed:pusherChannel];
                    [_client bindToEventNamed:@"sync" handleWithBlock:^(PTPusherEvent *event) {
#define PUSHER_RESOURCE_ID_KEY @"resourceId"
                        NSInteger resourceID = [[event.data objectForKey:PUSHER_RESOURCE_ID_KEY] integerValue];
                        if(![[self.event.resources valueForKey:@"resourceID"] containsObject:@(resourceID)]) {
                            [[K9ObjectGraph sharedObjectGraph] fetchResourcesForEventWithID:self.event.eventID completionHandler:^(NSArray *resources) {
                                [resources enumerateObjectsUsingBlock:^(K9Resource *resource, NSUInteger idx, BOOL *stop) {
                                    if(resource.resourceID == resourceID) {
                                        [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self.event userInfo:@{K9EventAddedResourcesNotificationKey: @[resource]}];
                                    }
                                }];
                            }];
                        }
                    }];
                });
            }];
        }
    }
}

- (void)eventDidModifyResources:(NSNotification *)notification {
    if(self.revealButton.hidden && self.event.resources) {
        self.revealButton.alpha = 0;
        self.revealButton.hidden = NO;
    }
    
    if(self.resourceCollectionWrapperViewHeight.constant == CLOSED_IMAGE_DRAWER_HEIGHT) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.revealButton.alpha = 1.0;
            } completion:^(BOOL finished) {
                self.ignoreDrawerToggleForPreferences = YES;
                [self toggleResourcesDrawer:self];
                self.ignoreDrawerToggleForPreferences = NO;
            }];
        });
    }
}

- (void)reloadEventViews {
    self.resourcesViewController.resources = [self.event resources];
    
    for(UIView *subview in [self.dogAvatarStackView subviews]) {
        [subview removeFromSuperview];
    }
    
    if([K9Preferences eventImageDrawerIsOpen] && self.event.resources.count) {
        self.resourceCollectionWrapperViewHeight.constant = OPEN_IMAGE_DRAWER_HEIGHT;
        [self.revealButton setImage:[UIImage imageNamed:OPEN_IMAGE_DRAWER_REVEAL_IMAGE] forState:UIControlStateNormal];
    } else {
        self.resourceCollectionWrapperViewHeight.constant = CLOSED_IMAGE_DRAWER_HEIGHT;
        [self.revealButton setImage:[UIImage imageNamed:CLOSED_IMAGE_DRAWER_REVEAL_IMAGE] forState:UIControlStateNormal];
    }
    [self.revealButton setHidden:!(self.event.resources.count)];
    
    UIView *previousView = nil;
    for(K9Dog *dog in [self.event assignedDogs]) {
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

- (IBAction)toggleResourcesDrawer:(id)sender {
    BOOL collapsing = (self.resourceCollectionWrapperViewHeight.constant != CLOSED_IMAGE_DRAWER_HEIGHT);
    
    if(!self.ignoreDrawerToggleForPreferences) {
        [K9Preferences setEventImageDrawerIsOpen:!collapsing];
    }
    
    CGFloat finalHeight = collapsing ? CLOSED_IMAGE_DRAWER_HEIGHT : OPEN_IMAGE_DRAWER_HEIGHT;
    UIImage *finalImage = [UIImage imageNamed:(collapsing ? CLOSED_IMAGE_DRAWER_REVEAL_IMAGE : OPEN_IMAGE_DRAWER_REVEAL_IMAGE)];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.resourceCollectionWrapperViewHeight.constant = finalHeight;
        [self.revealButton setImage:finalImage forState:UIControlStateNormal];
        [[[self.view superview] superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
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
