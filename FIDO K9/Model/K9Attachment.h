//
//  K9Attachment.h
//  FIDO K9
//
//  Created by Taylor on 4/12/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface K9Attachment : NSObject

+ (K9Attachment *)attachmentWithPropertyList:(NSDictionary *)propertyList;

@property (nonatomic) NSInteger attachmentID;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *attachmentDescription;
@property (copy, nonatomic) NSArray *associatedDogs;

@end
