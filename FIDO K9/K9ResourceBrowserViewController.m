//
//  K9PhotoBrowserViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9ResourceBrowserViewController.h"
#import "K9PhotoViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIView+Screenshot.h"
#import "K9Photo.h"


@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9ResourceBrowserViewController ()

@property (strong) NSMutableDictionary *viewControllerToResourceIndexDictionary;
@property (strong) NSMutableDictionary *resourceIndexToViewControllerDictionary;


@end

@implementation K9ResourceBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:[[self view] bounds]];

    self.viewControllerToResourceIndexDictionary = [NSMutableDictionary dictionary];
    self.resourceIndexToViewControllerDictionary = [NSMutableDictionary dictionary];
    self.delegate = self;
    self.dataSource = self;
    [self setViewControllers:@[[self currentViewController]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)setResources:(NSArray *)photos {
    _resources = photos;
    self.viewControllerToResourceIndexDictionary = [NSMutableDictionary dictionaryWithCapacity:photos.count];
    self.resourceIndexToViewControllerDictionary = [NSMutableDictionary dictionaryWithCapacity:photos.count];
    if(self.isViewLoaded) {
        _currentIndex = 0;
        [self setViewControllers:@[[self currentViewController]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", (_currentIndex+1), [_resources count]];
}

- (UIViewController *)currentViewController {
    return [self viewControllerAtIndex:_currentIndex];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = [[self resourceIndexToViewControllerDictionary] objectForKey:@(index)];
    if(!viewController) {
        id resource = [[self resources] objectAtIndex:index];
        
        if([resource isKindOfClass:[K9Photo class]]) {
            viewController = [[K9PhotoViewController alloc] initWithNibName:nil bundle:nil];
            [(K9PhotoViewController *)viewController setImage:[resource image]];
        }
        [[self resourceIndexToViewControllerDictionary] setObject:viewController forKey:@(index)];
        [[self viewControllerToResourceIndexDictionary] setObject:@(index) forKey:[self keyForViewController:viewController]];
    }
    return viewController;
}

- (id<NSCopying, NSCoding>)keyForViewController:(UIViewController *)viewController {
    return [NSString stringWithFormat:@"%p", viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllerToResourceIndexDictionary objectForKey:[self keyForViewController:viewController]] integerValue];
    if(index > 0) {
        return [self viewControllerAtIndex:index - 1];
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllerToResourceIndexDictionary objectForKey:[self keyForViewController:viewController]] integerValue];
    if(index < [[self resources] count] - 1) {
        return [self viewControllerAtIndex:index + 1];
    } else {
        return nil;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.currentIndex = [[[self viewControllerToResourceIndexDictionary] objectForKey:[self keyForViewController:[self.viewControllers firstObject]]] integerValue];
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
