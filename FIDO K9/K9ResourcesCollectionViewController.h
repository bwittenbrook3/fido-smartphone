//
//  K9PhotoBrowserCollectionViewController.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface K9ResourcesCollectionViewController : UICollectionViewController

@property NSArray *resources;

@end


@interface K9PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic) IBOutlet UIImageView *imageView;

@end