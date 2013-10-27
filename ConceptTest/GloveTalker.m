//
//  GloveTalker.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "GloveTalker.h"

#define kUrlString @"http://10.1.10.55:1234/replaceme"
#define kPollWait 0.1 // latency before reconnect

@interface GloveTalker () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property NSURLConnection *connection;

@end

@implementation GloveTalker

+ (instancetype)sharedGloveTalker
{
    static GloveTalker *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // wat
    }
    return self;
}

- (NSURLRequest *)request
{
    return [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kUrlString]];
}

- (void)connect
{
    self.connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self];
    [self.connection start];
}

- (void)connectAfterDelay
{
    double delayInSeconds = kPollWait;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self connect];
    });
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // i'm like yay
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *package = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    for (NSString *message in [package componentsSeparatedByString:@"\n"]) {
        NSArray *fields = [message componentsSeparatedByString:@","];
        NSAssert(fields.count == 4, @"fuck, man");
        
        NSMutableArray *numericFields = [NSMutableArray arrayWithCapacity:fields.count];
        for (NSString *field in fields) {
            [numericFields addObject:@([field boolValue])];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GloveTalkerFieldStateDidChangeNotification object:numericFields];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self connectAfterDelay];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Loooooooooooooooooop
    [self connectAfterDelay];
}

@end
