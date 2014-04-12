//
//  K9PhotoBrowserCollectionViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9ResourcesCollectionViewController.h"
#import "K9ResourceBrowserViewController.h"
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "K9PhotoViewController.h"
#import "K9Photo.h"

@interface K9ResourcesCollectionViewController () <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

@end

@implementation K9ResourcesCollectionViewController

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
}

- (void)viewWillDisappear:(BOOL)animated {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if([viewControllers indexOfObject:(self.parentViewController.parentViewController)] == NSNotFound) {
        self.navigationController.delegate = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setResources:(NSArray *)resources {
    if(_resources != resources && ![_resources isEqualToArray:resources]) {
        _resources = resources;
        [[self collectionView] reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id resource = [self.resources objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = nil;
    
    if([resource isKindOfClass:[K9Photo class]]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
        [[((K9PhotoCollectionViewCell *)cell) imageView] setImage:[(K9Photo *)resource thumbnail]];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];        
    }
    
    cell.clipsToBounds = YES;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor blackColor].CGColor;

    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationController.delegate = self;
    if([segue.identifier isEqualToString:@"selectPhotoSegue"]) {
        K9ResourceBrowserViewController *destination = segue.destinationViewController;
        [destination setResources:[self resources]];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        [destination setCurrentIndex:indexPath.row];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if([toVC isKindOfClass:[K9ResourceBrowserViewController class]] && operation == UINavigationControllerOperationPush) {
        return self;
    } else if([fromVC isKindOfClass:[K9ResourceBrowserViewController class]] && operation == UINavigationControllerOperationPop) {
        return self;
    } else {
        return nil;
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[K9ResourceBrowserViewController class]]) {
        K9ResourceBrowserViewController *toViewController = (K9ResourceBrowserViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIView *containerView = [transitionContext containerView];
        [[transitionContext containerView] insertSubview:toViewController.view atIndex:0];
        toViewController.view.alpha = 0;

        UIImage *screenshot = [[fromViewController view] screenshot];
        UIImage *finalBackground = [screenshot applyDarkEffect];
        CGFloat y = 64;//[[fromViewController topLayoutGuide] length];
        CGFloat height = fromViewController.view.frame.size.height - y - 49;//[[fromViewController bottomLayoutGuide] length];
        CGFloat width = fromViewController.view.frame.size.width;
        UIImage *mergedImage = [self imageWithImage:finalBackground inRect:CGRectMake(0, y, width, height) borderImage:screenshot];
        toViewController.backgroundImageView.image = mergedImage;

        // TODO: This assumes that it's a photo resource
        UIImage *image = [[self.resources objectAtIndex:toViewController.currentIndex] image];
        CGRect cellFrame = [[[self collectionViewLayout] layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentIndex inSection:0]] frame];
        cellFrame = [[self collectionView] convertRect:cellFrame toView:containerView];
        
        
        K9PhotoViewController *photoVC = [[toViewController childViewControllers] firstObject];
        UIView *view = [[[photoVC scrollView] subviews] firstObject];
        CGRect finalFrame = [view convertRect:[view bounds] toView:containerView];
        finalFrame.origin.y += 14;
        
        UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:cellFrame];
        [transitionImageView setContentMode:UIViewContentModeScaleAspectFill];
        [transitionImageView setClipsToBounds:YES];
        [transitionImageView setImage:image];
        [containerView addSubview:transitionImageView];
        
        [[toViewController backgroundImageView] setFrame:[[transitionContext containerView] bounds]];
        [containerView insertSubview:toViewController.backgroundImageView atIndex:0];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
            fromViewController.view.alpha = 0;
            [transitionImageView setFrame:finalFrame];
        } completion:^(BOOL finished) {
            toViewController.view.alpha = 1;
            fromViewController.view.alpha = 1;
            [transitionImageView removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        K9ResourceBrowserViewController* fromViewController = (K9ResourceBrowserViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

        UIView *containerView = [transitionContext containerView];

        [containerView insertSubview:toViewController.view atIndex:0];
        CGRect frame = toViewController.view.frame;
        toViewController.view.frame = frame;
        toViewController.view.alpha = 0;
        
        
        // TODO: This assumes that it's a photo resource
        UIImage *image = [[self.resources objectAtIndex:fromViewController.currentIndex] image];
        
        K9PhotoViewController *photoVC = [[fromViewController viewControllers] firstObject];
        UIView *view = [[[photoVC scrollView] subviews] firstObject];
        CGRect firstFrame = [view convertRect:[view bounds] toView:containerView];
        
        CGRect finalFrame = [[[self collectionViewLayout] layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:fromViewController.currentIndex inSection:0]] frame];
        finalFrame = [[self collectionView] convertRect:finalFrame toView:containerView];

        UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:firstFrame];
        [transitionImageView setContentMode:UIViewContentModeScaleAspectFill];
        [transitionImageView setClipsToBounds:YES];
        transitionImageView.layer.borderWidth = 0.5;
        transitionImageView.layer.borderColor = [UIColor blackColor].CGColor;
        [transitionImageView setImage:image];
        [containerView addSubview:transitionImageView];

        
        [[fromViewController backgroundImageView] removeFromSuperview];
        [[fromViewController backgroundImageView] setFrame:[[transitionContext containerView] bounds]];
        [[transitionContext containerView] insertSubview:fromViewController.backgroundImageView atIndex:0];

        fromViewController.view.alpha = 0;
        
        UICollectionViewCell *cell = [[self collectionView] cellForItemAtIndexPath:[NSIndexPath indexPathForItem:fromViewController.currentIndex inSection:0]];
        [cell setHidden:YES];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
            toViewController.view.alpha = 1;
            [transitionImageView setFrame:finalFrame];
        } completion:^(BOOL finished) {
            [cell setHidden:NO];
            fromViewController.view.alpha = 1;
            [transitionImageView removeFromSuperview];
            [[fromViewController backgroundImageView] removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

-(UIImage *)imageWithImage:(UIImage *)image inRect:(CGRect)cropRect borderImage:(UIImage *)borderImage{
    UIGraphicsBeginImageContext(borderImage.size);
    [borderImage drawAtPoint:CGPointZero];
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [image drawAtPoint:cropRect.origin];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage *)imageWithImage:(UIImage *)image croppedToRect:(CGRect)cropRect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@end

@implementation K9PhotoCollectionViewCell

@end
