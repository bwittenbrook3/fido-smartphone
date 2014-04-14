//
//  K9DogAvatarViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogAvatarViewController.h"
#import "K9CircularBorderImageView.h"
#import "K9Dog.h"


@interface K9DogAvatarViewController ()

@property (strong) NSArray *bottomConstraints;

@end

@implementation K9DogAvatarViewController

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
    [[self view] addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [bottomConstraint setPriority:250];
    [[self view] addConstraint:bottomConstraint];
    if(self.dog) [self reloadDogViews];
}

- (void)setDog:(K9Dog *)dog {
    if(_dog != dog) {
        _dog = dog;
        if(self.isViewLoaded) [self reloadDogViews];
    }
}

- (void)reloadDogViews {
    self.nameLabel.text = self.dog.name;
    self.avatarImageView.image = self.dog.image;
    self.avatarImageView.borderColor = self.dog.color;
    self.avatarImageView.borderWidth = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelected:(BOOL)selected {
    if(_selected != selected ){
        _selected = selected;
        [[self delegate] dogAvatarViewControllerToggledSelected:self];

        if(self.bottomConstraints) {
            [[self view] removeConstraints:self.bottomConstraints];
            self.bottomConstraints = nil;
        } else {
            NSMutableArray *constraints = [NSMutableArray array];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self view] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            [constraints addObject:bottomConstraint];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_nameLabel]-(>=0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nameLabel)]];
            
            [[self view] addConstraints:constraints];
            self.bottomConstraints = constraints;
        }
        
        UIView *highestView = [self view];
        while([highestView superview]) {
            highestView = [highestView superview];
        }
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [highestView layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];

    }
}

- (IBAction)userDidTap {
    self.selected = !self.selected;
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
