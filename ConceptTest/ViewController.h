//
//  ViewController.h
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SequenceMode,
    FreejamMode,
    GameMode
} AppMode;

@interface ViewController : UIViewController <UIBarPositioningDelegate>

@property (nonatomic, weak) IBOutlet UINavigationBar *bar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet UISwitch *gloveSwitch;

@property (nonatomic) AppMode mode;

@property (nonatomic, weak) IBOutlet UIButton *aButton;
@property (nonatomic, weak) IBOutlet UIButton *bButton;
@property (nonatomic, weak) IBOutlet UIButton *cButton;
@property (nonatomic, weak) IBOutlet UIButton *dButton;

- (IBAction)didChangeGloveSwitch:(id)sender;
- (IBAction)didChangeSegmentedControl:(id)sender;
- (IBAction)didTapButton:(id)sender;

- (IBAction)stopAll;

@end
