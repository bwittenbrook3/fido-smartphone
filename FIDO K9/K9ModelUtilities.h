//
//  K9ModelUtilities.h
//  FIDO K9
//
//  Created by Taylor on 4/16/14.
//  Copyright (c) 2014 FIDO. All rights reserved.
//

#ifndef FIDO_K9_K9ModelUtilities_h
#define FIDO_K9_K9ModelUtilities_h



static inline BOOL objectIsEmptyCheck(id object) {
    return (!object || object == [NSNull null]);
}
static inline id objectWithEmptyCheck(id object, id defaultObject) {
    if(objectIsEmptyCheck(object)) {
        return defaultObject;
    } else {
        return object;
    }
}

#endif