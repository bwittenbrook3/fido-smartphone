//
//  K9DogViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9DogViewController.h"
#import "K9DogDetailViewController.h"
#import "K9Dog.h"
#import "Forecastr+CLLocation.h"
#import "UIView+Screenshot.h"
#import "K9CircularBorderImageView.h"

#import <MapKit/MapKit.h>

#define COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define COLOR_PART_BLUE(color)   ( (color)        & 0xff)


@interface UIImage (Additions)
- (UIImage *)replaceBlueWithColor:(UIColor *)newColor;
@end

#define DEFAULT_ZOOM_LEVEL 600

@interface K9DogViewController () <UIActionSheetDelegate>

@property (strong) IBOutlet UIView *detailContainerView;
@property (strong) NSLayoutConstraint *heightConstraint;
@property (strong) K9DogDetailViewController *detailsViewController;
@property (strong) UIDynamicAnimator *animator;


@property (weak) IBOutlet UINavigationBar *subheaderBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *infoBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
- (IBAction)showInfo:(id)sender;
- (IBAction)closeInfo:(id)sender;

@end

@interface UIButton (ColorForState)

- (void)setColor:(UIColor *)color forState:(UIControlState)state;

@end

@interface K9Dog (K9DogAnnotation) <MKAnnotation>

@end

@implementation K9DogViewController {
    BOOL _showingDetails;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self view] bringSubviewToFront:[self subheaderBar]];
    [[self subheaderBar] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Add the detail content to our subheader bar
    self.detailsViewController = [[self childViewControllers] objectAtIndex:0];
    self.detailsViewController.dog = self.dog;
    UIView *detailsView = [self detailContainerView];
    [[self subheaderBar] addSubview:detailsView];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    [[self subheaderBar] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[detailsView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView)]];
    
    // Add the initial height constraint for our subheader bar
    UIView *statusLabel = [[self detailsViewController] statusLabel];
    CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
    CGFloat initialHeight = labelRect.origin.y*2 + labelRect.size.height;
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:[self subheaderBar] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:0 constant:initialHeight];
    [[self subheaderBar] addConstraint:[self heightConstraint]];
    
    [[self subheaderBar] setClipsToBounds:YES];
    
    if(self.dog) {
        [self updateDogViews];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    if(!_showingDetails) {
        UIView *detailsView = [[self detailsViewController] view];
        UIView *statusLabel = [[self detailsViewController] statusLabel];
        CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
        CGFloat initialHeight = labelRect.origin.y*2 + labelRect.size.height;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.heightConstraint.constant = initialHeight;
            [[self view] layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)setDog:(K9Dog *)dog {
    if(_dog != dog) {
        if(_dog) [self.mapView removeAnnotation:_dog];
        _dog = dog;
        if(self.isViewLoaded) [self updateDogViews];
    }
}

- (void)updateDogViews {
    [[self detailsViewController] setDog:self.dog];
    [self.navigationItem setTitle:[self.dog name]];
    
    [self.mapView setRegion:[self.mapView regionThatFits:MKCoordinateRegionMakeWithDistance([[self.dog lastKnownLocation] coordinate], DEFAULT_ZOOM_LEVEL, DEFAULT_ZOOM_LEVEL)]];
    [self.mapView addAnnotation:self.dog];
}

- (IBAction)showInfo:(id)sender {
    _showingDetails = YES;
    [self.navigationItem setRightBarButtonItem:self.doneBarButtonItem animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    CGFloat finalHeight = self.view.window.frame.size.height - self.subheaderBar.frame.origin.y;
    
    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [[self heightConstraint] setConstant:finalHeight];
        [self hideTabBar:self.tabBarController];
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)closeInfo:(id)sender {
    _showingDetails = NO;
    [self.navigationItem setRightBarButtonItem:self.infoBarButtonItem animated:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    UIView *detailsView = [[self detailsViewController] view];
    UIView *statusLabel = [[self detailsViewController] statusLabel];
    CGRect labelRect = [statusLabel convertRect:[statusLabel bounds] toView:detailsView];
    CGFloat finalHeight = labelRect.origin.y*2 + labelRect.size.height;

    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        [[self heightConstraint] setConstant:finalHeight];
        [self showTabBar:self.tabBarController];
        [[self view] layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    // Bounce the label towards the end of the animation, since constraints fail at doing this...
    [self performSelector:@selector(doLabelPush) withObject:nil afterDelay:0.29];
}

- (void)doLabelPush {
    UILabel *label = self.detailsViewController.statusLabel;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:label.superview];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[label] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.magnitude = 0.006f;
    pushBehavior.pushDirection = CGVectorMake(0.0f, -1.0f);
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[label]];
    itemBehaviour.elasticity = 0.4;
    itemBehaviour.resistance = 2;
    itemBehaviour.density = 5;
    itemBehaviour.allowsRotation = NO;
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[label]];
    gravity.magnitude = 1.4f;
    UICollisionBehavior *bounds = [[UICollisionBehavior alloc] initWithItems:@[label]];
    bounds.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:itemBehaviour];
    [self.animator addBehavior:gravity];
    [self.animator addBehavior:bounds];
    [self.animator addBehavior:pushBehavior];
    
    [self performSelector:@selector(removeLabelPush) withObject:nil afterDelay:0.5];
}

- (void)removeLabelPush {
    [self.animator removeAllBehaviors];
    self.animator = nil;
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller{
    [UIView beginAnimations:nil context:NULL];
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, tabbarcontroller.view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tabbarcontroller.view.frame.size.height)];
        }
    }
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller {
    [UIView beginAnimations:nil context:NULL];
    for(UIView *view in tabbarcontroller.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            [view setFrame:CGRectMake(view.frame.origin.x, tabbarcontroller.view.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        } else {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, tabbarcontroller.view.frame.size.height - tabbarcontroller.tabBar.frame.size.height)];
        }
    }
    [UIView commitAnimations];
}

#define ANNOTATION_VIEW_ID (@"MKPinAnnotationView")
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*) [self.mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_VIEW_ID];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_VIEW_ID];
    }
    
    annotationView.leftCalloutAccessoryView = [self newDirectionsCalloutView];
    annotationView.canShowCallout = YES;
    
    __block K9CircularBorderImageView *dogProfile = [[K9CircularBorderImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    dogProfile.backgroundColor = [UIColor clearColor];
    dogProfile.opaque = NO;
    
    __weak typeof(dogProfile) weakDogProfile = dogProfile;
    [dogProfile setImageWithURL:self.dog.imageURL placeholderImage:[K9Dog defaultDogImage] completion:^{
        UIImage *dogProfileImage = [weakDogProfile screenshot];
        annotationView.image = dogProfileImage; //[[UIImage imageNamed:@"Paw"] replaceBlueWithColor:self.dog.color];
    }];
    dogProfile.borderColor = self.dog.color;
    dogProfile.borderWidth = 1;
    
    
    annotationView.calloutOffset = CGPointMake(0, 0);
    
    return annotationView;
}


- (void)updateButtonColor:(id)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.6 alpha:1.0]];
}

- (void)releaseButtonColor:(id)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1.0 alpha:1.0]];
}

- (void)getDirections:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Maps App", @"Google Glass", nil];
    [sheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [self removeMapParallaxEffect];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    K9MapDirectionsMethod directionsMethod = (buttonIndex == 0 ? K9MapDirectionsMethodMapsApp : K9MapDirectionsMethodGoogleGlass);
    [self sendDirectionsTo:directionsMethod withLocation:self.dog.lastKnownLocation destinationName:self.dog.name];
    
    [self addMapParallaxEffect];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    UIColor *textColor = [[[[UIApplication sharedApplication] windows] firstObject] tintColor];
    UIColor *backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:150.0];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            
            for(UIView *buttonSubview in subview.subviews) {
                if (![buttonSubview isKindOfClass:[UILabel class]]) {
                    [buttonSubview setHidden:YES];
                }
            }
            
            UIButton *button = (UIButton *)subview;
            [button setColor:backgroundColor forState:UIControlStateNormal];
            [button setClipsToBounds:YES];
            CGRect frame = [button frame];
            frame.size.width -= 10;
            frame.origin.x += 5;
            frame.origin.y -= 1;
            frame.size.height += 2;
            [button setFrame:frame];
            
            
            UIRectCorner corners = 0;
            if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:0]]) {
                corners = UIRectCornerTopLeft | UIRectCornerTopRight;
            } else if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:([actionSheet numberOfButtons]-2)]]) {
                corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            } else if([[button titleForState:UIControlStateNormal] isEqualToString:[actionSheet buttonTitleAtIndex:[actionSheet cancelButtonIndex]]]) {
                corners = (UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft | UIRectCornerTopRight);
            }
            
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(4.0, 4.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
            
            
            [button setTitleColor:textColor forState:UIControlStateNormal];
        }
    }
}

@end

@implementation K9Dog (K9DogAnnotation)

- (CLLocationCoordinate2D)coordinate {
    return self.lastKnownLocation.coordinate;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.status;
}

@end

@implementation UIImage (Additions)
- (UIImage *)replaceBlueWithColor:(UIColor *)newColor{
    CGImageRef imageRef = [self CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef newCgColor = [newColor CGColor];
    const CGFloat *newComponents = CGColorGetComponents(newCgColor);
    float newRed = newComponents[0] * 255.0;
    float newGreen = newComponents[1] * 255.0;
    float newBlue = newComponents[2] * 255.0;

    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char blue  = rawData[byteIndex + 2];
        unsigned char alpha  = rawData[byteIndex + 3];
        
        float blueDiff = (blue - red)/255.0;
        
        rawData[byteIndex] = red + blueDiff*newRed;
        rawData[byteIndex + 1] = red + blueDiff*newGreen;
        rawData[byteIndex + 2] = red + blueDiff*newBlue;
        rawData[byteIndex + 3] = alpha;

        byteIndex += 4;
    }
    
    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context) scale:[self scale] orientation:UIImageOrientationUp];
    
    CGContextRelease(context);
    free(rawData);
    
    return result;
}
@end
