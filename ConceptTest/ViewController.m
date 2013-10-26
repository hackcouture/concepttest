//
//  ViewController.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "ViewController.h"
#import "GestureDetector.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up labels
    
    self.yesLabel.hidden = YES;
    self.noLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yes) name:GestureDetectorYesDetectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(no) name:GestureDetectorNoDetectedNotification object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)yes
{
    self.yesLabel.hidden = NO;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.yesLabel.hidden = YES;
    });
}

- (void)no
{
    self.noLabel.hidden = NO;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.noLabel.hidden = YES;
    });
}


@end
