//
//  K9K9NavigationViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogNavigationViewController.h"

@interface K9DogNavigationViewController ()

@end

@implementation K9DogNavigationViewController

- (UITabBarItem *)tabBarItem {
    UITabBarItem *item = [super tabBarItem];
    item.selectedImage = [UIImage imageNamed:@"K9s Tab Bar Selected Template"];
    item.image = [UIImage imageNamed:@"K9s Tab Bar Unselected Template"];
    return item;
}

@end
