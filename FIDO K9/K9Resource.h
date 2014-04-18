//
//  K9Resource.h
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9Resource : NSObject

+ (K9Resource *)resourceWithPropertyList:(id)propertyList;

@property (copy, nonatomic) NSURL *URL;

@end
