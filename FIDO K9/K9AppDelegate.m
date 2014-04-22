//
//  K9AppDelegate.m
//  FIDO K9
//
//  Created by Taylor on 4/4/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9AppDelegate.h"
#import "K9ObjectGraph.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"
#import "K9Event.h"
#import "Forecastr.h"
#import "AFNetworkActivityIndicatorManager.h"

#define PUSHER_API_KEY @"e7b137a34da31bed01d9"
#define FORECAST_API_KEY @"2dfce017e2dab289bc77cdabd3e77c44"

@implementation K9AppDelegate {
    __strong PTPusher *_client;
    UIBackgroundTaskIdentifier bgTask;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:6 * 1024 * 1024
                                                         diskCapacity:60 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.window setTintColor:[UIColor colorWithRed:238.0/255.0 green:230.0/255.0 blue:104.0/255.0 alpha:1.0]];
    
    [[Forecastr sharedManager] setApiKey:FORECAST_API_KEY];
    

    return YES;
}

#define LOCAL_NOTIFICATION_EVENT_ID_KEY (@"eventID")
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if([[notification userInfo] objectForKey:LOCAL_NOTIFICATION_EVENT_ID_KEY]) {
        NSNumber *eventID = [[notification userInfo] objectForKey:LOCAL_NOTIFICATION_EVENT_ID_KEY];
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        UINavigationController *eventNavigationController = [[tabBarController childViewControllers] objectAtIndex:1];
        [tabBarController setSelectedIndex:1];
        
        [eventNavigationController popToRootViewControllerAnimated:NO];
        
        UIViewController *recentEvents = [eventNavigationController topViewController];
        [recentEvents performSegueWithIdentifier:@"selectedEventSegue" sender:eventID];
    }
    
    // Make sure the banner doesn't stick around
    [application cancelLocalNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self registerForPusher];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)registerForPusher {
    if(bgTask == UIBackgroundTaskInvalid) {
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Pusher Background Task" expirationHandler:^{
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            localNotif.fireDate = [NSDate date];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.alertBody = @"I'm going to sleep";
            localNotif.alertAction = @"Wake Me Up";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            NSLog(@"sleeping");
            bgTask = UIBackgroundTaskInvalid;
        }];
        if(bgTask == UIBackgroundTaskInvalid) {
            NSLog(@"Failed to start background task");
        } else {
            NSLog(@"Started background task: %ld", bgTask);
        }
    }
    
    if(!_client) {
        [[K9ObjectGraph sharedObjectGraph] fetchEventPusherChannelWithCompletionHandler:^(NSString *pusherChannel) {
            NSLog(@"PusherChannel: %@", pusherChannel);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _client = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
                [_client connect];
                [_client subscribeToChannelNamed:pusherChannel];
                [_client bindToEventNamed:@"sync" handleWithBlock:^(PTPusherEvent *event) {
                    [self handlePusherEventNotification:(NSDictionary *)event.data];
                    
                }];
            });

        }];
    }
}

#define PUSHER_EVENT_ID_KEY (@"resourceId")
- (void)handlePusherEventNotification:(NSDictionary *)eventData {
    NSInteger eventID = [[eventData objectForKey:PUSHER_EVENT_ID_KEY] integerValue];
    [[K9ObjectGraph sharedObjectGraph] fetchEventWithID:eventID completionHandler:^(K9Event *event) {
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            localNotif.fireDate = [NSDate date];
            localNotif.timeZone = [NSTimeZone defaultTimeZone];
            localNotif.alertBody = [event title];
            localNotif.alertAction = @"View";
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.userInfo = @{LOCAL_NOTIFICATION_EVENT_ID_KEY: @(eventID)};
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
    }];
}

@end
