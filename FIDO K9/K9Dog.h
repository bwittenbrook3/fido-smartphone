//
//  K9Dog.h
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9Dog : NSObject

@property (nonatomic) NSInteger dogID;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSArray *events;

@end
