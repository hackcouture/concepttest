//
//  GloveTalker.h
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GloveTalkerFieldStateDidChangeNotification @"GloveTalkerFieldStateDidChange"

@interface GloveTalker : NSObject

+ (instancetype)sharedGloveTalker;

- (void)connect;

@end
