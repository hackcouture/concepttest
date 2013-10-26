//
//  GestureDetector.h
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GestureDetectorYesDetectedNotification @"GestureDetectorYesDetected"
#define GestureDetectorNoDetectedNotification @"GestureDetectorNoDetected"
#define GestureDetectorMotionNotification @"GestureDetectorMotion"

@interface GestureDetector : NSObject

typedef enum {
    GEST_START,
    GEST_ARM,
    GEST_UP,
    GEST_LEFT,
    GEST_YES,
    GEST_NO
} gesture_states;

@property (nonatomic) double theta_ave;
@property (nonatomic) double psi_ave;
@property (nonatomic) long long oldtime;
@property (nonatomic) gesture_states gesture_state;

- (instancetype)initWithDevice:(PLTDevice *)device;

@end
