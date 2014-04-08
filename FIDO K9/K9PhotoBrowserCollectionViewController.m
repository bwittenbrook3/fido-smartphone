//
//  K9PhotoBrowserCollectionViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9PhotoBrowserCollectionViewController.h"
#import "K9PhotoBrowserViewController.h"
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "K9PhotoViewController.h"

@interface K9PhotoBrowserCollectionViewController () <UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning>

@end

@implementation K9PhotoBrowserCollectionViewController

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
//    self.collectionView.backgroundView = [UIView new];
//    self.collectionView.backgroundView.backgroundColor = [UIColor clearColor];
//    self.collectionView.backgroundView.opaque = NO;
//    NSLog(@"%@", self.collectionView.backgroundView);
    // Do any additional setup after loading the view.
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


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.navigationController.delegate = self;
    if([segue.identifier isEqualToString:@"selectPhotoSegue"]) {
        K9PhotoBrowserViewController *destination = segue.destinationViewController;
        [destination setPhotos:@[[UIImage imageNamed:@"SamplePhoto"], [UIImage imageNamed:@"SamplePhoto"], [UIImage imageNamed:@"SamplePhoto"], [UIImage imageNamed:@"SamplePhoto"]]];
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        [destination setCurrentIndex:indexPath.row];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if([toVC isKindOfClass:[K9PhotoBrowserViewController class]] && operation == UINavigationControllerOperationPush) {
        return self;
    } else if([fromVC isKindOfClass:[K9PhotoBrowserViewController class]] && operation == UINavigationControllerOperationPop) {
        return self;
    } else {
        return nil;
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[K9PhotoBrowserViewController class]]) {
        K9PhotoBrowserViewController *toViewController = (K9PhotoBrowserViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
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

        UIImage *image = [UIImage imageNamed:@"SamplePhoto"];
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

//        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            fromViewController.view.alpha = 0;
//            [transitionImageView setFrame:finalFrame];
//        } completion:^(BOOL finished) {
//            toViewController.view.alpha = 1;
//            fromViewController.view.alpha = 1;
//            [transitionImageView removeFromSuperview];
//            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        }];
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
        K9PhotoBrowserViewController* fromViewController = (K9PhotoBrowserViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

        UIView *containerView = [transitionContext containerView];

        [containerView insertSubview:toViewController.view atIndex:0];
        CGRect frame = toViewController.view.frame;
        toViewController.view.frame = frame;
        toViewController.view.alpha = 0;
        
        UIImage *image = [UIImage imageNamed:@"SamplePhoto"];
        
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
