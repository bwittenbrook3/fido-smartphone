//
//  K9MapAnnotation+AnnotationSnapshot.m
//  FIDO K9
//
//  Created by Taylor on 4/19/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#import "K9MapAnnotation+AnnotationSnapshot.h"
#import <objc/runtime.h>

@implementation K9MapAnnotation (MapAnnotationSnapshot)

- (UIImage *)mapAnnotationSnapshot {
    return objc_getAssociatedObject(self, @selector(mapAnnotationSnapshot));
}

- (void)setMapAnnotationSnapshot:(UIImage *)mapAnnotationSnapshot {
    if(mapAnnotationSnapshot != self.mapAnnotationSnapshot) {
        objc_setAssociatedObject(self, @selector(mapAnnotationSnapshot), mapAnnotationSnapshot, OBJC_ASSOCIATION_RETAIN);
    }
}

@end