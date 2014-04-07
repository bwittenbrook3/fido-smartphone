//
//  K9PhotoBrowserViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9PhotoBrowserViewController.h"
#import "K9PhotoViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIView+Screenshot.h"


@interface UIView (Secret)
@property (readonly) NSString *recursiveDescription;
@end
@interface K9PhotoBrowserViewController ()

@property (strong) NSMutableDictionary *viewControllerToImageIndexDictionary;
@property (strong) NSMutableDictionary *imageIndexToViewControllerDictionary;


@end

@implementation K9PhotoBrowserViewController

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

    self.viewControllerToImageIndexDictionary = [NSMutableDictionary dictionary];
    self.imageIndexToViewControllerDictionary = [NSMutableDictionary dictionary];
    self.delegate = self;
    self.dataSource = self;
    [self setViewControllers:@[[self currentViewController]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}


- (void)viewDidAppear:(BOOL)animated {
//    [self.backgroundImageView removeFromSuperview];
//    [[self backgroundImageView] setFrame:[[[self view] superview] bounds]];
//    [[[self view] superview] insertSubview:self.backgroundImageView atIndex:0];
}

- (void)viewDidDisappear:(BOOL)animated {
    //[[self backgroundImageView] removeFromSuperview];
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    self.viewControllerToImageIndexDictionary = [NSMutableDictionary dictionaryWithCapacity:photos.count];
    self.imageIndexToViewControllerDictionary = [NSMutableDictionary dictionaryWithCapacity:photos.count];
    if(self.isViewLoaded) {
        _currentIndex = 0;
        [self setViewControllers:@[[self currentViewController]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld", (_currentIndex+1), [_photos count]];
}


- (UIViewController *)currentViewController {
    return [self viewControllerAtIndex:_currentIndex];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    K9PhotoViewController *photoViewController = [[self imageIndexToViewControllerDictionary] objectForKey:@(index)];
    if(!photoViewController) {
        photoViewController = [[K9PhotoViewController alloc] initWithNibName:nil bundle:nil];
        photoViewController.image = [[self photos] objectAtIndex:index];
        [[self imageIndexToViewControllerDictionary] setObject:photoViewController forKey:@(index)];
        [[self viewControllerToImageIndexDictionary] setObject:@(index) forKey:[self keyForViewController:photoViewController]];
    }
    return photoViewController;
}

- (id<NSCopying, NSCoding>)keyForViewController:(UIViewController *)viewController {
    return [NSString stringWithFormat:@"%p", viewController];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllerToImageIndexDictionary objectForKey:[self keyForViewController:viewController]] integerValue];
    if(index > 0) {
        return [self viewControllerAtIndex:index - 1];
    } else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [[self.viewControllerToImageIndexDictionary objectForKey:[self keyForViewController:viewController]] integerValue];
    if(index < [[self photos] count] - 1) {
        return [self viewControllerAtIndex:index + 1];
    } else {
        return nil;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.currentIndex = [[[self viewControllerToImageIndexDictionary] objectForKey:[self keyForViewController:[self.viewControllers firstObject]]] integerValue];
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
