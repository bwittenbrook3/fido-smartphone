//
//  K9Dog+Annotation.m
//  FIDO K9
//
//  Created by Taylor on 4/18/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9Dog+Annotation.h"

@implementation K9Dog (K9DogAnnotation)

- (CLLocationCoordinate2D)coordinate {
    return self.lastKnownLocation.coordinate;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    return self.status;
}

@end