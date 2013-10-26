//
//  GestureDetector.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "GestureDetector.h"

@interface GestureDetector () <PLTDeviceInfoObserver>

@property (nonatomic) PLTDevice *device;

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
    PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
    [self gestureCheck:theInfo.timestamp.timeIntervalSince1970 noplane:eulerAngles.x yesplane:eulerAngles.z];
}


#pragma mark -
#pragma mark Gesture detection

- (void)gestureCheck:(long long)thetime noplane:(double) theta yesplane:(double)psi
{
    self.theta_ave = self.theta_ave * .8 + theta * .2;
    self.psi_ave = self.psi_ave * .8 + psi * .2;
    
    if ((thetime - self.oldtime) > 5000 || (thetime - self.oldtime) < 0)
        self.oldtime = thetime;
    
    if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_UP || self.gesture_state == GEST_LEFT))
    {
        self.gesture_state = GEST_START;
        self.oldtime = thetime;
        
    }
    else if ((thetime - self.oldtime) > 2000 && (self.gesture_state == GEST_YES || self.gesture_state == GEST_NO))
    {
        self.gesture_state = GEST_START;
        self.oldtime = thetime;
        
    }
    else if (((theta - self.theta_ave) < -8) && (self.gesture_state == GEST_START))
    {
        self.gesture_state = GEST_UP;
        self.oldtime = thetime;
    }
    else if ((theta - self.theta_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_UP))
    {
        self.gesture_state = GEST_YES;
        self.oldtime = thetime;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GestureDetectorYesDetectedNotification object:nil];
        self.gesture_state = GEST_START;
    }
    else if (((psi - self.psi_ave) < -8) && (self.gesture_state == GEST_START))
    {
        self.gesture_state = GEST_LEFT;
        self.oldtime = thetime;
    }
    else if ((psi - self.psi_ave) > 8 && ((thetime - self.oldtime) < 1000) && (self.gesture_state == GEST_LEFT))
    {
        self.gesture_state = GEST_NO;
        self.oldtime = thetime;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GestureDetectorNoDetectedNotification object:nil];
        self.gesture_state = GEST_START;
    }
}

@end
