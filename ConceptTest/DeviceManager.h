//
//  DeviceManager.h
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GestureDetector;

@interface DeviceManager : NSObject

@property (nonatomic) PLTDevice *device;
@property (nonatomic) GestureDetector *gestureDetector;

+ (instancetype)sharedManager;
- (void)watchForDevices;

@end
