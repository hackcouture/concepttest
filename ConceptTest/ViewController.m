//
//  ViewController.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "ViewController.h"
#import "GestureDetector.h"
#import "F3PlotStrip.h"

@interface ViewController ()

@property (nonatomic) NSArray  *players;
@property (nonatomic) NSInteger nextSound;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yes) name:GestureDetectorYesDetectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(no) name:GestureDetectorNoDetectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlotStrip:) name:GestureDetectorMotionNotification object:nil];
    
    self.headingStrip.value = self.pitchStrip.value = 0;
    self.headingStrip.upperLimit = self.pitchStrip.upperLimit = 200;
    self.headingStrip.lowerLimit = self.pitchStrip.lowerLimit = -200;
    
    [self setupAudioPlayers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAudioPlayers
{
    NSArray *sampleNames = @[@"guitar_chord_A_01", @"guitar_chord_B_01", @"guitar_chord_C_01", @"guitar_chord_D_01"];
    NSMutableArray *players = [NSMutableArray array];
    for (NSString *fileName in sampleNames) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"caf"];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [player prepareToPlay];
        [players addObject:player];
    }
    
    self.players = players;
}

#pragma mark -
#pragma mark button tapping

- (void)startSound:(NSInteger)index
{
    AVAudioPlayer *player = self.players[index];
    [self stopAll];
    
    [player play];
}

- (void)stopAll
{
    for (AVAudioPlayer *p in self.players) {
        [p stop];
        p.currentTime = 0;
        [p prepareToPlay];
    }
}

- (IBAction)didTapA:(id)sender
{
    self.nextSound = 0;
}

- (IBAction)didTapB:(id)sender
{
    self.nextSound = 1;
}

- (IBAction)didTapC:(id)sender
{
    self.nextSound = 2;
}

- (IBAction)didTapD:(id)sender
{
    self.nextSound = 3;
}


- (void)yes
{
    [self startSound:self.nextSound];
}

- (void)no
{
    [self startSound:self.nextSound];
}

- (void)updatePlotStrip:(NSNotification *)notification
{
    PLTOrientationTrackingInfo *info = notification.object;
    double x = info.eulerAngles.x;
    double y = info.eulerAngles.y;
    
    self.headingStrip.value = x;
    self.pitchStrip.value = y;
}




@end
