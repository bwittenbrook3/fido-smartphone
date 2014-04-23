//
//  K9EventDetailViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9Dog, K9Event;
@protocol K9EventDetailViewControllerDelegate;

@interface K9EventDetailViewController : UIViewController

@property (weak) id<K9EventDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) K9Event *event;

@end

@protocol K9EventDetailViewControllerDelegate <NSObject>

- (void)eventDetailViewController:(K9EventDetailViewController *)eventDetail didFocusOnDog:(K9Dog *)dog wasFocusedOnDog:(K9Dog *)oldDog;

@end