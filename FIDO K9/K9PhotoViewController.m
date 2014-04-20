//
//  K9PhotoViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9PhotoViewController.h"
#import "ImageScrollView.h"
#import "UIImageView+AFNetworking+ObjectGraph.h"

@interface K9PhotoViewController ()

@property (strong) NSURL *url;
@end

@implementation K9PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    self.scrollView = scrollView;
    if(self.image) {
        self.scrollView.image = self.image;
    } else if (self.url) {
        NSLog(@"setting from URL");
        [self.scrollView setImageWithURL:self.url];
    }
    self.view = scrollView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if(self.isViewLoaded) {
        self.scrollView.image = self.image;
    }
}

- (void)setImageWithURL:(NSURL *)url {
    if(!self.isViewLoaded) {
        self.url = url;
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectZero];
        [image setImageWithURL:url placeholderImage:nil success:^(UIImage *image) {
            self.image = image;
        } failure:nil];
    } else {
        [self.scrollView setImageWithURL:url];
    }
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
