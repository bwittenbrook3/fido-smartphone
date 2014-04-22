//
//  K9Event.m
//  FIDO K9
//
//  Created by Taylor on 4/6/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Event.h"
#import "K9ObjectGraph.h"
#import "K9Dog.h"
#import <Foundation/NSJSONSerialization.h>

#import "K9Photo.h"

#import <MapKit/MapKit.h>

#define ID_KEY @"id"
#define DOG_KEY @"vest_id"
#define ATTACHMENT_ID @"attachment_id"
#define CREATION_DATE @"created_at"
#define UPDATE_DATE @"updated_at"

#define TITLE_KEY @"alert"
#define DETAIL_KEY @"details"

#define LATITUDE_KEY @"latitude"
#define LONGITUDE_KEY @"longitude"

#define RAND ((((float)rand() / RAND_MAX)-0.5)*0.0002)

NSString *const K9EventDidModifyResourcesNotification = @"K9EventDidModifyResourcesNotification";
NSString *const K9EventAddedResourcesNotificationKey = @"K9EventAddedResourcesNotificationKey";

@implementation K9Event

+ (K9Event *)eventWithPropertyList:(NSDictionary *)propertyList {    

    K9Event *event = [K9Event new];
    
    NSInteger dogID = [[propertyList objectForKey:DOG_KEY] integerValue];
    NSInteger attachmentID = [[propertyList objectForKey:ATTACHMENT_ID] integerValue];
    
    K9Dog *dog = [[K9ObjectGraph sharedObjectGraph] dogWithID:dogID];
    if(!dog) {
        // TODO: Delay loading of dog objects until requested
        [[K9ObjectGraph sharedObjectGraph] fetchDogWithID:dogID completionHandler:^(K9Dog *dog) {
            if(dog) {
                event.associatedDogs = @[dog];
            }
            [event _generatePaths];
        }];
    } else {
        // TODO: Remove the extra test dog when the API supports it
        K9Dog *dog2 = [[K9ObjectGraph sharedObjectGraph] dogWithID:(dogID+1)];
        if(dog2) {
            K9Dog *dog3 = [[K9ObjectGraph sharedObjectGraph] dogWithID:(dogID+2)];
            if(dog3) {
                event.associatedDogs = @[dog, dog2, dog3];
            } else {
                event.associatedDogs = @[dog, dog2];
            }
        } else {
            event.associatedDogs = @[dog];
        }
    }

    event.eventID = [[propertyList valueForKeyPath:ID_KEY] integerValue];
    event.title = [propertyList objectForKey:TITLE_KEY];
    event.eventDescription = [propertyList objectForKey:DETAIL_KEY];
    
    // TODO: Get event type from web api when it supports it
    event.eventType = K9EventTypeSuspiciousBag;
    if ([[event.title lowercaseString] rangeOfString:@"item"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousItem;
    } else if ([[event.title lowercaseString] rangeOfString:@"person"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousPerson;
    } else if ([[event.title lowercaseString] rangeOfString:@"gun"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousPerson;
    } else if ([[event.title lowercaseString] rangeOfString:@"box"].location != NSNotFound) {
        event.eventType = K9EventTypeSuspiciousItem;
    }
        
    if((id)event.eventDescription == [NSNull null]) {
        event.eventDescription = nil;
    }
    
    event.resources = @[];
    
    [[K9ObjectGraph sharedObjectGraph] fetchResourcesForEventWithID:event.eventID completionHandler:^(NSArray *resources) {
        [event addResources:resources];
    }];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    event.creationDate = [formatter dateFromString:[propertyList objectForKey:CREATION_DATE]];
    event.updateDate = [formatter dateFromString:[propertyList objectForKey:UPDATE_DATE]];
    
    CGFloat latitude = [[propertyList objectForKey:LATITUDE_KEY] floatValue];
    CGFloat longitude = [[propertyList objectForKey:LONGITUDE_KEY] floatValue];
    
    if(abs(latitude) < 0.001) latitude = 33.773451;
    if(abs(longitude)  < 0.001) longitude = -84.392783;
    event.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
//    NSString *JSONarray = @"[[33.77372269517606,-84.39316486465334],[33.77371437918544,-84.39316486465334],[33.77370814219194,-84.39316486465334],[33.77369982619987,-84.39316486465334],[33.77369151020702,-84.39316486465334],[33.77368527321185,-84.39316486465334],[33.77367695721755,-84.39316486465334],[33.77367072022136,-84.39316486465334],[33.77366448322466,-84.39316486465334],[33.77365616722837,-84.39316486465334],[33.77364993023062,-84.39316736573467],[33.77362914023486,-84.39316736573467],[33.77362290323514,-84.39316986681595],[33.77361666623497,-84.39316986681595],[33.77361042923434,-84.39316986681595],[33.77360419223327,-84.39316986681595],[33.77359795523177,-84.39317236789729],[33.77359171822979,-84.39317236789729],[33.77358756022819,-84.39317236789729],[33.77358132322545,-84.39317236789729],[33.77357716522335,-84.39317236789729],[33.77357092821986,-84.39317236789729],[33.77356677021728,-84.39317236789729],[33.77356261221451,-84.39317236789729],[33.77355845421154,-84.39317236789729],[33.77355221720666,-84.39317486897862],[33.77354805920316,-84.39317486897862],[33.77354390119947,-84.39317486897862],[33.77352726918267,-84.39317737005992],[33.77352311117798,-84.39317737005992],[33.77351687417055,-84.39317737005992],[33.77351271616534,-84.39317737005992],[33.77350855815995,-84.39317737005992],[33.77350232115145,-84.39317737005992],[33.77349816314551,-84.39317737005992],[33.77348361012324,-84.39317737005992],[33.7734690570985,-84.39317737005992],[33.77346489909095,-84.39317486897862],[33.77346074108322,-84.39316986681595],[33.77345866207927,-84.39316736573467],[33.77345450407125,-84.39316236357203],[33.77345242506718,-84.39315736140941],[33.77344826705882,-84.39315235924676],[33.77344410905029,-84.39314735708412],[33.77344203004593,-84.39314235492149],[33.7734378720371,-84.39313735275883],[33.77343579303262,-84.39313235059622],[33.77343163502346,-84.39312734843358],[33.77342955601883,-84.39311984518963],[33.77342331900459,-84.39309983653909],[33.77341708198989,-84.39307482572592],[33.77341500298488,-84.39306482140064],[33.77341292397984,-84.39305231599405],[33.77341084497473,-84.39304231166879],[33.77341084497473,-84.39303480842484],[33.77340876596956,-84.39302480409957],[33.77340876596956,-84.39301730085563],[33.77340668696439,-84.39300729653036],[33.77340668696439,-84.39299729220507],[33.77340668696439,-84.3929897889611],[33.77340668696439,-84.39298228571718],[33.77340668696439,-84.39295977598532],[33.77340668696439,-84.39293726625345],[33.77340668696439,-84.39292976300952],[33.77340876596956,-84.39290725327766],[33.77341084497473,-84.39289975003371],[33.77341292397984,-84.39288974570842],[33.77341708198989,-84.39287974138315],[33.77341916099482,-84.39287223813919],[33.77342123999972,-84.39286223381394],[33.77342331900459,-84.39285222948867],[33.77342955601883,-84.39282721867549],[33.77343163502346,-84.39281971543153],[33.77343371402805,-84.39281221218759],[33.77343371402805,-84.39280470894363],[33.77343579303262,-84.39279720569967],[33.77343579303262,-84.39278970245574],[33.77343579303262,-84.39278219921178],[33.77343579303262,-84.39277719704916],[33.7734378720371,-84.39276969380521],[33.7734378720371,-84.39276219056124],[33.77343995104156,-84.39275468731729],[33.77343995104156,-84.39274718407334],[33.77343995104156,-84.39271216893488],[33.77343995104156,-84.39270216460963],[33.77343995104156,-84.39269466136568],[33.77343995104156,-84.39268965920304],[33.77343995104156,-84.39268465704042],[33.77343995104156,-84.39267965487777],[33.77343995104156,-84.39267465271513],[33.77343995104156,-84.39266214730856],[33.77343995104156,-84.39264964190197]]";
    
//    NSData *data = [JSONarray dataUsingEncoding:NSUTF8StringEncoding];
//    NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    // TODO: Get the real paths when web API can give them
    [event _generatePaths];
    
    
    return event;
}

- (void)_generatePaths {
    NSMutableArray *paths = [NSMutableArray array];
    for(K9Dog *dog in self.associatedDogs) {
        K9DogPath *path = [K9DogPath new];
        path.dog = dog;
        path.event = self;
        NSUInteger numCoordinates = arc4random_uniform(50) + 2;
        CLLocationCoordinate2D coordinates[numCoordinates];
        for(int i = 0; i < numCoordinates; i++) {
            CLLocationCoordinate2D lastCoord = CLLocationCoordinate2DMake(self.location.coordinate.latitude + RAND, self.location.coordinate.longitude + RAND);
            if(i != 0) {
                lastCoord = coordinates[i - 1];
            }
            coordinates[i] = CLLocationCoordinate2DMake(lastCoord.latitude + RAND, lastCoord.longitude + RAND);
        }
        //        NSUInteger numCoordinates = [points count];
        //        CLLocationCoordinate2D coordinates[numCoordinates];
        //        for(int i = 0; i < numCoordinates; i++) {
        //            NSArray *coordinate = [points objectAtIndex:i];
        //            CGFloat lat = [[coordinate firstObject] floatValue];
        //            CGFloat longitude = [[coordinate lastObject] floatValue];
        //            coordinates[i] = CLLocationCoordinate2DMake(lat, longitude);
        //        }
        
        [path setCoordinates:coordinates count:numCoordinates];
        [paths addObject:path];
    }
    self.dogPaths = paths;
}

- (void)addResources:(NSArray *)resources {
    self.resources = [self.resources arrayByAddingObjectsFromArray:resources];
    
    NSDictionary *userInfo = @{K9EventAddedResourcesNotificationKey : resources};
    [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self userInfo:userInfo];
}

- (void)addResource:(K9Resource *)resource progressHandler:(void (^)(CGFloat progress))progressHandler{
    self.resources = [self.resources arrayByAddingObject:resource];
    
    NSDictionary *userInfo = @{K9EventAddedResourcesNotificationKey : @[resource]};
    [[NSNotificationCenter defaultCenter] postNotificationName:K9EventDidModifyResourcesNotification object:self userInfo:userInfo];
    
    resource.uploaded = NO;
    [[K9ObjectGraph sharedObjectGraph] uploadResource:resource forEvent:self progressHandler:^(CGFloat progress) {
        NSDictionary *progressInfo = @{@"progress": @(progress)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"progress" object:resource userInfo:progressInfo];
        if(progress > 0.99) {
            resource.uploaded = YES;
        }
    }];
}

@end

@implementation K9DogPath {
    __strong MKPolyline *polyline;
}

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count {
    polyline = [MKPolyline polylineWithCoordinates:coordinates count:count];
}

- (CLLocationCoordinate2D)coordinate {
    return [polyline coordinate];
}

- (MKMapRect)boundingMapRect {
    return [polyline boundingMapRect];
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [polyline intersectsMapRect:mapRect];
}

- (MKPolyline *)polyline {
    return polyline;
}

@end
