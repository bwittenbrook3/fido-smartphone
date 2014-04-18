//
//  K9NavigationReplaceSegue.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9NavigationReplaceSegue.h"

@implementation K9NavigationReplaceSegue

- (void)perform {
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    NSInteger index = [navigationController.viewControllers indexOfObject:sourceViewController];
    
    if(index == 0) {
        [navigationController setViewControllers:@[destinationController] animated:YES];
    } else {
        [navigationController popToViewController:navigationController.viewControllers[index-1] animated:NO];
        [navigationController pushViewController:destinationController animated:YES];
    }
}

@end
