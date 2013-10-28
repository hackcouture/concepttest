//
//  GestureDetector.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "GestureDetector.h"

#define kThreshold 15
#define kMovingAvgConstant 0.1

@interface GestureDetector () <PLTDeviceInfoObserver>

@property (nonatomic) PLTDevice *device;
@property (nonatomic) BOOL triggered;
@property (nonatomic) double pitchAverage;

@end

@implementation GestureDetector

- (instancetype)initWithDevice:(PLTDevice *)device
{
    self = [super init];
    if (self != nil) {
        self.device = device;
        [device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
    }
    
    return self;
}

- (void)dealloc
{
    [self.device unsubscribe:self fromService:PLTServiceOrientationTracking];
}

#pragma mark -
#pragma mark PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
    if ([theInfo class] == [PLTOrientationTrackingInfo class]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GestureDetectorMotionNotification object:theInfo];
        [self gestureCheck:(PLTOrientationTrackingInfo *)theInfo];
    }
}


#pragma mark -
#pragma mark Gesture detection

- (void)gestureCheck:(PLTOrientationTrackingInfo *)info
{
    double pitch = info.eulerAngles.y;
    
    self.pitchAverage = self.pitchAverage * (1.0 - kMovingAvgConstant) + pitch * kMovingAvgConstant;
    
    // add for backswings: || pitch >= (self.pitchAverage + kThreshold)
    if (pitch <= (self.pitchAverage - kThreshold)) {
        // fire once when you get beyond threshold
        if (!self.triggered) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GestureDetectorYesDetectedNotification object:nil];;
            self.triggered = YES;
        }
    } else {
        // reset
        self.triggered = NO;
    }
}

@end
