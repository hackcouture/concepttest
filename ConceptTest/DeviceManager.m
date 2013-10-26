//
//  DeviceManager.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "DeviceManager.h"
#import "GestureDetector.h"

@interface DeviceManager () <PLTDeviceConnectionDelegate>

@end

@implementation DeviceManager

+ (instancetype)sharedManager
{
    static DeviceManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });

    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailable:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
    }
    
    return self;
}

- (void)watchForDevices
{
    NSArray *devices = [PLTDevice availableDevices];
	if ([devices count] > 0) {
        [self connectToDevice:devices[0]];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailable:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

- (void)newDeviceAvailable:(NSNotification *)notification
{
    [self connectToDevice:notification.userInfo[PLTDeviceNewDeviceNotificationKey]];
}

- (void)connectToDevice:(PLTDevice *)device
{
    self.device = device;
    self.device.connectionDelegate = self;
    [self.device openConnection];
}

#pragma mark - 
#pragma mark PLTDeviceConnectionDelegate

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
    NSLog(@"fail 2 open: %@", error);
    self.device = nil;
}

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
    NSLog(@"opened connection");
    self.gestureDetector = [[GestureDetector alloc] initWithDevice:self.device];
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
    self.gestureDetector = nil;
}




@end