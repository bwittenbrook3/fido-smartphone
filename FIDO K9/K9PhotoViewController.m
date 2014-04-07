//
//  K9PhotoViewController.m
//  FIDO K9
//
//  Created by Taylor on 4/7/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9PhotoViewController.h"
#import "ImageScrollView.h"

@interface K9PhotoViewController ()

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
