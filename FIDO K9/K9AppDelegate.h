//
//  K9AppDelegate.h
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusher.h"

@interface K9AppDelegate : UIResponder <UIApplicationDelegate, PTPusherDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
