//
//  K9DogAvatarViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class K9Dog, K9CircularBorderImageView;
@protocol K9DogAvatarViewControllerDelegate;

@interface K9DogAvatarViewController : UIViewController


@property (weak) id<K9DogAvatarViewControllerDelegate> delegate;

@property (weak) IBOutlet K9CircularBorderImageView *avatarImageView;
@property (weak) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) K9Dog *dog;

@property (getter = isSelected) BOOL selected;

@end

@protocol K9DogAvatarViewControllerDelegate <NSObject>

@required
- (void)dogAvatarViewControllerToggledSelected:(K9DogAvatarViewController *)dogAvatarViewController;

@end