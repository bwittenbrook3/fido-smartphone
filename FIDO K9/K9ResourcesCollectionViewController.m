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
#import "UIImageView+AFNetworking+ObjectGraph.h"
#import "DAProgressOverlayView.h"
#import "K9Event.h"
#import "K9OverlayViewController.h"
#import "K9MapAnnotation.h"
#import "K9MapAnnotation+AnnotationSnapshot.h"


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

- (void)eventDidModifyResources:(NSNotification *)notification {
    NSArray *resources = [[notification userInfo] objectForKey:K9EventAddedResourcesNotificationKey];
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:resources.count];
    
    [resources enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_resources.count + idx inSection:0];
        [indexPaths addObject:indexPath];
        
        if([obj isKindOfClass:[K9MapAnnotation class]]) {
            K9OverlayViewController *overlayVC = [[K9OverlayViewController alloc] init];
            [overlayVC.view setFrame:self.view.window.frame];
            [overlayVC setMapAnnotation:obj];
            [overlayVC snapshotOverlayView:^(UIImage *snapshot) {
                [obj setMapAnnotationSnapshot:snapshot];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
        }
    }];
    
    if(!_resources) {
        _resources = [resources copy];
    } else {
        _resources = [_resources arrayByAddingObjectsFromArray:resources];
    }
    
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
    
    [self.collectionView scrollToItemAtIndexPath:[indexPaths lastObject] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id resource = [self.resources objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    if([resource isKindOfClass:[K9Photo class]]) {
        [[((K9PhotoCollectionViewCell *)cell) imageView] setImageWithURL:[resource URL] placeholderImage:nil success:^(UIImage *image) {
            [[((K9PhotoCollectionViewCell *)cell) imageView] setImage:image];
        } failure:nil];
    } else if([resource isKindOfClass:[K9MapAnnotation class]]) {
        if(![resource mapAnnotationSnapshot]) {
            [[((K9PhotoCollectionViewCell *)cell) imageView] setImage:nil];
        } else {
            [[((K9PhotoCollectionViewCell *)cell) imageView] setImage:[resource mapAnnotationSnapshot]];
        }
    }
    
    cell.clipsToBounds = YES;
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor grayColor].CGColor;

    if(![resource isUploaded] ) {
        DAProgressOverlayView *progressOverlay = [[DAProgressOverlayView alloc] initWithFrame:cell.contentView.bounds];
        [progressOverlay setTriggersDownloadDidFinishAnimationAutomatically:YES];
        [cell.contentView addSubview:progressOverlay];
        
        // TODO: Put this somewhere better?
        [[NSNotificationCenter defaultCenter] addObserverForName:@"progress" object:resource queue:nil usingBlock:^(NSNotification *note) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressOverlay setProgress:[[[note userInfo] objectForKey:@"progress"] floatValue]];
                if(progressOverlay.progress ) {
                    [progressOverlay performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.5];
                }
            });
        }];
    }
    
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
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if([[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[K9ResourceBrowserViewController class]]) {
        K9ResourceBrowserViewController *toViewController = (K9ResourceBrowserViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIView *containerView = [transitionContext containerView];
        [[transitionContext containerView] insertSubview:toViewController.view atIndex:0];
        toViewController.view.alpha = 0;

        UIImage *screenshot = [[fromViewController view] screenshot];
        UIImage *finalBackground = [screenshot applyLightEffect];
        CGFloat y = 64;//[[fromViewController topLayoutGuide] length];
        
        CGRect tabBarRect = CGRectIntersection([[fromViewController.tabBarController view] bounds], [[fromViewController.tabBarController tabBar] frame]);
        
        if(tabBarRect.size.height == 0) {
            toViewController.edgesForExtendedLayout = UIRectEdgeBottom;
            toViewController.extendedLayoutIncludesOpaqueBars = NO;
            toViewController.automaticallyAdjustsScrollViewInsets=YES;
            CGRect frame = [[toViewController view] frame];
            frame.size.height += [[fromViewController.tabBarController tabBar] frame].size.height;
            [[toViewController view] setFrame:frame];
        } else {
            toViewController.edgesForExtendedLayout = 0;
        }
        
        CGFloat height = fromViewController.view.frame.size.height - y - tabBarRect.size.height;
        CGFloat width = fromViewController.view.frame.size.width;
        UIImage *mergedImage = [self imageWithImage:finalBackground inRect:CGRectMake(0, y, width, height) borderImage:screenshot];
        toViewController.backgroundImageView.image = mergedImage;

        // TODO: This assumes that it's a photo resource
        NSURL *imageURL = nil;
        if([[self.resources objectAtIndex:toViewController.currentIndex] isKindOfClass:[K9Photo class]]) {
            imageURL = [[self.resources objectAtIndex:toViewController.currentIndex] URL];
        }
        
        CGRect cellFrame = [[[self collectionViewLayout] layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentIndex inSection:0]] frame];
        cellFrame = [[self collectionView] convertRect:cellFrame toView:containerView];
        
        CGRect finalFrame = CGRectZero;
        if([[self.resources objectAtIndex:toViewController.currentIndex] isKindOfClass:[K9Photo class]]) {
            K9PhotoViewController *photoVC = [[toViewController viewControllers] firstObject];
            UIView *view = [[[photoVC scrollView] subviews] firstObject];
            // Make sure it's actually laid out before getting its frame
            [[toViewController view] layoutIfNeeded];
            finalFrame = [view convertRect:[view bounds] toView:containerView];
        } else {
            K9OverlayViewController *overlayVC = [[toViewController viewControllers] firstObject];
            UIView *view = [overlayVC view];
            finalFrame = [view convertRect:[view bounds] toView:containerView];
        }
        
        UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:cellFrame];
        [transitionImageView setContentMode:UIViewContentModeScaleAspectFill];
        [transitionImageView setClipsToBounds:YES];
        if([[self.resources objectAtIndex:toViewController.currentIndex] isKindOfClass:[K9Photo class]]) {
            __weak typeof(transitionImageView) weakTransitionImageView = transitionImageView;
            [transitionImageView setImageWithURL:imageURL placeholderImage:nil success:^(UIImage *image) {
                [weakTransitionImageView setImage:image];
            } failure:nil];
        } else {
            [transitionImageView setImage:[[self.resources objectAtIndex:toViewController.currentIndex] mapAnnotationSnapshot]];
        }
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
        
        CGRect firstFrame = CGRectZero;

        NSURL *imageURL = nil;
        if([[self.resources objectAtIndex:fromViewController.currentIndex] isKindOfClass:[K9Photo class]]) {
            imageURL = [[self.resources objectAtIndex:fromViewController.currentIndex] URL];
            
            K9PhotoViewController *photoVC = [[fromViewController viewControllers] firstObject];
            UIView *view = [[[photoVC scrollView] subviews] firstObject];
            firstFrame = [view convertRect:[view bounds] toView:containerView];
        } else {
            K9OverlayViewController *overlayVC = [[fromViewController viewControllers] firstObject];
            UIView *view = [overlayVC view];
            firstFrame = [view convertRect:[view bounds] toView:containerView];
        }
        
        CGRect finalFrame = [[[self collectionViewLayout] layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:fromViewController.currentIndex inSection:0]] frame];
        finalFrame = [[self collectionView] convertRect:finalFrame toView:containerView];

        UIImageView *transitionImageView = [[UIImageView alloc] initWithFrame:firstFrame];
        [transitionImageView setContentMode:UIViewContentModeScaleAspectFill];
        [transitionImageView setClipsToBounds:YES];
        transitionImageView.layer.borderWidth = 0.5;
        transitionImageView.layer.borderColor = [UIColor grayColor].CGColor;
        
        if([[self.resources objectAtIndex:fromViewController.currentIndex] isKindOfClass:[K9Photo class]]) {
            __weak typeof(transitionImageView) weakTransitionImageView = transitionImageView;
            [transitionImageView setImageWithURL:imageURL placeholderImage:nil success:^(UIImage *image) {
                [weakTransitionImageView setImage:image];
            } failure:nil];
        } else {
            [transitionImageView setImage:[[self.resources objectAtIndex:fromViewController.currentIndex] mapAnnotationSnapshot]];
        }
        
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
    CGFloat scaleFactor =  image.scale;
    CGRect captureRect = CGRectMake(scaleFactor * cropRect.origin.x, scaleFactor * cropRect.origin.y, scaleFactor * cropRect.size.width, scaleFactor * cropRect.size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], captureRect);
    image = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    [image drawAtPoint:cropRect.origin];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage *)imageWithImage:(UIImage *)image croppedToRect:(CGRect)cropRect {
    CGFloat scaleFactor =  image.scale;
    CGRect captureRect = CGRectMake(scaleFactor * cropRect.origin.x, scaleFactor * cropRect.origin.y, scaleFactor * cropRect.size.width, scaleFactor * cropRect.size.height);

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], captureRect);
    image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@end

@implementation K9PhotoCollectionViewCell

@end


