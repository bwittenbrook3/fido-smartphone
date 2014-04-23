//
//  K9Activation.h
//  FIDO K9
//
//  Created by Taylor on 4/22/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class K9Attachment, K9Dog;
@interface K9Activation : NSObject

@property (nonatomic, strong) K9Attachment *attachment;
@property (nonatomic, weak) K9Dog *dog;

@property (copy) NSDate *triggerTime;


@end
