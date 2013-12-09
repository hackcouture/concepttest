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

#define USE_GLOVE self.gloveSwitch.isOn
#define USE_SHAKE_TRIGGER 1

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
    
//    self.view.backgroundColor = [UIColor colorWithHex:0xffaabb];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggered) name:GestureDetectorYesDetectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSwitches:) name:GloveTalkerFieldStateDidChangeNotification object:nil];
    
    [self setupAudioPlayers];
    
    [self recolor];
    
    // start in sequence
    self.mode = SequenceMode;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.gameStep = 0;

    if (USE_GLOVE) {
        [self highlightPressedButtons];
    } else {
        [self recolor];
        [self highlightButton:0];
    }
}



- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if USE_SHAKE_TRIGGER

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self triggered];
    }
}

#endif

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
    NSArray *oldStates = self.states;
    self.states = notification.object;
    NSAssert(self.states.count == 4, @"i'm like, wtf?");
    
    if (self.mode == FreejamMode || self.mode == GameMode) {
        [self highlightPressedButtons];
    }
    
    // trigger if states changed
    for (int i=0;i<4;i++) {
        if ([oldStates[i] boolValue] != [self.states[i] boolValue]) {
            [self triggered];
            break;
        }
    }
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
        [self stopAll];
        
        if (USE_GLOVE) {
            for (int i = 0 ; i<self.states.count; i++) {
                if ([self.states[i] boolValue] == 1) {
                    AVAudioPlayer *player = self.players[i];
                    [player play];
                }
            }
        } else {
            [(AVAudioPlayer *)self.players[self.nextSound] play];
        }

        if ([self checkForWin]) {
            [self rainbowAnimate];
        }
        
    } else if (![[self.players lastObject] isPlaying]) {
        NSInteger seqSound = sequence[self.nextInSequence];
        [self stopAll];
        [(AVAudioPlayer *)self.players[seqSound] play];
        self.nextInSequence = (self.nextInSequence + 1) % seqLength;

        [self recolor];
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
        [self recolor];
        [self highlightButton:sender.tag];

    }
}

- (void)triggered
{
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

- (UIButton *)buttonForIndex:(NSInteger)n
{
    switch (n) {
        case 0:
            return self.aButton;
        case 1:
            return self.bButton;
        case 2:
            return self.cButton;
        case 3:
            return  self.dButton;
        default:
            return nil;
    }
}

- (void)highlightButton:(NSInteger)n
{
    UIButton *target = [self buttonForIndex:n];
    target.backgroundColor = [target.backgroundColor offsetWithHue:0.0 saturation:1.0 brightness:1.0 alpha:1.0];
}

- (void)highlightPressedButtons
{
    [self recolor];
    for (int i=0; i<self.states.count; i++) {
        if ([self.states[i] boolValue] == YES) {
            [self highlightButton:i];
        }
    }
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

        [self recolor];
        [self highlightButton:seqSound];
    }
}

- (IBAction)didChangeGloveSwitch:(id)sender
{
    [self highlightPressedButtons];
}

@end
