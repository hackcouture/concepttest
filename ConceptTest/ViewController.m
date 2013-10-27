//
//  ViewController.m
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import "ViewController.h"
#import "GestureDetector.h"
#import "GloveTalker.h"

#define kAColor [UIColor colorWithHex:0x99ffac]
#define kBColor [UIColor colorWithHex:0xff99e7]
#define kCColor [UIColor colorWithHex:0x99caff]
#define kDColor [UIColor colorWithHex:0xffcc99]

// smoke on the water (applause)
static NSInteger sequence[] = {0,1,3,0,1,2,3,0,1,3,1,0,4};
static NSInteger seqLength = sizeof(sequence)/sizeof(NSInteger);

@interface ViewController ()

@property (nonatomic) NSArray  *players;
@property (nonatomic) NSArray  *states;

@property (nonatomic) NSInteger nextSound;
@property (nonatomic) NSInteger nextInSequence;

@property (nonatomic) NSInteger gameStep;

@property (nonatomic) NSTimer *animateTimer;

@end

@implementation ViewController

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggered) name:GestureDetectorYesDetectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSwitches:) name:GloveTalkerFieldStateDidChangeNotification object:nil];

    [self setupAudioPlayers];
    
    [self recolor];
    
    // start in sequence
    self.mode = SequenceMode;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.gameStep = 0;
    [self highlightButton:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAudioPlayers
{
    NSArray *sampleNames = @[@"guitar_chord_A_01", @"guitar_chord_B_01", @"guitar_chord_C_01", @"guitar_chord_D_01", @"crowd_cheer_01"];
    
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

- (void)updateSwitches:(NSNotification *)notification
{
    NSArray *states = notification.object;
    NSAssert(states.count == 4, @"i'm like, wtf?");
}

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

- (void)playNext
{
    if (self.mode == FreejamMode || self.mode == GameMode) {
        [self startSound:self.nextSound];

        if ([self checkForWin]) {
            [self rainbowAnimate];
        }
        
    } else if (![[self.players lastObject] isPlaying]) {
        NSInteger seqSound = sequence[self.nextInSequence];
        [self startSound:seqSound];
        self.nextInSequence = (self.nextInSequence + 1) % seqLength;

        [self highlightButton:seqSound];
        if (seqSound == 4) {
            // winning!
            [self rainbowAnimate];
        }
    }
}

- (BOOL)checkForWin
{
    NSInteger expected = sequence[self.gameStep];
    if (expected == self.nextSound) {
        self.gameStep++;
    } else {
        self.gameStep = 0;  
    }
    
    // seqLength - 1 because the last is the cheering...
    if (self.gameStep >= seqLength-1) {
        // restart the game and win!
        self.gameStep = 0;
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)didTapButton:(UIButton *)sender
{
    if (self.mode == FreejamMode || self.mode == GameMode) {
        self.nextSound = sender.tag;
        [self highlightButton:sender.tag];
    }
}

- (void)triggered
{
    NSInteger next = sequence[self.nextInSequence];
    [self playNext];
}

#pragma mark -
#pragma mark coloring

- (void)recolor
{
    self.aButton.backgroundColor = [kAColor offsetWithHue:0 saturation:-0.2 brightness:0 alpha:0];
    self.bButton.backgroundColor = [kBColor offsetWithHue:0 saturation:-0.2 brightness:0 alpha:0];
    self.cButton.backgroundColor = [kCColor offsetWithHue:0 saturation:-0.2 brightness:0 alpha:0];
    self.dButton.backgroundColor = [kDColor offsetWithHue:0 saturation:-0.2 brightness:0 alpha:0];
}

- (void)highlightButton:(NSInteger)n
{
    UIButton *target = nil;
    switch (n) {
        case 0:
            target = self.aButton;
            break;
        case 1:
            target = self.bButton;
            break;
        case 2:
            target = self.cButton;
            break;
        case 3:
            target = self.dButton;
            break;
        default:
            break;
    }
    
    [self recolor];
    target.backgroundColor = [target.backgroundColor offsetWithHue:0.0 saturation:1.0 brightness:1.0 alpha:1.0];
}

- (void)rainbowAnimate
{
    __block NSInteger count = 0;
    __weak typeof(self) slf = self;
    [self recolor];
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 block:^{
        count++;
        if (count > 120) {
            [slf.animateTimer invalidate];
            slf.animateTimer = nil;
                [self recolor];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
                for (UIButton *b in @[self.aButton, self.bButton, self.cButton, self.dButton]) {
                    b.backgroundColor = [b.backgroundColor offsetWithHue:0.05 saturation:0.1 brightness:0.1 alpha:0];
                }
            }];

        }
    } repeats:YES];
    
}

#pragma mark - 
#pragma mark lets make it a game and stuff

- (IBAction)didChangeSegmentedControl:(id)sender
{
    // just happens to line up...
    self.mode = self.segmentedControl.selectedSegmentIndex;
    
    // reset game if they leave game mode
    if (self.mode != GameMode) {
        self.gameStep = 0;
    }
    
    if (self.mode == SequenceMode) {
        NSInteger seqSound = sequence[MAX(self.nextInSequence-1,0)];
        [self highlightButton:seqSound];
    }
}

@end
