//
//  K9TrainingViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/13/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9TrainingNavigationViewController.h"

@interface K9TrainingNavigationViewController ()

@end

@implementation K9TrainingNavigationViewController

- (UITabBarItem *)tabBarItem {
    UITabBarItem *item = [super tabBarItem];
    item.selectedImage = [UIImage imageNamed:@"Whistle Selected"];
    item.image = [UIImage imageNamed:@"Whistle"];
    return item;
}

@end
